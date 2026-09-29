import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ModelValidationScreen extends StatelessWidget {
  const ModelValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Model Architecture & Validation',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          overflow: TextOverflow.ellipsis,
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
            // Top Scientific Integrity Alert
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFFB45309), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scientific Honesty & Validation Rigor',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF92400E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'FLUVIA strictly distinguishes between operational prediction pipelines and full-scale field calibrations. Benchmark figures below represent target validation protocols under the Leave-Catchment-Out test protocol.',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF78350F), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Conceptual Model Architecture Diagram
            _buildArchitectureDiagram(),
            const SizedBox(height: 16),

            // Leave-Catchment-Out Validation Experiment Protocol
            _buildLeaveCatchmentOutSection(),
            const SizedBox(height: 16),

            // Baseline Comparison Matrix
            _buildBaselineComparisonMatrix(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureDiagram() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'Deep Fusion Architecture',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                child: Text('PREDICTION ENGINE', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF2563EB))),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Inputs -> 3 Encoders -> Fusion Engine -> Multi-Horizon Output
          _buildArchRow('1. STATIC GEOMORPHIC', 'Area, Slope, Relief, LULC, Drainage, TWI', 'Static MLP (128-D)', const Color(0xFF3B82F6)),
          const SizedBox(height: 8),
          _buildArchRow('2. DYNAMIC HYDRO-METEOROLOGY', '15m Rain, Soil Saturation, API-7', 'Bi-GRU / LSTM (256-D)', const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _buildArchRow('3. RIVER NETWORK TOPOLOGY', 'Strahler Confluences & Stream Graph', 'Graph Neural Net (GNN)', const Color(0xFF8B5CF6)),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '⚡ LATENT CATCHMENT HYDROLOGICAL STATE FUSION',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Multi-Horizon Peak Surge Head: 6H • 3H • 1H • 30M',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 9.5, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchRow(String title, String inputs, String encoder, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 36,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Inputs: $inputs', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    encoder,
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCatchmentOutSection() {
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
            'Leave-Catchment-Out (LCO) Validation Experiment',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            'To rigorously evaluate performance on truly ungauged basins, the model is trained on N-1 monitored basins and evaluated exclusively on a held-out catchment unseen during training.',
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 12),

          // LCO Visual Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 450;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRAINING SET (N-1 Catchments)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF15803D))),
                      const SizedBox(height: 2),
                      Text('Catchments A, B, C, D, F, G, H (Instrumented Gauges)', style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF334155))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text('ZERO-SHOT GENERALIZATION', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('HELD OUT TEST (PUB)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFDC2626))),
                      const SizedBox(height: 2),
                      Text('Catchment E (Zero-Shot Prediction)', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRAINING SET (N-1 Catchments)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF15803D))),
                          const SizedBox(height: 4),
                          Text('Catchment A, B, C, D, F, G, H (Instrumented Gauges)', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF334155))),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HELD OUT TEST (PUB)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFDC2626))),
                          const SizedBox(height: 4),
                          Text('Catchment E (Zero-Shot Prediction)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaselineComparisonMatrix() {
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
              Flexible(
                child: Text(
                  'Hydrological Benchmark Comparison',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                child: Text('TARGET METRICS', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFFB45309))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 480),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.2),
                  1: FlexColumnWidth(1.2),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.4),
                },
                border: TableBorder.all(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(8)),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                    children: [
                      _buildTableCell('Model Paradigm', isHeader: true),
                      _buildTableCell('NSE Score', isHeader: true),
                      _buildTableCell('KGE Efficiency', isHeader: true),
                      _buildTableCell('Peak Flow Error', isHeader: true),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('1. Lumped Rainfall Thresholds'),
                      _buildTableCell('0.42 (Low)'),
                      _buildTableCell('0.38'),
                      _buildTableCell('±34%'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('2. Standard HEC-HMS (Calibrated)'),
                      _buildTableCell('0.68 (Moderate)'),
                      _buildTableCell('0.64'),
                      _buildTableCell('±22%'),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('3. FLUVIA Catchment-Aware GNN', isBold: true),
                      _buildTableCell('0.82 (Target)', tagColor: const Color(0xFF16A34A)),
                      _buildTableCell('0.79 (Target)', tagColor: const Color(0xFF16A34A)),
                      _buildTableCell('±11% (Target)', tagColor: const Color(0xFF16A34A)),
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

  Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false, Color? tagColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                fontWeight: (isHeader || isBold) ? FontWeight.w700 : FontWeight.w500,
                color: isHeader ? const Color(0xFF0F172A) : isBold ? const Color(0xFF0284C7) : const Color(0xFF334155),
              ),
            ),
    );
  }
}
