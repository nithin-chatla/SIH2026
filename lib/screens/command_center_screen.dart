import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../models/ward_risk.dart';
import '../theme/app_colors.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  bool _isBroadcasting = false;
  String _selectedBroadcastWard = 'ALL';

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;
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
              child: const Icon(Icons.security, color: AppColors.criticalRed, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'NDRF Tactical Command Center',
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
            // Top Status Bar: Responsive 2x2 on Mobile or 4 items on Desktop
            _buildResponsiveStatusBar(context, service, isMobile),
            const SizedBox(height: 16),

            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildCapBroadcastPanel(context, service),
                        const SizedBox(height: 16),
                        _buildResourceDeploymentTracker(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildWardSirenControlGrid(context, service),
                        const SizedBox(height: 16),
                        _buildDroneTelemetryFeed(context),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _buildCapBroadcastPanel(context, service),
              const SizedBox(height: 16),
              _buildWardSirenControlGrid(context, service),
              const SizedBox(height: 16),
              _buildResourceDeploymentTracker(context),
              const SizedBox(height: 16),
              _buildDroneTelemetryFeed(context),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveStatusBar(BuildContext context, DisasterDataService service, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid = constraints.maxWidth < 900;
        if (useGrid) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCommandStatus('ISRO SAT-LINK', 'ACTIVE (GAGAN)', AppColors.safeGreen)),
                    Expanded(child: _buildCommandStatus('QRT BATTALION', '14 DEPLOYED', AppColors.primary)),
                  ],
                ),
                const Divider(height: 16, color: AppColors.border),
                Row(
                  children: [
                    Expanded(child: _buildCommandStatus('CAP GATEWAY', 'ONLINE / READY', AppColors.safeGreen)),
                    Expanded(child: _buildCommandStatus('ACOUSTIC SIRENS', '${service.criticalWardsCount} ARMED', AppColors.criticalRed)),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildCommandStatus('ISRO SAT-LINK', 'ACTIVE (GAGAN/NAVIC)', AppColors.safeGreen)),
              Expanded(child: _buildCommandStatus('QRT BATTALION', '14 TEAMS DEPLOYED', AppColors.primary)),
              Expanded(child: _buildCommandStatus('CAP GATEWAY', 'ONLINE / READY', AppColors.safeGreen)),
              Expanded(child: _buildCommandStatus('ACOUSTIC SIRENS', '${service.criticalWardsCount} ARMED', AppColors.criticalRed)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommandStatus(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: color), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildCapBroadcastPanel(BuildContext context, DisasterDataService service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.criticalRedBorder),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cell_tower, color: AppColors.criticalRed, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CAP EMERGENCY BROADCASTER',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.criticalRed, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dispatches emergency cell broadcast alerts and geo-fenced SMS notifications directly to citizen mobile devices across affected wards.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Ward Selector
          Text('Target Hazard Polygon:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBroadcastWard,
                isExpanded: true,
                dropdownColor: Colors.white,
                items: [
                  const DropdownMenuItem(value: 'ALL', child: Text('BROADCAST ALL HIGH-RISK WARDS')),
                  ...service.wards.map((w) => DropdownMenuItem(value: w.id, child: Text('${w.name} (${w.alertLevel.name.toUpperCase()})', overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) => setState(() => _selectedBroadcastWard = v!),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Message Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRANSMISSION PAYLOAD PREVIEW:', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(
                  'NDRF EMERGENCY FLASH FLOOD ORDER: Immediate evacuation ordered. Lead time window 25 mins. Follow Route Green-1 to designated high ground.',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _isBroadcasting = true);
                if (_selectedBroadcastWard == 'ALL') {
                  for (final w in service.wards) {
                    if (w.alertLevel == AlertLevel.critical || w.alertLevel == AlertLevel.warning) {
                      service.triggerWardSiren(w.id);
                    }
                  }
                } else {
                  service.triggerWardSiren(_selectedBroadcastWard);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('CAP Cell Broadcast Dispatched to 12,400+ citizen devices! Sirens sounding.'),
                    backgroundColor: AppColors.criticalRed,
                  ),
                );
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _isBroadcasting = false);
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.criticalRed, foregroundColor: Colors.white),
              icon: Icon(_isBroadcasting ? Icons.hourglass_top : Icons.broadcast_on_personal, size: 18),
              label: Text(_isBroadcasting ? 'TRANSMITTING BROADCAST...' : 'TRANSMIT MASS EMERGENCY ALERT', overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWardSirenControlGrid(BuildContext context, DisasterDataService service) {
    return Container(
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
          Text(
            'VILLAGE & WARD ACOUSTIC SIREN MATRIX',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          ...service.wards.map((ward) {
            final bool isActive = ward.sirenStatus == 'ACTIVE_BROADCAST';
            final Color riskColor = AppColors.getRiskColor(ward.alertLevel.name);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isActive ? AppColors.criticalRed : AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: riskColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ward.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                        Text('Risk: ${ward.riskScore.toInt()}% • Lead: ${ward.evacuationLeadTimeMinutes}m', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => service.triggerWardSiren(ward.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? AppColors.criticalRed : Colors.white,
                      foregroundColor: isActive ? Colors.white : AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.volume_up_outlined, size: 13, color: isActive ? Colors.white : AppColors.criticalRed),
                    label: Text(isActive ? 'ACTIVE' : 'TEST', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResourceDeploymentTracker(BuildContext context) {
    return Container(
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
          Text(
            'NDRF & SDRF UNIT DEPLOYMENT ASSETS',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          _buildAssetRow('NDRF 8th Battalion Team Alpha', 'Alaknanda Gorge Bridge', 'Boats & Heavy Cutters', AppColors.safeGreen),
          const Divider(height: 14, color: AppColors.border),
          _buildAssetRow('SDRF Mountain Rescue Team 3', 'Joshimath Upper Ward', 'Earthmover & Rope Gear', AppColors.safeGreen),
          const Divider(height: 14, color: AppColors.border),
          _buildAssetRow('IAF MI-17 Helitack Unit', 'Auli High Helipad', 'Air Evac Standby', AppColors.warningOrange),
        ],
      ),
    );
  }

  Widget _buildAssetRow(String name, String location, String gear, Color statusColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
              Text('$location • $gear', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(color: statusColor.withAlpha(20), borderRadius: BorderRadius.circular(4)),
          child: Text('READY', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ],
    );
  }

  Widget _buildDroneTelemetryFeed(BuildContext context) {
    return Container(
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
              const Icon(Icons.flight_takeoff_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI Reconnaissance Drone Feed',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.safeGreenBg, borderRadius: BorderRadius.circular(4)),
                child: Text('LIVE STREAM', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.safeGreen)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.videocam_outlined, size: 36, color: Color(0xFF334155)),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Text(
                    'CAM-04 [FLIR THERMAL / RGB 4K]\nALT: 180m AGL • 042° NE',
                    style: GoogleFonts.spaceMono(fontSize: 9, color: AppColors.safeGreen),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Text(
                    'AI DETECTION: SWELL +1.2m\nDEBRIS AT KM 14.2',
                    style: GoogleFonts.spaceMono(fontSize: 9, color: AppColors.warningOrange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
