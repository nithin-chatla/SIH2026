import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../services/disaster_data_service.dart';
import '../models/citizen_report.dart';
import '../theme/app_colors.dart';

class CitizenReportScreen extends StatefulWidget {
  const CitizenReportScreen({super.key});

  @override
  State<CitizenReportScreen> createState() => _CitizenReportScreenState();
}

class _CitizenReportScreenState extends State<CitizenReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Local Citizen / Volunteer');
  final _phoneController = TextEditingController(text: '+91 98765-43210');
  final _descController = TextEditingController();
  HazardCategory _category = HazardCategory.landslideObstruction;
  String _severity = 'Critical';

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Citizen Hazard Reporting Portal', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner (Clean Light Styling)
            Container(
              padding: const EdgeInsets.all(18),
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
                    child: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CROWDSOURCED HAZARD INTELLIGENCE',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.5),
                        ),
                        Text(
                          'Report fresh ground cracks, road blockages, river surging, or stranded individuals directly to NDRF and district disaster control rooms.',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SUBMIT FIELD OBSERVATION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                    const SizedBox(height: 16),

                    // Hazard Type Dropdown
                    Text('Hazard Classification', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<HazardCategory>(
                          value: _category,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(value: HazardCategory.landslideObstruction, child: Text('Active Landslide / Road Block')),
                            DropdownMenuItem(value: HazardCategory.bridgeOverflow, child: Text('Bridge Submerged / Turbulent Flow')),
                            DropdownMenuItem(value: HazardCategory.slopeCrack, child: Text('Fresh Ground / Hill Fissure')),
                            DropdownMenuItem(value: HazardCategory.waterLogging, child: Text('Severe Flash Waterlogging')),
                            DropdownMenuItem(value: HazardCategory.debrisFlow, child: Text('Debris Flow & Mud Torrent')),
                          ],
                          onChanged: (val) => setState(() => _category = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Severity Selector
                    Text('Urgency & Threat Level', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Minor Hazard', 'Moderate Danger', 'Critical / Imminent'].map((sev) {
                        final bool isSel = _severity == sev;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () => setState(() => _severity = sev),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.criticalRedBg : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isSel ? AppColors.criticalRed : AppColors.border),
                                ),
                                child: Center(
                                  child: Text(
                                    sev,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                      color: isSel ? AppColors.criticalRed : AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    Text('Detailed Description', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Specify exact landmark, road blockage, water level rise, or stranded vehicles...',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter description' : null,
                    ),
                    const SizedBox(height: 16),

                    // Geotag & Photo simulated attachments
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.gps_fixed, size: 16, color: AppColors.safeGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'GPS: 30.5540°N, 79.5630°E (Auto Tagged)',
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Photo attached successfully!'), backgroundColor: AppColors.primary),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceElevated, foregroundColor: AppColors.primary),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text('Add Photo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final report = CitizenHazardReport(
                              id: 'CR-${DateTime.now().millisecondsSinceEpoch}',
                              reporterName: _nameController.text,
                              phoneNumber: _phoneController.text,
                              category: _category,
                              description: _descController.text,
                              location: const LatLng(30.5540, 79.5630),
                              wardName: service.selectedWard?.name ?? 'Joshimath Ward',
                              reportedAt: DateTime.now(),
                              severity: _severity,
                            );
                            service.submitCitizenReport(report);
                            _descController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Hazard Report submitted to NDRF & Disaster Control Room!'), backgroundColor: AppColors.safeGreen),
                            );
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Transmit Report to Disaster Authority'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Crowdsourced Feed
            Text(
              'LIVE COMMUNITY HAZARD ALERTS',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            ...service.citizenReports.map((r) => _buildReportTile(context, r)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, CitizenHazardReport report) {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningOrangeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(report.categoryTitle, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.warningOrange)),
              ),
              if (report.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.safeGreenBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 12, color: AppColors.safeGreen),
                      const SizedBox(width: 4),
                      Text('NDRF VERIFIED', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.safeGreen)),
                    ],
                  ),
                ),
              Text('Upvotes: ${report.upvotes}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.description, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text('Reported by: ${report.reporterName} • ${report.wardName}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
              Text('Just now', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
