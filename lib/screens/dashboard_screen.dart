import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/disaster_data_service.dart';
import '../models/ward_risk.dart';
import '../theme/app_colors.dart';
import '../widgets/risk_gauge_meter.dart';
import '../widgets/lead_time_counter.dart';
import '../widgets/sensor_telemetry_card.dart';
import '../widgets/alert_banner.dart';
import '../widgets/simulation_control_panel.dart';
import '../widgets/weather_radar_card.dart';
import '../widgets/end_to_end_demo_wizard.dart';
import '../widgets/affected_locations_view.dart';
import '../widgets/fluvia_sensing_matrix_card.dart';



class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final selectedWard = service.selectedWard;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;
    final isMobile = screenWidth < 600;
    final String currentDate = DateFormat('EEE, d MMM yyyy • HH:mm').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Clean minimal SliverAppBar
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            titleSpacing: 12,
            surfaceTintColor: Colors.transparent,
            backgroundColor: AppColors.surface,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.water_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  isMobile ? 'Dashboard' : 'Operational Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            actions: [
              // Region Selector
              Container(
                margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: service.selectedRegion,
                    dropdownColor: Colors.white,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(
                        value: 'Uttarakhand & Himalayas',
                        child: Text('Chamoli'),
                      ),
                      DropdownMenuItem(
                        value: 'Western Ghats (Wayanad/Idukki)',
                        child: Text('Wayanad'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) service.setRegion(val);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 22, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // End-to-End FLUVIA Demo Wizard Bar (Authority / Operations only)
                  if (service.isDemoWizardActive)
                    const EndToEndDemoWizard()
                  else if (service.isAuthority)
                    _buildPipelineBanner(service),

                  // Live Status Bar
                  _buildStatusBar(currentDate, isMobile),
                  const SizedBox(height: 16),

                  // KPI Cards
                  _buildKpiSummary(context, service),
                  const SizedBox(height: 18),

                  // Active Disaster Bulletins
                  if (service.activeAlerts.isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.emergency_outlined,
                      iconColor: AppColors.criticalRed,
                      title: 'Active Early Warning Bulletins',
                    ),
                    const SizedBox(height: 10),
                    ...service.activeAlerts.map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AlertBanner(alert: alert),
                    )),
                    const SizedBox(height: 16),
                  ],

                  // Responsive Layout: 2 Columns on Web, 1 Column on Mobile
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWardCard(context, service, selectedWard, isMobile),
                              const SizedBox(height: 18),
                              const FluviaSensingMatrixCard(),
                              const SizedBox(height: 18),
                              const AffectedLocationsView(),
                              if (service.isAuthority) ...[
                                const SizedBox(height: 18),
                                const SimulationControlPanel(),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const WeatherRadarCard(),
                              const SizedBox(height: 18),
                              _buildTelemetryFeed(context, service),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildWardCard(context, service, selectedWard, isMobile),
                    const SizedBox(height: 18),
                    const FluviaSensingMatrixCard(),
                    const SizedBox(height: 18),
                    const AffectedLocationsView(),
                    if (service.isAuthority) ...[
                      const SizedBox(height: 18),
                      const SimulationControlPanel(),
                    ],
                    const SizedBox(height: 18),
                    const WeatherRadarCard(),
                    const SizedBox(height: 18),
                    _buildTelemetryFeed(context, service),
                  ],

                  const SizedBox(height: 24),
                  _buildQuickAccessSection(context, isMobile),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PIPELINE BANNER
  // ─────────────────────────────────────────────────────────────
  Widget _buildPipelineBanner(DisasterDataService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1120).withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FLUVIA Live Operational Pipeline',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SENSE → HARMONIZE → MODEL → PREDICT → LOCALIZE → VERIFY → ALERT → ACT',
                          style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF94A3B8), letterSpacing: 0.3),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => service.startDemoWizard(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 16),
                      label: Text('RUN WORKFLOW', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ],
              ),
              if (isNarrow) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => service.startDemoWizard(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                    label: Text('RUN WORKFLOW', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STATUS BAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildStatusBar(String currentDate, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppColors.premiumCardDecoration,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              Text(
                isMobile ? 'Live • IST' : currentDate,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.safeGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.safeGreen.withAlpha(80),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isMobile ? 'Systems Online' : 'IoT Telemetry Active • All Systems Online',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.safeGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION HEADER
  // ─────────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // KPI SUMMARY
  // ─────────────────────────────────────────────────────────────
  Widget _buildKpiSummary(BuildContext context, DisasterDataService service) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 700 ? 4 : 2;
        final double aspectRatio = width > 700
            ? 2.4
            : width > 380
                ? 1.55
                : 1.35;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: aspectRatio,
          children: [
            _buildKpiCard(
              title: 'Critical Wards',
              value: '${service.criticalWardsCount}',
              statusText: 'Evacuation required',
              color: AppColors.criticalRed,
              icon: Icons.warning_amber_rounded,
            ),
            _buildKpiCard(
              title: 'Warning Stage',
              value: '${service.warningWardsCount}',
              statusText: 'Pre-alert monitoring',
              color: AppColors.warningOrange,
              icon: Icons.shield_outlined,
            ),
            _buildKpiCard(
              title: 'Population at Risk',
              value: '${service.totalAtRiskPopulation}',
              statusText: 'In Red/Orange zones',
              color: AppColors.primary,
              icon: Icons.people_outline,
            ),
            _buildKpiCard(
              title: 'IoT Sensor Mesh',
              value: '${service.sensors.length} Nodes',
              statusText: 'All telemetry online',
              color: AppColors.safeGreen,
              icon: Icons.sensors,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String statusText,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // WARD CARD
  // ─────────────────────────────────────────────────────────────
  Widget _buildWardCard(
    BuildContext context,
    DisasterDataService service,
    WardRisk? ward,
    bool isMobile,
  ) {
    if (ward == null) return const SizedBox.shrink();

    final Color riskColor = AppColors.getRiskColor(ward.alertLevel.name);
    final Color riskBg = AppColors.getRiskBg(ward.alertLevel.name);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppColors.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: riskColor.withAlpha(40)),
                          ),
                          child: Text(
                            ward.alertLevel.name.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: riskColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Text(
                          '${ward.district} • ${ward.elevationMeters.toInt()}m',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ward.name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Ward Selector
              PopupMenuButton<WardRisk>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.unfold_more_rounded, color: AppColors.textSecondary, size: 18),
                ),
                tooltip: 'Select Village/Ward',
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (w) => service.selectWard(w),
                itemBuilder: (context) => service.wards.map((w) {
                  final c = AppColors.getRiskColor(w.alertLevel.name);
                  return PopupMenuItem(
                    value: w,
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(w.name, style: GoogleFonts.inter(fontSize: 12))),
                        Text('${w.riskScore.toInt()}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gauge + Lead Time
          if (isMobile)
            Column(
              children: [
                RiskGaugeMeter(score: ward.riskScore, size: 120),
                const SizedBox(height: 14),
                LeadTimeCounter(
                  leadTimeMinutes: ward.evacuationLeadTimeMinutes,
                  wardName: ward.name,
                ),
              ],
            )
          else
            Row(
              children: [
                RiskGaugeMeter(score: ward.riskScore, size: 120),
                const SizedBox(width: 16),
                Expanded(
                  child: LeadTimeCounter(
                    leadTimeMinutes: ward.evacuationLeadTimeMinutes,
                    wardName: ward.name,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // 4 Key Hydrological Metrics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildMetricItem('Rain Rate', '${ward.rainfall1hMm.toStringAsFixed(1)} mm/h')),
                Expanded(child: _buildMetricItem('Soil Sat.', '${ward.soilSaturationPercent.toStringAsFixed(0)}%')),
                Expanded(child: _buildMetricItem('Slope FoS', ward.factorOfSafety.toStringAsFixed(2))),
                Expanded(child: _buildMetricItem('Flood Risk', '${ward.floodProbability.toStringAsFixed(0)}%')),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Rainfall Intervals
          _buildRainfallIntervalsCard(service, ward),
          const SizedBox(height: 14),

          // Multi-Horizon Predictions
          _buildMultiHorizonPredictionsCard(ward),
          const SizedBox(height: 14),

          // Evidence-Based Explainability
          if (ward.evidence != null) ...[
            _buildExplainabilityCard(ward.evidence!),
            const SizedBox(height: 14),
          ],

          Text(
            ward.actionAdvisory,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => onNavigateTab(1),
                icon: const Icon(Icons.map_outlined, size: 16),
                label: const Text('View GIS Map'),
              ),
              if (ward.alertLevel == AlertLevel.critical || ward.alertLevel == AlertLevel.warning)
                ElevatedButton.icon(
                  onPressed: () => service.triggerWardSiren(ward.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.criticalRed,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.volume_up_outlined, size: 16),
                  label: Text(ward.sirenStatus == 'ACTIVE_BROADCAST' ? 'Siren Active' : 'Sound Siren'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // RAINFALL INTERVALS
  // ─────────────────────────────────────────────────────────────
  Widget _buildRainfallIntervalsCard(DisasterDataService service, WardRisk ward) {
    final rf = service.getRainfallBreakdownForWard(ward.id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.rainBlue.withAlpha(15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.water_drop_outlined, size: 13, color: AppColors.rainBlue),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Rainfall Accumulation',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.rainBlue.withAlpha(15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'API-7: ${rf['api7']?.toInt()}mm',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.rainBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 260),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubMetric('15-Min', '${rf['15m']}mm'),
                  const SizedBox(width: 10),
                  _buildSubMetric('1-Hour', '${rf['1h']}mm'),
                  const SizedBox(width: 10),
                  _buildSubMetric('3-Hour', '${rf['3h']}mm'),
                  const SizedBox(width: 10),
                  _buildSubMetric('6-Hour', '${rf['6h']}mm'),
                  const SizedBox(width: 10),
                  _buildSubMetric('24-Hour', '${rf['24h']}mm'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MULTI-HORIZON PREDICTIONS
  // ─────────────────────────────────────────────────────────────
  Widget _buildMultiHorizonPredictionsCard(WardRisk ward) {
    final horizons = ward.horizonPredictions;
    if (horizons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppColors.premiumCardDecoration.copyWith(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withAlpha(15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.av_timer_rounded, size: 13, color: AppColors.warningOrange),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Multi-Horizon Forecast',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text('HORIZONS', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 260),
              child: Row(
                children: horizons.map((h) {
                  final c = AppColors.getRiskColor(h.alertLevel.name);
                  return Container(
                    width: 66,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.withAlpha(12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.withAlpha(50)),
                    ),
                    child: Column(
                      children: [
                        Text(h.horizon, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: c)),
                        const SizedBox(height: 3),
                        Text('${h.riskScore.toInt()}%', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        Text('${h.forecastRainfallMm}mm', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // EXPLAINABILITY
  // ─────────────────────────────────────────────────────────────
  Widget _buildExplainabilityCard(dynamic evidence) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.psychology_alt_outlined, size: 13, color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Hydrological Explainability: Why is this area at risk?',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.criticalRedBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.criticalRedBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 14, color: AppColors.criticalRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Primary Trigger: ${evidence.dominantTrigger}',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.criticalRed),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '• Mechanism: ${evidence.hydrologicalMechanism}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TELEMETRY FEED
  // ─────────────────────────────────────────────────────────────
  Widget _buildTelemetryFeed(BuildContext context, DisasterDataService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(
              icon: Icons.sensors_outlined,
              iconColor: AppColors.primary,
              title: 'Live Sensor Telemetry',
            ),
            TextButton(
              onPressed: () => onNavigateTab(service.isAuthority ? 2 : 1),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: Text(
                'View All (${service.sensors.length})',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...service.sensors.take(3).map((sensor) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SensorTelemetryCard(
              sensor: sensor,
              onTap: () {
                service.selectSensor(sensor);
                onNavigateTab(service.isAuthority ? 2 : 1);
              },
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // QUICK ACCESS SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildQuickAccessSection(BuildContext context, bool isMobile) {
    final service = context.watch<DisasterDataService>();
    final isAuthority = service.isAuthority;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.rocket_launch_outlined,
          iconColor: AppColors.indigo,
          title: 'Quick Disaster Action Hub',
        ),
        const SizedBox(height: 12),
        if (isMobile)
          Column(
            children: [
              _buildActionTile(
                icon: Icons.map_outlined,
                title: 'GIS Hazard Map',
                subtitle: 'Live river surge & satellite radar',
                color: AppColors.primary,
                onTap: () => onNavigateTab(1),
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.navigation_outlined,
                title: isAuthority ? 'Evacuation Shelters' : 'Safe Evacuation Hub',
                subtitle: 'High-ground shelter routes & beds',
                color: AppColors.safeGreen,
                onTap: () => onNavigateTab(isAuthority ? 4 : 2),
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: isAuthority ? Icons.admin_panel_settings_outlined : Icons.add_photo_alternate_outlined,
                title: isAuthority ? 'NDRF Operations Room' : 'Citizen Hazard Report',
                subtitle: isAuthority ? 'Multi-village CAP broadcasts' : 'Crowdsourced field observations',
                color: isAuthority ? AppColors.criticalRed : AppColors.warningOrange,
                onTap: () => onNavigateTab(isAuthority ? 6 : 3),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.map_outlined,
                  title: 'GIS Hazard Map',
                  subtitle: 'Live river surge & radar',
                  color: AppColors.primary,
                  onTap: () => onNavigateTab(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.navigation_outlined,
                  title: isAuthority ? 'Evacuation Shelters' : 'Safe Evacuation Hub',
                  subtitle: 'High-ground shelter routes',
                  color: AppColors.safeGreen,
                  onTap: () => onNavigateTab(isAuthority ? 4 : 2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  icon: isAuthority ? Icons.admin_panel_settings_outlined : Icons.add_photo_alternate_outlined,
                  title: isAuthority ? 'NDRF Operations Room' : 'Citizen Hazard Report',
                  subtitle: isAuthority ? 'Multi-village CAP broadcasts' : 'Crowdsourced reports',
                  color: isAuthority ? AppColors.criticalRed : AppColors.warningOrange,
                  onTap: () => onNavigateTab(isAuthority ? 6 : 3),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppColors.premiumCardDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textMuted.withAlpha(120)),
            ],
          ),
        ),
      ),
    );
  }
}
