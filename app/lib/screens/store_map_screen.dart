import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme/app_ui_colors.dart';
import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/location_snapshot.dart';
import '../models/store.dart';
import '../state/app_scope.dart';

/// Peta Toko Terdekat: peta OpenStreetMap, lokasi pengguna, dan jarak toko.
class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  static const _demoCenter = LatLng(-6.2088, 106.8456);

  final _query = TextEditingController();
  final _mapController = MapController();

  LatLng _center = _demoCenter;
  List<Store>? _stores;
  String? _locationNote;
  bool _loading = true;
  bool _locating = false;
  bool _usingDemoLocation = true;
  bool _mapReady = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _query.text = widget.initialQuery;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _refreshLocation();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _refreshLocation() async {
    if (_locating) return;
    setState(() => _locating = true);

    String? note;
    try {
      final snapshot = await AppScope.of(context).locationService
          .getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _center = LatLng(snapshot.latitude, snapshot.longitude);
        _usingDemoLocation = false;
        _locationNote =
            'Lokasi kamu: ${snapshot.coordinateLabel} '
            '(±${snapshot.accuracyMeters.round()} m)';
      });
      if (_mapReady) _mapController.move(_center, 14);
    } on LocationException catch (error) {
      note = '${error.message} Peta memakai lokasi demo Jakarta.';
    } on Object {
      note = 'Lokasi tidak tersedia. Peta memakai lokasi demo Jakarta.';
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
          if (note != null) {
            _locationNote = note;
            _usingDemoLocation = true;
          }
        });
      }
      await _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final stores = await AppScope.of(context).storeService.nearby(
        lat: _center.latitude,
        lng: _center.longitude,
        query: _query.text,
      );
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _loading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openLocationSettings() async {
    final opened = await AppScope.of(context).locationService.openAppSettings();
    if (!opened && mounted) {
      showMonexToast(
        context,
        'Pengaturan aplikasi tidak dapat dibuka.',
        isError: true,
      );
    }
  }

  void _focusStore(Store store) {
    _mapController.move(LatLng(store.lat, store.lng), 15);
    showMonexToast(
      context,
      '${store.name} · ${_distanceLabel(store.distanceKm)}',
    );
  }

  Future<void> _centerOnMyLocation() async {
    if (_mapReady) {
      _mapController.move(_center, 15);
    }
    await _refreshLocation();
  }

  void _clearSearch() {
    _query.clear();
    setState(() {});
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stores = _stores;

    return Scaffold(
      appBar: MonexAppBar(
        title: 'Toko Terdekat',
        subtitle: 'Peta & jarak toko komputer',
        showBack: true,
        actions: [
          MonexCircleIconButton(
            icon: Icons.my_location_rounded,
            tooltip: 'Perbarui lokasi',
            onTap: _locating ? null : _refreshLocation,
          ),
        ],
      ),
      body: SafeArea(
        child: stores == null
            ? _buildInitial(theme)
            : _buildContent(theme, stores),
      ),
    );
  }

  Widget _buildInitial(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: MonexOrbitLoader(
          size: 60,
          label: 'Mencari lokasi',
          message: 'Mengambil posisi dan toko di sekitarmu...',
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MonexSpacing.screenPaddingH),
        child: MonexEmptyState(
          icon: Icons.store_mall_directory_outlined,
          title: 'Toko belum bisa dimuat.',
          message: 'Data toko lokal tidak dapat dibaca.',
          actionLabel: 'Coba lagi',
          onAction: _load,
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, List<Store> stores) {
    final keyword = _query.text.trim();
    final showEmpty = !_loading && stores.isEmpty;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(child: _buildSearch(theme)),
        if (_locationNote != null)
          SliverToBoxAdapter(child: _buildLocationNote(theme)),
        SliverToBoxAdapter(child: _buildMap()),
        SliverToBoxAdapter(child: _buildToolbar(theme, stores)),
        if (_loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          ),
        if (showEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(MonexSpacing.screenPaddingH),
              child: MonexEmptyState(
                icon: Icons.store_mall_directory_outlined,
                title: keyword.isEmpty
                    ? 'Tidak ada toko dalam radius 25 km.'
                    : 'Tidak ada toko yang cocok dengan "$keyword".',
                message: keyword.isEmpty
                    ? 'Coba perbarui lokasi atau perluas pencarian.'
                    : 'Coba kata kunci lain, misalnya nama toko atau tipe produk.',
                actionLabel: keyword.isEmpty
                    ? 'Perbarui lokasi'
                    : 'Hapus filter',
                onAction: keyword.isEmpty ? _refreshLocation : _clearSearch,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              MonexSpacing.screenPaddingH,
              0,
              MonexSpacing.screenPaddingH,
              28,
            ),
            sliver: SliverList.separated(
              itemCount: stores.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: MonexSpacing.gridGap),
              itemBuilder: (context, index) => _StoreTile(
                store: stores[index],
                query: keyword,
                onTap: () => _focusStore(stores[index]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearch(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MonexSpacing.screenPaddingH,
        10,
        MonexSpacing.screenPaddingH,
        10,
      ),
      child: TextField(
        key: const Key('stores_search'),
        controller: _query,
        textInputAction: TextInputAction.search,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _load(),
        decoration: InputDecoration(
          hintText: 'Cari nama toko atau produk',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _query.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _clearSearch,
                ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildLocationNote(ThemeData theme) {
    final palette = MonexPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MonexSpacing.screenPaddingH,
      ),
      child: MonexSurfaceCard(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        radius: MonexSpacing.radiusMd,
        child: Row(
          children: [
            Icon(
              _usingDemoLocation
                  ? Icons.info_outline_rounded
                  : Icons.my_location_rounded,
              size: 18,
              color: _usingDemoLocation ? palette.textMuted : palette.accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_locationNote!, style: theme.textTheme.bodySmall),
            ),
            if (_usingDemoLocation)
              TextButton(
                onPressed: _openLocationSettings,
                child: const Text('Pengaturan'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    final stores = _stores ?? const <Store>[];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MonexSpacing.screenPaddingH,
        vertical: 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MonexSpacing.radiusCard),
        child: SizedBox(
          height: 230,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 13,
                  minZoom: 4,
                  maxZoom: 18,
                  onMapReady: () {
                    _mapReady = true;
                    _mapController.move(_center, 13);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.worthbang.worthbang_lite',
                    maxNativeZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center,
                        width: 34,
                        height: 34,
                        child: Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      for (final store in stores)
                        Marker(
                          point: LatLng(store.lat, store.lng),
                          width: 36,
                          height: 36,
                          child: GestureDetector(
                            onTap: () => _focusStore(store),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: MonexColors.lime,
                              size: 32,
                              shadows: [
                                Shadow(
                                  color: MonexColors.canvas,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              if (_usingDemoLocation)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: MonexColors.canvas.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(
                        MonexSpacing.radiusPill,
                      ),
                    ),
                    child: const Text(
                      'Lokasi demo',
                      style: TextStyle(
                        fontFamily: kMonexFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: MonexColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              // Tombol biru "Lokasi Saya" di pojok kanan bawah peta
              Positioned(
                right: 12,
                bottom: 28,
                child: Tooltip(
                  message: 'Lokasi saya',
                  child: Material(
                    key: const Key('stores_my_location_button'),
                    color: const Color(0xFF2563EB),
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: Colors.black.withValues(alpha: 0.35),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _locating ? null : _centerOnMyLocation,
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Center(
                          child: _locating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme, List<Store> stores) {
    final keyword = _query.text.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MonexSpacing.screenPaddingH,
        0,
        MonexSpacing.screenPaddingH,
        10,
      ),
      child: Text(
        keyword.isEmpty
            ? '${stores.length} toko dalam radius 25 km'
            : '${stores.length} toko cocok dengan "$keyword"',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({
    required this.store,
    required this.query,
    required this.onTap,
  });

  final Store store;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = MonexPalette.of(context);
    final price = query.isEmpty ? null : store.priceFor(query);

    return MonexSurfaceCard(
      key: Key('store_${store.id}'),
      color: AppUiColors.of(context).tokoCardBg,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: MonexSpacing.radiusMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
            ),
            child: Icon(
              Icons.storefront_outlined,
              size: 19,
              color: palette.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  '${store.address} · ${store.city}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.near_me_rounded,
                      size: 13,
                      color: palette.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _distanceLabel(store.distanceKm),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (price != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        formatRupiah(price),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded, size: 18, color: palette.textMuted),
        ],
      ),
    );
  }
}

String _distanceLabel(double distanceKm) {
  if (distanceKm < 1) {
    return '${(distanceKm * 1000).round()} m';
  }
  return '${distanceKm.toStringAsFixed(1)} km';
}
