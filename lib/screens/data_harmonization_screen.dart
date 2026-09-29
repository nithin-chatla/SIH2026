import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../models/catchment_model.dart';
import '../theme/app_colors.dart';

class DataHarmonizationScreen extends StatelessWidget {
  const DataHarmonizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final steps = service.dataHarmonizationSteps;
    final sources = service.dataSources;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Multi-Source Data Harmonization',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            Text(
              'Spatial & Temporal Integration of Heterogeneous Environmental Datasets',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Scientific Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multi-Source Spatial & Temporal Harmonization Pipeline',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF15803D)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'FLUVIA harmonizes coarse satellite grids (10km), high-resolution elevation models (30m), and point IoT telemetry into hydrologically aligned catchment forcing without inventing fictitious micro-scale downscaling.',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF166534), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual Pipeline Step Cards
            Text(
              'Hydrological Feature Harmonization Pipeline',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            ...steps.map((step) => _buildHarmonizationCard(step)),
            const SizedBox(height: 16),

            // Comprehensive Multi-Source Data Quality Audit Table
            _buildDataQualityAuditSection(sources),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHarmonizationCard(DataHarmonizationStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                step.sourceName,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LATENCY: ${step.latency.toUpperCase()}',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF15803D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Transformation Flow (Raw -> Spatial/Temporal -> Final Hydrological Feature)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                _buildFlowRow('Raw Resolution:', step.rawResolution, Icons.grid_view_rounded),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF94A3B8)),
                ),
                _buildFlowRow('Spatial Transformation:', step.spatialTransformation, Icons.transform_rounded),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF94A3B8)),
                ),
                _buildFlowRow('Final Hydro Feature:', step.finalHydrologicalFeature, Icons.check_circle_rounded, highlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowRow(String label, String value, IconData icon, {bool highlight = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 280;
        if (isCompact) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: highlight ? const Color(0xFF0284C7) : const Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                          color: highlight ? const Color(0xFF0284C7) : const Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                    color: highlight ? const Color(0xFF0F172A) : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: highlight ? const Color(0xFF0284C7) : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                  color: highlight ? const Color(0xFF0284C7) : const Color(0xFF475569),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  color: highlight ? const Color(0xFF0F172A) : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataQualityAuditSection(List<SystemDataSource> sources) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, size: 18, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data Quality & Health Matrix',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sources.map((src) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              src.category,
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF0284C7)),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: src.status == DataQualityStatus.good
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                src.status == DataQualityStatus.good ? 'HEALTHY' : 'DEGRADED',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: src.status == DataQualityStatus.good
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        src.providerName,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Cadence: ${src.updateCadence} • Last Received: ${src.lastObservedTimestamp}',
                        style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${src.scientificRole}',
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
