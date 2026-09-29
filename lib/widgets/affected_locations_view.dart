import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../models/ward_risk.dart';
import '../theme/app_colors.dart';

class AffectedLocationsView extends StatelessWidget {
  const AffectedLocationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final catchment = service.selectedCatchment ?? (service.catchments.isNotEmpty ? service.catchments.first : null);
    final wards = service.wards;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_tree_outlined, color: Color(0xFF0284C7), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Downstream Risk Localization & Asset Hierarchy',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Catchment ➔ Flow Network ➔ Downstream Villages ➔ Roads & Bridges',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ASSET HIERARCHY',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),

            ],
          ),

          const SizedBox(height: 14),

          // Flow Network Hierarchy Tree
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHierarchyNode(
                  icon: Icons.terrain_rounded,
                  color: const Color(0xFF0284C7),
                  title: 'HEADWATER CATCHMENT',
                  name: catchment?.name ?? 'Alaknanda Upper Catchment (CAT-01)',
                  meta: 'Drainage Area: ${catchment?.areaSqKm ?? 342.5} km² • Mean Slope: ${catchment?.meanSlopeDegrees ?? 38.4}°',
                  isFirst: true,
                ),
                _buildHierarchyNode(
                  icon: Icons.water_rounded,
                  color: const Color(0xFF0284C7),
                  title: 'STREAM FLOW NETWORK',
                  name: 'Rishi Ganga ➔ Dhauli Ganga ➔ Alaknanda Main Stem (Order 4)',
                  meta: 'Stream Length: 24.8 km • Kinematic Lag: 45 mins',
                ),
                _buildHierarchyNode(
                  icon: Icons.location_city_rounded,
                  color: const Color(0xFFDC2626),
                  title: 'EXPOSED SETTLEMENTS & WARDS',
                  name: '${wards.length} Downstream Population Clusters (${service.totalAtRiskPopulation} Residents)',
                  meta: 'Critical Alerts: ${service.criticalWardsCount} • Warnings: ${service.warningWardsCount}',
                ),
                _buildHierarchyNode(
                  icon: Icons.alt_route_rounded,
                  color: const Color(0xFFEA580C),
                  title: 'CRITICAL INFRASTRUCTURE & LIFELINES',
                  name: '12 Bridges, 2 High-Pass Highways, 4 Emergency Camps, 2 Hospitals',
                  meta: 'Vulnerability Score: 78.4/100 (Submersion & Debris Risk)',
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Detailed List of Affected Downstream Assets
          Text(
            'AFFECTED DOWNSTREAM LOCATIONS & INFRASTRUCTURE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          ...wards.map((w) => _buildAffectedWardCard(w)),

          const SizedBox(height: 10),

          // Scientific & Modeling Disclaimer
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFB45309), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Scientific Disclaimer: Downstream affected locations are mapped based on DEM flow-path connectivity, geomorphic proximity, and stream order lag. True sub-meter inundation boundaries require dynamic 2D hydrodynamic modeling (e.g. HEC-RAS / TELEMAC).',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF92400E),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyNode({
    required IconData icon,
    required Color color,
    required String title,
    required String name,
    required String meta,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
                border: Border.all(color: color.withAlpha(120)),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: const Color(0xFFCBD5E1),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: color),
                ),
                Text(
                  name,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                ),
                Text(
                  meta,
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAffectedWardCard(WardRisk ward) {
    final Color riskColor = AppColors.getRiskColor(ward.alertLevel.name);
    final Color riskBg = AppColors.getRiskBg(ward.alertLevel.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: riskBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ward.alertLevel.name.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: riskColor),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ward.name,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${ward.riskScore.toStringAsFixed(0)}% Risk',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: riskColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.alt_route, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Catchment Rel: Confluence zone • Elev: ${ward.elevationMeters.toInt()}m • Lead Time: ${ward.evacuationLeadTimeMinutes}m',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Evidence: ${ward.actionAdvisory}',
            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF475569), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
