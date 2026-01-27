/// Map Location Picker Screen - Select location on map
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../cubit/map_location_cubit.dart';
import '../cubit/map_location_state.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Marker? _marker;
  MapLocationCubit? _cubit;
  LatLng? _lastUpdatedPosition;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) {
        final cubit = MapLocationCubit();
        cubit.initialize(
          initialLatitude: widget.initialLatitude,
          initialLongitude: widget.initialLongitude,
        );
        _cubit = cubit; // Save reference immediately
        return cubit;
      },
      child: Builder(
        builder: (builderContext) {
          // Ensure cubit reference is set
          _cubit ??= builderContext.read<MapLocationCubit>();
          return Scaffold(
            appBar: AppBar(
              title: const Text('تحديد الموقع على الخريطة'),
              actions: [
                IconButton(
                  icon: const Icon(Iconsax.location),
                  onPressed: () {
                    _cubit?.getCurrentLocation();
                  },
                  tooltip: 'الموقع الحالي',
                ),
              ],
            ),
            body: BlocConsumer<MapLocationCubit, MapLocationState>(
              listener: (context, state) {
                // Only update marker if coordinates actually changed
                if (state.status == MapLocationStatus.success &&
                    state.hasCoordinates) {
                  final newPosition = LatLng(state.latitude!, state.longitude!);

                  // Check if position actually changed to avoid unnecessary updates
                  if (_lastUpdatedPosition == null ||
                      (_lastUpdatedPosition!.latitude != newPosition.latitude ||
                          _lastUpdatedPosition!.longitude !=
                              newPosition.longitude)) {
                    _lastUpdatedPosition = newPosition;
                    _updateMarker(newPosition);

                    // Only move camera on initial load or when explicitly requested
                    if (_mapController != null && _marker == null) {
                      _moveCameraToLocation(newPosition);
                    }
                  }
                }

                if (state.status == MapLocationStatus.error &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    // Google Map
                    _buildMap(state, isDark),

                    // Search Bar
                    _buildSearchBar(state, isDark),

                    // Loading Overlay
                    if (state.status == MapLocationStatus.locationLoading ||
                        state.status == MapLocationStatus.geocodingLoading)
                      _buildLoadingOverlay(),

                    // Address Card
                    if (state.hasAddress &&
                        state.status == MapLocationStatus.success)
                      _buildAddressCard(state, isDark),

                    // Confirm Button
                    _buildConfirmButton(state, isDark, builderContext),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMap(MapLocationState state, bool isDark) {
    final initialPosition = state.hasCoordinates
        ? LatLng(state.latitude!, state.longitude!)
        : const LatLng(24.7136, 46.6753); // Default to Riyadh

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        if (state.hasCoordinates) {
          _updateMarker(initialPosition);
        }
      },
      onTap: (LatLng position) {
        _cubit?.updateLocation(position.latitude, position.longitude);
      },
      onCameraIdle: () {
        // When camera stops moving, update location from camera center
        if (mounted && _mapController != null) {
          _mapController!
              .getVisibleRegion()
              .then((bounds) {
                // Get center of visible region
                final center = LatLng(
                  (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                  (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
                );

                // Only update if position actually changed
                if (_lastUpdatedPosition == null ||
                    (_lastUpdatedPosition!.latitude != center.latitude ||
                        _lastUpdatedPosition!.longitude != center.longitude)) {
                  _lastUpdatedPosition = center;
                  _updateMarker(center);
                  _cubit?.updateLocation(center.latitude, center.longitude);
                }
              })
              .catchError((_) {
                // Fallback: use marker position if available
                if (_marker != null) {
                  final position = _marker!.position;
                  if (_lastUpdatedPosition == null ||
                      (_lastUpdatedPosition!.latitude != position.latitude ||
                          _lastUpdatedPosition!.longitude !=
                              position.longitude)) {
                    _lastUpdatedPosition = position;
                    _cubit?.updateLocation(
                      position.latitude,
                      position.longitude,
                    );
                  }
                }
              });
        }
      },
      markers: _marker != null ? {_marker!} : {},
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
    );
  }

  Widget _buildSearchBar(MapLocationState state, bool isDark) {
    return Positioned(
      top: 16.h,
      left: 16.w,
      right: 16.w,
      child: Column(
        children: [
          // Search TextField
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن عنوان...',
                prefixIcon: Icon(Iconsax.search_normal, size: 20.sp),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Iconsax.close_circle, size: 20.sp),
                        onPressed: () {
                          _searchController.clear();
                          _cubit?.clearSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _cubit?.searchAddress(value);
                } else {
                  _cubit?.clearSearch();
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _cubit?.searchAddress(value);
                }
              },
            ),
          ),

          // Search Results
          if (state.isSearching || state.searchResults.isNotEmpty)
            _buildSearchResults(state, isDark),
        ],
      ),
    );
  }

  Widget _buildSearchResults(MapLocationState state, bool isDark) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: state.isSearching
          ? Padding(
              padding: EdgeInsets.all(16.w),
              child: const Center(child: CircularProgressIndicator()),
            )
          : state.searchResults.isEmpty
          ? Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'لا توجد نتائج',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: state.searchResults.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              itemBuilder: (context, index) {
                final result = state.searchResults[index];
                return ListTile(
                  leading: Icon(
                    Iconsax.location,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  title: Text(
                    result.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  onTap: () {
                    _searchController.text = result.description;
                    _cubit?.selectSearchResult(result);
                  },
                );
              },
            ),
    );
  }

  Widget _buildAddressCard(MapLocationState state, bool isDark) {
    return Positioned(
      bottom: 100.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Iconsax.location, color: AppColors.primary, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'العنوان المحدد',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    state.formattedAddress ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(
    MapLocationState state,
    bool isDark,
    BuildContext context,
  ) {
    return Positioned(
      bottom: 16.h,
      left: 16.w,
      right: 16.w,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: state.hasCoordinates
              ? () {
                  Navigator.of(context).pop({
                    'latitude': state.latitude,
                    'longitude': state.longitude,
                    'address': state.formattedAddress,
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.textTertiaryLight,
          ),
          child: Text(
            'تأكيد الموقع',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _marker = Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onDragEnd: (LatLng newPosition) {
          if (mounted) {
            _cubit?.updateLocation(newPosition.latitude, newPosition.longitude);
          }
        },
      );
    });
  }

  Future<void> _moveCameraToLocation(LatLng position) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15.0),
      );
    }
  }
}
