import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../models/evacuation_center.dart';
import '../theme/app_colors.dart';

class EvacuationHubScreen extends StatefulWidget {
  const EvacuationHubScreen({super.key});

  @override
  State<EvacuationHubScreen> createState() => _EvacuationHubScreenState();
}

class _EvacuationHubScreenState extends State<EvacuationHubScreen> {
  bool _isSosBeaconActive = false;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final selectedWard = service.selectedWard;

    return Scaffold(
      appBar: AppBar(
        title: Text('Evacuation & High-Ground Shelters', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency SOS Beacon Card (Clean Light Styling)
            _buildSosBeaconCard(context),
            const SizedBox(height: 16),

            // Active Safe Evacuation Corridor Advisory
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.safeGreenBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.safeGreenBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.alt_route_rounded, color: AppColors.safeGreen, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DESIGNATED SAFE CORRIDOR: GREEN ROUTE 1',
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.safeGreen, letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Active Path: ${selectedWard?.name ?? 'Lower Ward'} ➔ Upper Ridge Road ➔ Auli High Ground Haven',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '⚠️ CAUTION: Avoid Alaknanda Lower Riverside Track & Km 14 Bypass due to active boulder slide risk.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.warningOrange, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // High-Ground Shelters
            Text(
              'NEAREST HIGH-GROUND RELIEF CAMPS & HOSPITALS',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            ...service.evacuationCenters.map((center) => _buildCenterCard(context, center)),

            const SizedBox(height: 24),

            // Emergency Helplines
            _buildEmergencyContacts(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSosBeaconCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isSosBeaconActive ? AppColors.criticalRedBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSosBeaconActive ? AppColors.criticalRedBorder : AppColors.border,
          width: _isSosBeaconActive ? 1.5 : 1.0,
        ),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isSosBeaconActive ? AppColors.criticalRed : AppColors.criticalRedBg,
                    ),
                    child: Icon(
                      Icons.sos_rounded,
                      color: _isSosBeaconActive ? Colors.white : AppColors.criticalRed,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSosBeaconActive ? 'SOS DISTRESS BEACON ACTIVE' : 'Emergency SOS Distress Beacon',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isSosBeaconActive ? AppColors.criticalRed : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _isSosBeaconActive ? 'GPS location transmitting to NDRF quick response team' : 'Transmits offline distress SMS & acoustic alarm',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _isSosBeaconActive = !_isSosBeaconActive);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isSosBeaconActive ? 'SOS Distress Beacon Activated! NDRF notified.' : 'SOS Beacon Deactivated.'),
                            backgroundColor: _isSosBeaconActive ? AppColors.criticalRed : AppColors.surfaceElevated,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSosBeaconActive ? AppColors.criticalRed : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(_isSosBeaconActive ? 'STOP' : 'ACTIVATE'),
                    ),
                  ],
                ],
              ),
              if (isNarrow) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _isSosBeaconActive = !_isSosBeaconActive);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isSosBeaconActive ? 'SOS Distress Beacon Activated! NDRF notified.' : 'SOS Beacon Deactivated.'),
                          backgroundColor: _isSosBeaconActive ? AppColors.criticalRed : AppColors.surfaceElevated,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSosBeaconActive ? AppColors.criticalRed : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(_isSosBeaconActive ? 'STOP' : 'ACTIVATE'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCenterCard(BuildContext context, EvacuationCenter center) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.safeGreenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.safeGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.name, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Elevation: ${center.elevationMeters.toInt()}m • ${center.distanceKm} km away', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.safeGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${center.availableBeds} beds', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.safeGreen)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              if (center.hasHelipad) _buildFeatureBadge('Helipad (Air Evac)'),
              if (center.hasMedicalSupport) _buildFeatureBadge('Doctor & Triage'),
              _buildFeatureBadge('Emergency Power Gen'),
              _buildFeatureBadge('Potable Water'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling Camp Dispatch: ${center.contactNumber}'), backgroundColor: AppColors.primary),
                    );
                  },
                  icon: const Icon(Icons.call_outlined, size: 16),
                  label: Text('Contact Center: ${center.contactNumber}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
    );
  }

  Widget _buildEmergencyContacts(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GOVERNMENT EMERGENCY HELPLINES', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          _buildContactRow('National Disaster Response Force (NDRF)', '1078 / 011-24363260'),
          const Divider(height: 16, color: AppColors.border),
          _buildContactRow('State Emergency Operation Center (SEOC)', '1070 (Toll Free)'),
          const Divider(height: 16, color: AppColors.border),
          _buildContactRow('District Disaster Management Authority (DDMA)', '1077'),
          const Divider(height: 16, color: AppColors.border),
          _buildContactRow('Mountain Rescue & Air Ambulance Command', '+91 135-2710334'),
        ],
      ),
    );
  }

  Widget _buildContactRow(String title, String number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(number, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
        ),
        const Icon(Icons.phone_in_talk_outlined, size: 18, color: AppColors.primary),
      ],
    );
  }
}
