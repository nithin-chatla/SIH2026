import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../models/catchment_model.dart';
import '../theme/app_colors.dart';

class SystemStatusScreen extends StatelessWidget {
  const SystemStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final dataSources = service.dataSources;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FLUVIA Central System Status',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Subsystem Health, Data Quality & Telemetry Overview',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Health Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withAlpha(40),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF22C55E)),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Color(0xFF22C55E), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SYSTEM OPERATIONAL (ALL SUBSYSTEMS ACTIVE)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '7 Core Subsystems Active • Multi-Source Telemetry Synchronized • 0 Data Loss',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 7 Core Subsystems Grid
            Text(
              'CORE FLUVIA SUBSYSTEM HEALTH & INTEGRITY',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            _buildSubsystemCard(
              title: 'Data Ingestion & Sensors (SENSE)',
              statusTag: '[SIMULATED TELEMETRY]',
              tagColor: const Color(0xFF0284C7),
              description: 'IMD Doppler radar, GPM IMERG, CWC Hydro stage, and autonomous IoT nodes.',
              lastUpdated: '12 seconds ago',
              latency: 'Near-Realtime',
            ),
            _buildSubsystemCard(
              title: 'Spatial-Temporal Harmonization (HARMONIZE)',
              statusTag: '[OPERATIONAL PIPELINE]',
              tagColor: const Color(0xFF16A34A),
              description: 'Area-weighted Catchment-Averaged Rainfall Forcing (CARF) aggregation.',
              lastUpdated: 'Synchronized on clock cycle',
              latency: '< 50ms processing',
            ),
            _buildSubsystemCard(
              title: 'Catchment Prediction Engine (MODEL)',
              statusTag: '[OPERATIONAL ENGINE]',
              tagColor: const Color(0xFF7C3AED),
              description: 'Physics-guided GRU/LSTM networks + PUB geomorphic parameter transfer.',
              lastUpdated: 'Active cycle',
              latency: 'Inference 120ms',
            ),
            _buildSubsystemCard(
              title: 'Multi-Horizon Forecast Engine (PREDICT)',
              statusTag: '[6H / 3H / 1H / 30M]',
              tagColor: const Color(0xFFEA580C),
              description: 'Multi-head discharge forecast for 6H, 3H, 1H, and 30M peak surge windows.',
              lastUpdated: 'Every 5 mins',
              latency: 'Deterministic',
            ),
            _buildSubsystemCard(
              title: 'Downstream Risk Localizer (LOCALIZE)',
              statusTag: '[REGIONALLY CALIBRATED]',

              tagColor: const Color(0xFFDC2626),
              description: 'Translates catchment discharge to 4-tier risk categories and asset vulnerability.',
              lastUpdated: 'Instantaneous',
              latency: '< 10ms',
            ),
            _buildSubsystemCard(
              title: 'Authority Verification & CAP (VERIFY / ALERT)',
              statusTag: '[3-STEP SECURE WORKFLOW]',
              tagColor: const Color(0xFF0F172A),
              description: 'Officer evidence inspection, authorization gate, and Common Alerting Protocol dispatch.',
              lastUpdated: 'On-Demand',
              latency: 'Sub-second push',
            ),
            _buildSubsystemCard(
              title: 'Historical Digital Twin Replay (REPLAY)',
              statusTag: '[DIGITAL TWIN REPLAY]',
              tagColor: const Color(0xFF475569),
              description: 'Deterministic replay engine for 2021 Chamoli & 2024 Wayanad disasters.',
              lastUpdated: 'Pre-indexed',
              latency: 'Interactive scrubbing',
            ),

            const SizedBox(height: 16),

            // Environmental Data Sources Registry
            Text(
              'ENVIRONMENTAL DATA SOURCES & QUALITY VERIFICATION',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            ...dataSources.map((source) => _buildSourceCard(source)),

            const SizedBox(height: 16),

            // Scientific Honesty Policy Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.policy_outlined, size: 16, color: Color(0xFF334155)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'FLUVIA Data Integrity & Transparency Charter',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Missing environmental telemetry is handled explicitly without silently converting to zero.\n• Simulated data sources are clearly tagged as [SIMULATED DATA] to maintain operational transparency.\n• Model thresholds are labeled as regionally calibratable rather than universally validated.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsystemCard({
    required String title,
    required String statusTag,
    required Color tagColor,
    required String description,
    required String lastUpdated,
    required String latency,
  }) {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: tagColor.withAlpha(80)),
                ),
                child: Text(
                  statusTag,
                  style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w800, color: tagColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text('Status: Online ($latency)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A))),
              Text('Last Check: $lastUpdated', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(SystemDataSource source) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  source.category,
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF0369A1)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  source.providerName,
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Text(
                  '[SIMULATED]',
                  style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Resolution: ${source.resolution} • Cadence: ${source.updateCadence}', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
          Text('Role: ${source.scientificRole}', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF475569), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
