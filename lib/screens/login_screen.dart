import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../services/disaster_data_service.dart';
import '../widgets/app_logo.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // 0 = Citizen, 1 = Official Authority
  int _roleIndex = 0;

  // For Citizen: true = Sign In, false = Sign Up
  bool _isSignIn = true;

  // Citizen Controllers
  final _citizenPhoneController = TextEditingController(text: '+91 98451 22910');
  final _citizenPassController = TextEditingController(text: '123456');
  final _citizenNameController = TextEditingController(text: 'Aarav Rawat');
  bool _obscureCitizenPass = true;

  // Official Controllers
  String _selectedDept = 'NDRF 8th Battalion Command';
  final _officialIdController = TextEditingController(text: 'NDRF-UK-8842');
  final _officialPassController = TextEditingController(text: 'NDRF@Secure2026');
  bool _obscureOfficialPass = true;

  final List<String> _departments = [
    'NDRF 8th Battalion Command',
    'State Disaster Management Authority (SDMA)',
    'Central Water Commission (CWC Flood Division)',
    'India Meteorological Department (IMD)',
    'District Emergency Operations Center (DEOC)',
  ];

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _citizenPhoneController.dispose();
    _citizenPassController.dispose();
    _citizenNameController.dispose();
    _officialIdController.dispose();
    _officialPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Background Pattern
          _buildAnimatedBackground(),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 48 : 20,
                    vertical: 32,
                  ),
                  child: isWide
                      ? _buildDesktopLayout(service)
                      : _buildMobileLayout(service),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BackgroundPatternPainter(
            animationValue: _pulseController.value,
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(DisasterDataService service) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Branding Panel
          Expanded(
            flex: 5,
            child: _buildBrandingPanel(),
          ),
          const SizedBox(width: 40),
          // Right: Login Form
          Expanded(
            flex: 5,
            child: _buildLoginCard(service),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(DisasterDataService service) {
    return _buildLoginCard(service);
  }

  Widget _buildBrandingPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: 72, borderRadius: 18, showGlow: true),
        const SizedBox(height: 24),
        Text(
          'FLUVIA',
          style: GoogleFonts.inter(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Catchment-Aware Flash-Flood\n& Landslide Intelligence',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Feature Highlights
        _buildFeatureRow(Icons.satellite_alt_rounded, 'Multi-Source Data Harmonization', 'IMD, CWC, ISRO, IoT sensors fused in real-time'),
        const SizedBox(height: 16),
        _buildFeatureRow(Icons.psychology_alt_outlined, 'AI-Driven Prediction Engine', 'Catchment-level LSTM + XGBoost ensemble models'),
        const SizedBox(height: 16),
        _buildFeatureRow(Icons.cell_tower_rounded, '5-Level CAP Warning System', 'Hyper-local alerts with evacuation routing'),
        const SizedBox(height: 32),

        // Credibility Badges
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.safeGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SIH 2026 • Government of India Initiative',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withAlpha(25)),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(DisasterDataService service) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      decoration: AppColors.elevatedCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mobile: Show brand header
            if (MediaQuery.of(context).size.width < 900)
              _buildMobileBrandHeader(),

            // Role Switcher
            _buildRoleSelector(),
            const SizedBox(height: 28),

            // Body Form
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _roleIndex == 0
                  ? _buildCitizenForm(service)
                  : _buildOfficialForm(service),
            ),

            const SizedBox(height: 28),

            // Divider with label
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'QUICK DEMO',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            const SizedBox(height: 16),

            _buildQuickDemoButtons(service),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBrandHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          const AppLogo(size: 64, borderRadius: 16, showGlow: true),
          const SizedBox(height: 16),
          Text(
            'FLUVIA',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Flash Flood & Landslide Early Warning System',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleButton(
              title: 'Citizen',
              icon: Icons.person_outline_rounded,
              isSelected: _roleIndex == 0,
              onTap: () => setState(() => _roleIndex = 0),
            ),
          ),
          Expanded(
            child: _buildRoleButton(
              title: 'Official Authority',
              icon: Icons.shield_outlined,
              isSelected: _roleIndex == 1,
              onTap: () => setState(() => _roleIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CITIZEN: SIGN IN & SIGN UP ---
  Widget _buildCitizenForm(DisasterDataService service) {
    return Column(
      key: const ValueKey('citizen'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub Toggle: Sign In vs Sign Up
        Row(
          children: [
            Expanded(child: _buildTabButton('Sign In', _isSignIn, () => setState(() => _isSignIn = true))),
            Expanded(child: _buildTabButton('Sign Up', !_isSignIn, () => setState(() => _isSignIn = false))),
          ],
        ),
        const SizedBox(height: 24),

        if (!_isSignIn) ...[
          _buildInput(
            controller: _citizenNameController,
            label: 'Full Name',
            hint: 'e.g. Aarav Rawat',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
        ],

        _buildInput(
          controller: _citizenPhoneController,
          label: 'Mobile Number',
          hint: '+91 98451 22910',
          icon: Icons.phone_android_rounded,
        ),
        const SizedBox(height: 16),

        _buildInput(
          controller: _citizenPassController,
          label: 'Password',
          hint: '••••••',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureCitizenPass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureCitizenPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
            onPressed: () => setState(() => _obscureCitizenPass = !_obscureCitizenPass),
          ),
        ),
        const SizedBox(height: 24),

        _buildPrimaryButton(
          label: _isSignIn ? 'Sign In' : 'Create Account',
          icon: _isSignIn ? Icons.login_rounded : Icons.person_add_alt_1_rounded,
          color: AppColors.primary,
          onPressed: () => _handleCitizenAction(service),
        ),
      ],
    );
  }

  // --- OFFICIAL AUTHORITY: SIGN IN ONLY ---
  Widget _buildOfficialForm(DisasterDataService service) {
    return Column(
      key: const ValueKey('official'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.criticalRedBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.criticalRedBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.security_rounded, size: 16, color: AppColors.criticalRed),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Secure Government Portal — MFA Enforced',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.criticalRed,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Department Selection
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department / Agency',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDept,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  items: _departments.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(
                        d,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDept = val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildInput(
          controller: _officialIdController,
          label: 'Official ID / Badge Number',
          hint: 'e.g. NDRF-UK-8842',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),

        _buildInput(
          controller: _officialPassController,
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureOfficialPass,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureOfficialPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
            onPressed: () => setState(() => _obscureOfficialPass = !_obscureOfficialPass),
          ),
        ),
        const SizedBox(height: 24),

        _buildPrimaryButton(
          label: 'Authenticate & Login',
          icon: Icons.verified_user_outlined,
          color: AppColors.surfaceDark,
          onPressed: () => _handleOfficialAction(service),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceElevated,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDemoButtons(DisasterDataService service) {
    return Row(
      children: [
        Expanded(
          child: _buildDemoChip(
            icon: Icons.shield_outlined,
            label: 'NDRF Officer',
            color: AppColors.criticalRed,
            onTap: () {
              service.loginAsOfficial(
                name: 'Inspector Rajesh Varma',
                badgeId: 'NDRF-UK-8842',
                department: 'NDRF 8th Battalion Command',
              );
              widget.onLoginSuccess();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDemoChip(
            icon: Icons.person_outline_rounded,
            label: 'Citizen',
            color: AppColors.primary,
            onTap: () {
              service.loginAsCitizen(
                name: 'Aarav Rawat',
                phone: '+91 98451 22910',
                wardId: 'W-02',
                wardName: 'Alaknanda Riverfront',
                location: const LatLng(30.5470, 79.5520),
              );
              widget.onLoginSuccess();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDemoChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCitizenAction(DisasterDataService service) {
    final name = _isSignIn ? 'Aarav Rawat' : _citizenNameController.text.trim();
    final phone = _citizenPhoneController.text.trim();

    service.loginAsCitizen(
      name: name.isEmpty ? 'Aarav Rawat' : name,
      phone: phone.isEmpty ? '+91 98451 22910' : phone,
      wardId: 'W-02',
      wardName: 'Alaknanda Riverfront',
      location: const LatLng(30.5470, 79.5520),
    );
    widget.onLoginSuccess();
  }

  void _handleOfficialAction(DisasterDataService service) {
    final badgeId = _officialIdController.text.trim();

    service.loginAsOfficial(
      name: 'Inspector Rajesh Varma',
      badgeId: badgeId.isEmpty ? 'NDRF-UK-8842' : badgeId,
      department: _selectedDept,
    );
    widget.onLoginSuccess();
  }
}


// ─────────────────────────────────────────────────────────────
// Background Painter — Subtle topographic / water-ripple pattern
// ─────────────────────────────────────────────────────────────
class _BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  _BackgroundPatternPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // Subtle topographic rings
    for (int i = 0; i < 6; i++) {
      final radius = 80.0 + i * 80 + animationValue * 15;
      final opacity = (0.03 - i * 0.004).clamp(0.005, 0.04);
      paint.color = const Color(0xFF1A6FEF).withAlpha((opacity * 255).toInt());

      // Top-right cluster
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15),
        radius,
        paint,
      );

      // Bottom-left cluster
      canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.85),
        radius * 0.8,
        paint,
      );
    }

    // Diagonal accent lines
    for (int i = 0; i < 4; i++) {
      final y = size.height * 0.2 + i * 140 + animationValue * 8;
      paint.color = const Color(0xFF1A6FEF).withAlpha(6);
      paint.strokeWidth = 0.5;
      canvas.drawLine(
        Offset(-50, y),
        Offset(size.width + 50, y - 100),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
