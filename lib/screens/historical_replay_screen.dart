import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../models/catchment_model.dart';
import '../theme/app_colors.dart';

class HistoricalReplayScreen extends StatefulWidget {
  const HistoricalReplayScreen({super.key});

  @override
  State<HistoricalReplayScreen> createState() => _HistoricalReplayScreenState();
}

class _HistoricalReplayScreenState extends State<HistoricalReplayScreen> {
  int _selectedEventIndex = 0;
  int _currentStepIndex = 3; // Defaults to T-30M for dramatic impact

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final events = service.historicalEvents;
    final activeEvent = events[_selectedEventIndex.clamp(0, events.length - 1)];
    final timeSteps = activeEvent.timeSteps;
    final currentStep = timeSteps[_currentStepIndex.clamp(0, timeSteps.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historical Disaster Event Replay',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            Text(
              'Time-Series Progression & Validation Scrubber',
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
            // Top Badge Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_edu_rounded, color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HISTORICAL DIGITAL TWIN REPLAY MODE',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                    ),

                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Event Selector Dropdown / Pills
            Text('Select Historical Benchmark Event:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedEventIndex,
                  isExpanded: true,
                  items: events.asMap().entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(
                        entry.value.name,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedEventIndex = val;
                        _currentStepIndex = 2;
                      });
                      _applyReplayStep(service, events[val].timeSteps[_currentStepIndex], events[val].name);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Event Summary Card
            _buildEventSummaryCard(activeEvent),
            const SizedBox(height: 16),

            // Interactive Timeline Scrubber
            _buildTimelineScrubber(service, timeSteps, activeEvent.name),
            const SizedBox(height: 16),

            // Current Step Telemetry & Disaster Dynamics
            _buildCurrentStepDetails(currentStep),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSummaryCard(HistoricalEventReplayItem event) {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(event.dateString, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7))),
              Text('Impact: ${event.totalCasualtiesOrDisplacement} Affected', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626))),
            ],
          ),
          const SizedBox(height: 6),
          Text(event.location, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(event.description, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569), height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTimelineScrubber(DisasterDataService service, List<ReplayTimeStep> timeSteps, String eventName) {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text('Interactive Timeline Scrubber', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
              Text('Step ${_currentStepIndex + 1} of ${timeSteps.length}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 14),

          // Timeline Step Buttons
          Row(
            children: timeSteps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isSelected = idx == _currentStepIndex;
              final color = AppColors.getRiskColor(step.riskLevel.name);

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _currentStepIndex = idx);
                    _applyReplayStep(service, step, eventName);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: color, width: 1.5) : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          step.timeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.timeOffset,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepDetails(ReplayTimeStep step) {
    final riskColor = AppColors.getRiskColor(step.riskLevel.name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withAlpha(80)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: riskColor.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  'PHASE: ${step.timeLabel} (${step.riskLevel.name.toUpperCase()})',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: riskColor),
                ),
              ),
              Text(
                'Hydrological Peak Cresting',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Metric Cards
          Row(
            children: [
              Expanded(
                child: _buildStepMetric('Rain Rate', '${step.rainfallMmPerHour} mm/h', Icons.water_drop_outlined, const Color(0xFF0284C7)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStepMetric('Soil Saturation', '${step.soilSaturationPercent}%', Icons.layers_outlined, const Color(0xFFD97706)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStepMetric('Stream Stage', '${step.predictedWaterLevelMeters} m', Icons.waves_rounded, const Color(0xFFDC2626)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'Situational Progression:',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            step.situationNarrative,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155), height: 1.4),
          ),
          const SizedBox(height: 10),

          Text(
            'Emergency Response Action Triggered:',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7)),
          ),
          const SizedBox(height: 4),
          Text(
            step.actionTaken,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  void _applyReplayStep(DisasterDataService service, ReplayTimeStep step, String eventName) {
    service.updateSimulation(
      rainfallBoostMm: step.rainfallMmPerHour,
      soilBoostPercent: step.soilSaturationPercent * 0.3,
      scenarioName: 'Historical Replay: $eventName (${step.timeLabel})',
    );
  }
}
