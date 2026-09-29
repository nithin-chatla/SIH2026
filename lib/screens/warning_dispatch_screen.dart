import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../models/ward_risk.dart';
import '../theme/app_colors.dart';

class WarningDispatchScreen extends StatefulWidget {
  const WarningDispatchScreen({super.key});

  @override
  State<WarningDispatchScreen> createState() => _WarningDispatchScreenState();
}

class _WarningDispatchScreenState extends State<WarningDispatchScreen> {
  String _selectedTargetWardId = 'W-02';
  AlertLevel _selectedAlertLevel = AlertLevel.critical;
  double _geofenceRadiusKm = 5.0;
  int _leadTimeMinutes = 25;

  final _headlineController = TextEditingController(
    text: 'IMMEDIATE FLASH FLOOD EVACUATION ORDER: ALAKNANDA SECTOR',
  );
  final _problemDetailController = TextEditingController(
    text: 'Extreme upstream cloudburst (>82mm/hr) detected by Doppler radar. River gauge S-301 surged +1.6m above dangerous crest. Debris mudflow reported at Km 14.2 bypass.',
  );
  final _evacRouteController = TextEditingController(
    text: 'Follow Green Corridor Route 1 towards Auli High Ground Shelter (Elev: 2,750m). Avoid riverbank culvert road.',
  );

  bool _isBroadcasting = false;

  @override
  void dispose() {
    _headlineController.dispose();
    _problemDetailController.dispose();
    _evacRouteController.dispose();
    super.dispose();
  }

  void _applyLevelPreset(AlertLevel level) {
    setState(() {
      _selectedAlertLevel = level;
      switch (level) {
        case AlertLevel.critical:
          _headlineController.text = 'MANDATORY EVACUATION: IMMINENT FLASH FLOOD & DEBRIS SURGE';
          _problemDetailController.text = 'River discharge surging rapidly. Ultrasonic gauge crest exceeded danger threshold by +1.4m. Severe torrent imminent.';
          _leadTimeMinutes = 20;
          break;
        case AlertLevel.warning:
          _headlineController.text = 'LEVEL 4 WARNING: PREPARE FOR EVACUATION';
          _problemDetailController.text = 'Continuous high precipitation (>45mm/hr). Slope factor of safety dropped to 1.08. Move vulnerable citizens to relief camps.';
          _leadTimeMinutes = 45;
          break;
        case AlertLevel.alert:
          _headlineController.text = 'LEVEL 3 ALERT: SOIL SATURATION & RUNOFF WATCH';
          _problemDetailController.text = 'Deep soil sensor layers reach 86% saturation. Inclinometers track minor ground creep.';
          _leadTimeMinutes = 90;
          break;
        case AlertLevel.advisory:
          _headlineController.text = 'LEVEL 2 ADVISORY: MONSOON STREAM SWELL';
          _problemDetailController.text = 'Catchment receiving moderate rain. Keep livestock and vehicles away from seasonal stream gullies.';
          _leadTimeMinutes = 180;
          break;
        case AlertLevel.safe:
          _headlineController.text = 'LEVEL 1: NORMAL BASELINE STATUS';
          _problemDetailController.text = 'All telemetry within safe thresholds. IoT sensor network operational.';
          _leadTimeMinutes = 360;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.criticalRedBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cell_tower, color: AppColors.criticalRed, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '5-Level Geo-Warning Dispatch Console',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.satellite_alt_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OFFICIAL COMMON ALERTING PROTOCOL (CAP) BROADCASTER',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dispatches geo-fenced cell broadcasts, acoustic sirens, and instant mobile alerts directly to citizens currently located within the targeted hazard boundary.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 1: Target Location Selector
            Text('STEP 1: SELECT TARGET HAZARD SECTOR & RADIUS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Target Village / River Catchment Ward:',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTargetWardId,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        items: [
                          const DropdownMenuItem(value: 'ALL', child: Text('⚠️ BROADCAST TO ALL REGIONAL WARDS (DISTRICT-WIDE)')),
                          ...service.wards.map((w) {
                            return DropdownMenuItem(
                              value: w.id,
                              child: Text('${w.name} • Pop: ${w.population} (${w.district})', overflow: TextOverflow.ellipsis),
                            );
                          }),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedTargetWardId = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text('Geofence Alert Radius:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      Text('${_geofenceRadiusKm.toStringAsFixed(1)} km Buffer', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _geofenceRadiusKm,
                    min: 1.0,
                    max: 15.0,
                    divisions: 14,
                    onChanged: (v) => setState(() => _geofenceRadiusKm = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 2: 5-Level Warning Selector Cards
            Text('STEP 2: SELECT 5-TIER WARNING LEVEL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            _buildFiveLevelGrid(isMobile),
            const SizedBox(height: 20),

            // Step 3: Specific Problem Details & Instructions
            Text('STEP 3: SPECIFY FIELD CAUSE & EVACUATION ROUTE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alert Headline / Order', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _headlineController,
                    decoration: const InputDecoration(hintText: 'Enter broadcast headline...'),
                  ),
                  const SizedBox(height: 14),
                  Text('Actual Hazard Cause & Sensor Observation', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _problemDetailController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Detail rain rates, river crest, rockslide points, or trapped areas...'),
                  ),
                  const SizedBox(height: 14),
                  Text('Designated Safe Evacuation Corridor', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _evacRouteController,
                    decoration: const InputDecoration(hintText: 'Specify safe high ground route and camps...'),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text('Estimated Evacuation Lead Time:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                      Text('$_leadTimeMinutes mins window', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.criticalRed)),
                    ],
                  ),
                  Slider(
                    value: _leadTimeMinutes.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    onChanged: (v) => setState(() => _leadTimeMinutes = v.toInt()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step 4: Dispatch Execution Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isBroadcasting ? null : () => _executeBroadcast(service),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getRiskColor(_selectedAlertLevel.name),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                icon: Icon(_isBroadcasting ? Icons.hourglass_top : Icons.emergency_share, size: 20),
                label: Text(
                  _isBroadcasting
                      ? 'TRANSMITTING GEO-BROADCAST...'
                      : 'DISPATCH LEVEL ${_getLevelNumber(_selectedAlertLevel)} GEO-ALERT TO CITIZENS',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFiveLevelGrid(bool isMobile) {
    final levels = [
      {'level': AlertLevel.safe, 'num': '1', 'title': 'Level 1: Normal', 'sub': 'Baseline monitoring / Safe', 'color': AppColors.level1Green, 'bg': AppColors.level1GreenBg},
      {'level': AlertLevel.advisory, 'num': '2', 'title': 'Level 2: Advisory', 'sub': 'Stream rise / Squall watch', 'color': AppColors.level2Blue, 'bg': AppColors.level2BlueBg},
      {'level': AlertLevel.alert, 'num': '3', 'title': 'Level 3: Alert', 'sub': 'Soil sat >80% / Slope creep', 'color': AppColors.level3Yellow, 'bg': AppColors.level3YellowBg},
      {'level': AlertLevel.warning, 'num': '4', 'title': 'Level 4: Warning', 'sub': 'Flash flood likely / Prepare evac', 'color': AppColors.level4Orange, 'bg': AppColors.level4OrangeBg},
      {'level': AlertLevel.critical, 'num': '5', 'title': 'Level 5: Critical', 'sub': 'Mandatory evacuation order', 'color': AppColors.level5Red, 'bg': AppColors.level5RedBg},
    ];

    return Column(
      children: levels.map((item) {
        final AlertLevel lvl = item['level'] as AlertLevel;
        final bool isSelected = _selectedAlertLevel == lvl;
        final Color color = item['color'] as Color;
        final Color bg = item['bg'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _applyLevelPreset(lvl),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? bg : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 1))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        item['num'] as String,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? color : AppColors.textPrimary),
                        ),
                        Text(
                          item['sub'] as String,
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: color, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getLevelNumber(AlertLevel level) {
    switch (level) {
      case AlertLevel.safe: return '1 (SAFE)';
      case AlertLevel.advisory: return '2 (ADVISORY)';
      case AlertLevel.alert: return '3 (ALERT)';
      case AlertLevel.warning: return '4 (WARNING)';
      case AlertLevel.critical: return '5 (CRITICAL)';
    }
  }

  void _executeBroadcast(DisasterDataService service) {
    // Show Official Verification & Authorization Dialog before dissemination
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFFDC2626), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Authority Warning Authorization',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FLUVIA 3-Step Warning Workflow: Review ➔ Authorize ➔ Disseminate',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target Sector: ${_selectedTargetWardId == 'ALL' ? 'All Mountain Basins' : service.selectedWard?.name ?? _selectedTargetWardId}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text('Alert Level: ${_getLevelNumber(_selectedAlertLevel)}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.getRiskColor(_selectedAlertLevel.name))),
                  Text('Lead Time: $_leadTimeMinutes minutes', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569))),
                  const Divider(height: 12),
                  Text('Authorized Officer: ${service.currentUser?.name ?? 'Inspector Rajesh Varma'}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
                  Text('Agency Badge ID: ${service.currentUser?.badgeId ?? 'NDRF-UK-8842'}', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'By authorizing, CAP geo-targeted push notifications and SMS relays will be broadcast to all citizens within the hazard polygon.',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), height: 1.3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _finalizeBroadcast(service);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getRiskColor(_selectedAlertLevel.name),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.send_rounded, size: 14),
            label: Text('AUTHORIZE & DISSEMINATE', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _finalizeBroadcast(DisasterDataService service) {
    setState(() => _isBroadcasting = true);

    service.dispatchFiveLevelAlert(
      targetWardId: _selectedTargetWardId,
      alertLevel: _selectedAlertLevel,
      headline: _headlineController.text,
      specificProblemDetail: _problemDetailController.text,
      safeEvacuationRoute: _evacRouteController.text,
      leadTimeMinutes: _leadTimeMinutes,
      dangerRadiusKm: _geofenceRadiusKm,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CAP Level ${_getLevelNumber(_selectedAlertLevel)} Broadcast officially authorized and dispatched to citizens!'),
        backgroundColor: AppColors.getRiskColor(_selectedAlertLevel.name),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isBroadcasting = false);
    });
  }
}
