import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/core_providers.dart';
import '../../../application/providers/employee_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Displays employee location track data on a Google Map.
///
/// The user selects an employee from a dropdown. Track points are fetched
/// from the API and displayed as markers connected by polylines.
///   - First point: green marker (start of route).
///   - Subsequent points: blue markers.
///   - Info windows show the timestamp of each point.
class EmployeeTrackingScreen extends ConsumerStatefulWidget {
  const EmployeeTrackingScreen({super.key});

  @override
  ConsumerState<EmployeeTrackingScreen> createState() =>
      _EmployeeTrackingScreenState();
}

class _EmployeeTrackingScreenState
    extends ConsumerState<EmployeeTrackingScreen> {
  String? _selectedEmployeeId;

  final Completer<GoogleMapController> _mapController = Completer();

  static const LatLng _defaultCenter = LatLng(17.385, 78.4867); // Hyderabad

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dealerId = ref.read(authLocalDatasourceProvider).dealerId;
      ref.read(employeeProvider.notifier).loadEmployees(dealerId: dealerId);
    });
  }

  void _onEmployeeSelected(String? employeeId) {
    if (employeeId == null) return;
    setState(() => _selectedEmployeeId = employeeId);
    ref.read(employeeProvider.notifier).loadEmployeeTrack(
          employeeId: employeeId,
        );
  }

  Future<void> _refreshTrack() async {
    if (_selectedEmployeeId == null) return;
    await ref.read(employeeProvider.notifier).loadEmployeeTrack(
          employeeId: _selectedEmployeeId!,
        );
  }

  // ── Map data builders ──────────────────────────────────────────────────

  Set<Marker> _buildMarkers(List<Map<String, dynamic>> trackPoints) {
    final markers = <Marker>{};

    for (var i = 0; i < trackPoints.length; i++) {
      final point = trackPoints[i];
      final lat = double.tryParse(point['latitude']?.toString() ?? '');
      final lng = double.tryParse(point['longitude']?.toString() ?? '');
      if (lat == null || lng == null) continue;

      final isFirst = i == 0;
      final timestamp = point['timestamp']?.toString() ?? '';
      final address = point['address']?.toString() ?? '';

      markers.add(
        Marker(
          markerId: MarkerId('track_$i'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isFirst
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: isFirst ? 'Start' : 'Point ${i + 1}',
            snippet: timestamp.isNotEmpty
                ? timestamp
                : (address.isNotEmpty ? address : null),
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(List<Map<String, dynamic>> trackPoints) {
    final coordinates = <LatLng>[];

    for (final point in trackPoints) {
      final lat = double.tryParse(point['latitude']?.toString() ?? '');
      final lng = double.tryParse(point['longitude']?.toString() ?? '');
      if (lat != null && lng != null) {
        coordinates.add(LatLng(lat, lng));
      }
    }

    if (coordinates.length < 2) return {};

    return {
      Polyline(
        polylineId: const PolylineId('employee_route'),
        points: coordinates,
        color: AppColors.primary,
        width: 3,
        patterns: [PatternItem.dash(12), PatternItem.gap(6)],
      ),
    };
  }

  Future<void> _fitBounds(List<Map<String, dynamic>> trackPoints) async {
    if (trackPoints.isEmpty) return;

    final latLngs = <LatLng>[];
    for (final point in trackPoints) {
      final lat = double.tryParse(point['latitude']?.toString() ?? '');
      final lng = double.tryParse(point['longitude']?.toString() ?? '');
      if (lat != null && lng != null) {
        latLngs.add(LatLng(lat, lng));
      }
    }

    if (latLngs.isEmpty) return;

    if (latLngs.length == 1) {
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(latLngs.first, 15),
      );
      return;
    }

    double minLat = latLngs.first.latitude;
    double maxLat = latLngs.first.latitude;
    double minLng = latLngs.first.longitude;
    double maxLng = latLngs.first.longitude;

    for (final ll in latLngs) {
      if (ll.latitude < minLat) minLat = ll.latitude;
      if (ll.latitude > maxLat) maxLat = ll.latitude;
      if (ll.longitude < minLng) minLng = ll.longitude;
      if (ll.longitude > maxLng) maxLng = ll.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final empState = ref.watch(employeeProvider);

    // When track data loads, fit map bounds.
    ref.listen<EmployeeState>(employeeProvider, (prev, next) {
      if (next.trackPoints.isNotEmpty &&
          prev?.trackPoints != next.trackPoints) {
        _fitBounds(next.trackPoints);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Employee Tracking',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Employee selector
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: DropdownButtonFormField<String>(
              value: _selectedEmployeeId,
              decoration: InputDecoration(
                hintText: 'Select Employee',
                hintStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(LucideIcons.user, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              items: empState.employees.map((emp) {
                return DropdownMenuItem<String>(
                  value: emp['employee_id']?.toString(),
                  child: Text(
                    emp['employee_name']?.toString() ?? 'Unknown',
                    style: const TextStyle(
                        fontFamily: 'DM Sans', fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: _onEmployeeSelected,
            ),
          ),

          // Map or empty state
          Expanded(
            child: _selectedEmployeeId == null
                ? _buildEmptyState()
                : _buildMap(empState),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(LucideIcons.mapPin,
                size: 36, color: AppColors.success),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track Employees',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select an employee to view their location',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(EmployeeState empState) {
    final emp = empState.employees.firstWhere(
      (e) => e['employee_id']?.toString() == _selectedEmployeeId,
      orElse: () => <String, dynamic>{},
    );
    final name = emp['employee_name']?.toString() ?? 'Employee';
    final trackPoints = empState.trackPoints;
    final isLoadingTrack = empState.isLoadingTrack;

    final markers = _buildMarkers(trackPoints);
    final polylines = _buildPolylines(trackPoints);

    // Determine initial camera position.
    LatLng initialPos = _defaultCenter;
    if (trackPoints.isNotEmpty) {
      final first = trackPoints.first;
      final lat = double.tryParse(first['latitude']?.toString() ?? '');
      final lng = double.tryParse(first['longitude']?.toString() ?? '');
      if (lat != null && lng != null) {
        initialPos = LatLng(lat, lng);
      }
    }

    final lastTimestamp = trackPoints.isNotEmpty
        ? trackPoints.last['timestamp']?.toString() ?? ''
        : '';

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPos,
            zoom: 13,
          ),
          onMapCreated: (controller) {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
          markers: markers,
          polylines: polylines,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
        ),

        // Loading overlay
        if (isLoadingTrack)
          Container(
            color: Colors.white.withValues(alpha: 0.6),
            child: const Center(child: CircularProgressIndicator()),
          ),

        // No data overlay
        if (!isLoadingTrack && trackPoints.isEmpty)
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.mapPinOff,
                      size: 32, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'No tracking data available',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No location records found for $name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Employee info card at bottom
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: trackPoints.isNotEmpty
                                  ? AppColors.success
                                  : AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              lastTimestamp.isNotEmpty
                                  ? 'Last seen: $lastTimestamp'
                                  : 'Awaiting location data',
                              style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (trackPoints.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${trackPoints.length} location point${trackPoints.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: isLoadingTrack ? null : _refreshTrack,
                    icon: Icon(
                      LucideIcons.refreshCw,
                      size: 16,
                      color: isLoadingTrack
                          ? AppColors.textMuted
                          : AppColors.primary,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
