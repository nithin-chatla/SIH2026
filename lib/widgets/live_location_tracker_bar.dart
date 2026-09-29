import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../services/disaster_data_service.dart';
import '../theme/app_colors.dart';

class LiveLocationTrackerBar extends StatelessWidget {
  const LiveLocationTrackerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final user = service.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          // Live GPS Icon & Coordinates
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.safeGreen),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE GPS TRACKING ACTIVE',
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.safeGreen, letterSpacing: 0.4),
                    ),
                  ],
                ),
                Text(
                  '${user.currentWardName} (${user.currentCoordinates.latitude.toStringAsFixed(4)}°N, ${user.currentCoordinates.longitude.toStringAsFixed(4)}°E)',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Travel Simulation Dropdown
          PopupMenuButton<Map<String, dynamic>>(
            tooltip: 'Simulate User Movement Between Wards',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.alt_route_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Change Location', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
            onSelected: (loc) {
              service.updateLiveLocation(
                loc['coord'] as LatLng,
                loc['wardId'] as String,
                loc['wardName'] as String,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Simulated movement: User relocated to ${loc['wardName']}'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: {
                  'coord': const LatLng(30.5470, 79.5520),
                  'wardId': 'W-02',
                  'wardName': 'Alaknanda Riverfront (Hazard Zone)',
                },
                child: Row(
                  children: [
                    const Icon(Icons.water, size: 16, color: AppColors.criticalRed),
                    const SizedBox(width: 8),
                    Text('Alaknanda Riverfront (High Risk)', style: GoogleFonts.inter(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: {
                  'coord': const LatLng(30.5583, 79.5668),
                  'wardId': 'W-01',
                  'wardName': 'Joshimath Upper Ward (Sector 4)',
                },
                child: Row(
                  children: [
                    const Icon(Icons.terrain, size: 16, color: AppColors.warningOrange),
                    const SizedBox(width: 8),
                    Text('Joshimath Upper Ward', style: GoogleFonts.inter(fontSize: 12)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: {
                  'coord': const LatLng(30.5310, 79.5710),
                  'wardId': 'W-04',
                  'wardName': 'Auli High Haven (Safe Refuge)',
                },
                child: Row(
                  children: [
                    const Icon(Icons.shield, size: 16, color: AppColors.safeGreen),
                    const SizedBox(width: 8),
                    Text('Auli High Haven (Safe Ground)', style: GoogleFonts.inter(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
