import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme/monex_theme.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/monex_widgets.dart';
import '../models/location_snapshot.dart';
import '../models/store.dart';
import '../state/app_scope.dart';

/// Toko Terdekat: peta OpenStreetMap, jarak toko, dan notifikasi lokasi.
class NearbyStoresScreen extends StatefulWidget {
  const NearbyStoresScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<NearbyStoresScreen> createState() => _NearbyStoresScreenState();
}

class _NearbyStoresScreenState extends State<NearbyStoresScreen> {
  static const _demoCenter = LatLng(-6.2088, 106.8456);
  static const _nearestNotificationId = 2002;

  final _query = TextEditingController();
  final _mapController = MapController();

  LatLng _center = _demoCenter;
  LocationSnapshot? _snapshot;
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
        _snapshot = snapshot;
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

  Future<void> _notifyNearest() async {
    final stores = _stores;
    if (stores == null || stores.isEmpty) return;
    final nearest = stores.first;
    final notifications = AppScope.of(context).notificationService;

    try {
      var granted = await notifications.areNotificationsEnabled();
      if (!granted) granted = await notifications.requestPermission();
      if (!granted) {
        if (!mounted) return;
        showMonexToast(
          context,
          'Izin notifikasi belum aktif. Aktifkan lewat pengaturan aplikasi.',
          isError: true,
        );
        return;
      }

      final origin = _snapshot?.coordinateLabel ?? 'lokasi demo Jakarta';
      await notifications.showImmediate(
        id: _nearestNotificationId,
        title: 'Toko terdekat: ${nearest.name}',
        body:
            '${_distanceLabel(nearest.distanceKm)} dari $origin. '
            '${nearest.address}',
      );
      if (!mounted) return;
      showMonexToast(
        context,
        'Notifikasi toko terdekat dikirim.',
        isSuccess: true,
      );
    } on Object {
      if (!mounted) return;
      showMonexToast(context, 'Gagal mengirim notifikasi.', isError: true);
    }
  }

  void _focusStore(Store store) {
    _mapController.move(LatLng(store.lat, store.lng), 15);
    showMonexToast(
      context,
      '${store.name} · ${_distanceLabel(store.distanceKm)}',
    );
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
              color: _usingDemoLocation
                  ? MonexColors.textMuted
                  : MonexColors.lime,
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
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: Colors.blueAccent,
                          size: 28,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  keyword.isEmpty
                      ? '${stores.length} toko dalam radius 25 km'
                      : '${stores.length} toko cocok dengan "$keyword"',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              TextButton.icon(
                key: const Key('stores_notify_nearest'),
                onPressed: stores.isEmpty ? null : _notifyNearest,
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('Notifikasi'),
              ),
            ],
          ),
        ],
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
    final price = query.isEmpty ? null : store.priceFor(query);

    return MonexSurfaceCard(
      key: Key('store_${store.id}'),
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
              color: MonexColors.limeMuted,
              borderRadius: BorderRadius.circular(MonexSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 19,
              color: MonexColors.lime,
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
                      color: MonexColors.textMuted,
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
                          color: MonexColors.lime,
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
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: MonexColors.textMuted,
          ),
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
