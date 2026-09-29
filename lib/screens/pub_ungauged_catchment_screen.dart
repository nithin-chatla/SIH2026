import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../models/catchment_model.dart';
import '../theme/app_colors.dart';

class PubUngaugedCatchmentScreen extends StatefulWidget {
  const PubUngaugedCatchmentScreen({super.key});

  @override
  State<PubUngaugedCatchmentScreen> createState() => _PubUngaugedCatchmentScreenState();
}

class _PubUngaugedCatchmentScreenState extends State<PubUngaugedCatchmentScreen> {
  int _selectedTab = 1; // 0 = Monitored (CAT-01), 1 = Ungauged (CAT-02)

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final catchments = service.catchments;
    final monitoredCatchment = catchments.firstWhere((c) => c.isGauged, orElse: () => catchments.first);
    final ungaugedCatchment = catchments.firstWhere((c) => !c.isGauged, orElse: () => catchments.last);
    final activeCatchment = _selectedTab == 0 ? monitoredCatchment : ungaugedCatchment;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PUB — Prediction in Ungauged Basins',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            Text(
              'Hydrological Knowledge Transfer for Data-Sparse Mountain Catchments',
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
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IAHS Ungauged Basin Regionalization Framework',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E40AF)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Over 85% of Himalayan sub-catchments lack direct river stage or discharge gauge telemetry. FLUVIA transfers non-linear rainfall-runoff parameters from instrumented donor basins to ungauged targets using hydro-geomorphic similarity and regionalized unit hydrographs.',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1E3A8A), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Catchment Type Selector (Monitored vs Ungauged)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSelectorTab(
                      title: 'Monitored Donor Catchment',
                      subtitle: 'Gauged Basin (CAT-01: Upper Alaknanda)',
                      icon: Icons.sensors,
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildSelectorTab(
                      title: 'Ungauged Target Catchment',
                      subtitle: 'Data-Sparse PUB Basin (CAT-02: Helang)',
                      icon: Icons.alt_route_rounded,
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual Knowledge Transfer Flowchart
            _buildKnowledgeTransferFlowchart(monitoredCatchment, ungaugedCatchment),
            const SizedBox(height: 16),

            // Active Catchment Geomorphic Profile & PUB Status
            _buildCatchmentPubCard(activeCatchment),
            const SizedBox(height: 16),

            // Side-by-Side Geomorphic Fingerprint Matrix
            _buildGeomorphicComparisonMatrix(monitoredCatchment, ungaugedCatchment),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTab({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: const Color(0xFFCBD5E1)) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
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

  Widget _buildKnowledgeTransferFlowchart(CatchmentBasin donor, CatchmentBasin ungauged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_outlined, size: 18, color: Color(0xFF0284C7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PUB Hydrological Knowledge Transfer Architecture',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3-Block Flow Diagram
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              return isNarrow
                  ? Column(
                      children: [
                        _buildFlowBlock(
                          title: '1. MONITORED DONOR BASIN',
                          tag: 'GAUGED [CAT-01]',
                          tagColor: const Color(0xFF16A34A),
                          points: [
                            'In-situ stage/discharge telemetry',
                            'Calibrated rainfall-runoff curves',
                            'Known unit hydrograph response',
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Icon(Icons.arrow_downward_rounded, color: Color(0xFF94A3B8)),
                        ),
                        _buildFlowBlock(
                          title: '2. GEOMORPHIC TRANSFER ENGINE',
                          tag: '86% HYDRO-SIMILARITY',
                          tagColor: const Color(0xFF0284C7),
                          points: [
                            'Hypsometric curve & slope matching',
                            'Drainage density & soil CN scaling',
                            'Spatial lag time regionalization',
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Icon(Icons.arrow_downward_rounded, color: Color(0xFF94A3B8)),
                        ),
                        _buildFlowBlock(
                          title: '3. UNGAUGED TARGET BASIN',
                          tag: 'PUB ESTIMATE [CAT-02]',
                          tagColor: const Color(0xFFDC2626),
                          points: [
                            'Discharge observation: Unavailable',
                            'Local DEM + Doppler rainfall forcing',
                            'Derived flood risk & peak lead time',
                          ],
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildFlowBlock(
                            title: '1. MONITORED DONOR',
                            tag: 'GAUGED [CAT-01]',
                            tagColor: const Color(0xFF16A34A),
                            points: [
                              'Stage/discharge telemetry',
                              'Calibrated hydrograph',
                              'Known runoff lag time',
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 40),
                          child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8), size: 20),
                        ),
                        Expanded(
                          child: _buildFlowBlock(
                            title: '2. TRANSFER ENGINE',
                            tag: '86% SIMILARITY',
                            tagColor: const Color(0xFF0284C7),
                            points: [
                              'Hypsometric matching',
                              'Drainage density scaling',
                              'Regionalized parameters',
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 40),
                          child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8), size: 20),
                        ),
                        Expanded(
                          child: _buildFlowBlock(
                            title: '3. UNGAUGED TARGET',
                            tag: 'PUB ESTIMATE [CAT-02]',
                            tagColor: const Color(0xFFDC2626),
                            points: [
                              'Gauge: Unavailable',
                              'Local DEM + Rainfall',
                              'Derived peak surge & risk',
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlowBlock({
    required String title,
    required String tag,
    required Color tagColor,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: tagColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    Expanded(
                      child: Text(
                        p,
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCatchmentPubCard(CatchmentBasin catchment) {
    final bool isUngauged = !catchment.isGauged;
    final fg = catchment.geomorphicFingerprint;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUngauged ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUngauged ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isUngauged ? 'PUB UNGAUGED BASIN' : 'DIRECTLY GAUGED BASIN',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isUngauged ? const Color(0xFFB45309) : const Color(0xFF15803D),
                  ),
                ),
              ),
              Text(
                'Catchment ID: ${catchment.id}',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            catchment.name,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          ),
          Text(
            'River System: ${catchment.riverSystem}',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Ungauged Disclaimer & PUB Mechanism
          if (isUngauged && catchment.pubMetadata != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          catchment.pubMetadata!.localDischargeStatus,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Prediction Model: ${catchment.pubMetadata!.transferMechanism}',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF78350F)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    catchment.pubMetadata!.justification,
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF92400E)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Key Geomorphic Parameters Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 550 ? 3 : 2;
              final ratio = constraints.maxWidth >= 550 ? 2.4 : (constraints.maxWidth < 360 ? 1.4 : 1.8);
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: ratio,
                children: [
                  _buildParamTile('Catchment Area', '${catchment.areaSqKm} km²'),
                  _buildParamTile('Mean Elevation', '${catchment.meanElevationMeters.toInt()} m'),
                  _buildParamTile('Mean Slope', '${catchment.meanSlopeDegrees.toStringAsFixed(1)}°'),
                  _buildParamTile('Relief Ratio', '${fg.reliefMeters.toInt()} m'),
                  _buildParamTile('Drainage Density', '${fg.drainageDensityKmPerKm2} km/km²'),
                  _buildParamTile('Concentration Time', '${fg.timeOfConcentrationHours} hrs'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParamTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildGeomorphicComparisonMatrix(CatchmentBasin monitored, CatchmentBasin ungauged) {
    final mFg = monitored.geomorphicFingerprint;
    final uFg = ungauged.geomorphicFingerprint;

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
          Text(
            'Geomorphic Fingerprint & Transfer Compatibility Matrix',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 480),
              child: Table(
                border: TableBorder.all(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(8)),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                    children: [
                      _buildTableCell('Geomorphic Feature', isHeader: true),
                      _buildTableCell('Gauged Donor (CAT-01)', isHeader: true),
                      _buildTableCell('Ungauged Target (CAT-02)', isHeader: true),
                      _buildTableCell('Transfer Match', isHeader: true),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Topographic Slope'),
                      _buildTableCell('${monitored.meanSlopeDegrees}°'),
                      _buildTableCell('${ungauged.meanSlopeDegrees}°'),
                      _buildTableCell('89% High Match', tagColor: const Color(0xFF16A34A)),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Drainage Density'),
                      _buildTableCell('${mFg.drainageDensityKmPerKm2} km/km²'),
                      _buildTableCell('${uFg.drainageDensityKmPerKm2} km/km²'),
                      _buildTableCell('82% Matched', tagColor: const Color(0xFF16A34A)),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Hypsometric Index'),
                      _buildTableCell('${mFg.hypsometricIntegral}'),
                      _buildTableCell('${uFg.hypsometricIntegral}'),
                      _buildTableCell('91% High Match', tagColor: const Color(0xFF16A34A)),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Soil Hydrologic Group'),
                      _buildTableCell('Group B (Sandy Loam)'),
                      _buildTableCell('Group B/C (Colluvium)'),
                      _buildTableCell('Compatible', tagColor: const Color(0xFF0284C7)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? tagColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: tagColor != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: tagColor.withAlpha(20), borderRadius: BorderRadius.circular(4)),
              child: Text(
                text,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: tagColor),
              ),
            )
          : Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                color: isHeader ? const Color(0xFF0F172A) : const Color(0xFF334155),
              ),
            ),
    );
  }
}
