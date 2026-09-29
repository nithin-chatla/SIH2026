import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/disaster_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/citizen_alert_dialog.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'iot_sensors_screen.dart';
import 'warning_dispatch_screen.dart';
import 'evacuation_hub_screen.dart';
import 'citizen_report_screen.dart';
import 'command_center_screen.dart';
import 'pub_ungauged_catchment_screen.dart';
import 'data_harmonization_screen.dart';
import 'model_validation_screen.dart';
import 'historical_replay_screen.dart';
import 'system_status_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String? _lastShownAlertId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DisasterDataService>();

    // If not logged in, show Login Screen
    if (!service.isLoggedIn) {
      return LoginScreen(onLoginSuccess: () => setState(() => _currentIndex = 0));
    }

    final isAuthority = service.isAuthority;
    final isDesktop = MediaQuery.of(context).size.width >= 950;

    // Check if a new targeted alert exists for the user's location
    if (service.latestTargetedAlertForUser != null &&
        service.latestTargetedAlertForUser!.id != _lastShownAlertId) {
      final alert = service.latestTargetedAlertForUser!;
      _lastShownAlertId = alert.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => CitizenTargetedAlertDialog(
            alert: alert,
            onDismiss: () {
              Navigator.pop(ctx);
              service.dismissUserAlert();
            },
            onNavigateSafeRoute: () {
              Navigator.pop(ctx);
              service.dismissUserAlert();
              setState(() => _currentIndex = isAuthority ? 4 : 1);
            },
          ),
        );
      });
    }

    // Screens list according to role
    final List<Widget> screens = isAuthority
        ? [
            DashboardScreen(onNavigateTab: (idx) => setState(() => _currentIndex = idx)),
            const MapScreen(),
            const IoTSensorsScreen(),
            const WarningDispatchScreen(),
            const EvacuationHubScreen(),
            const CitizenReportScreen(),
            const CommandCenterScreen(),
          ]
        : [
            DashboardScreen(onNavigateTab: (idx) => setState(() => _currentIndex = idx)),
            const MapScreen(),
            const EvacuationHubScreen(),
            const CitizenReportScreen(),
          ];

    final clampedIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildPremiumAppBar(service, isAuthority, isDesktop),
      drawer: _buildPremiumDrawer(service, isAuthority),
      body: Column(
        children: [
          // Critical Emergency Banner
          if (service.criticalWardsCount > 0)
            _buildEmergencyBanner(service, isAuthority),

          // Main Screen Area
          Expanded(
            child: Row(
              children: [
                if (isDesktop) _buildPremiumRail(isAuthority, clampedIndex),
                Expanded(
                  child: IndexedStack(
                    index: clampedIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : _buildPremiumBottomNav(isAuthority, clampedIndex),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PREMIUM APP BAR
  // ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildPremiumAppBar(
      DisasterDataService service, bool isAuthority, bool isDesktop) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Hamburger Menu
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, size: 22, color: AppColors.textSecondary),
                    tooltip: 'FLUVIA Modules & Research',
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    splashRadius: 20,
                  ),
                ),
                const SizedBox(width: 4),

                // Logo & Title
                const AppLogoWithTitle(
                  logoSize: 32,
                  titleFontSize: 17,
                  subtitleFontSize: 10,
                  showSubtitle: false,
                ),
                const SizedBox(width: 10),

                // Role Badge
                _buildRoleBadge(isAuthority),

                const Spacer(),

                // Operations Menu
                _buildOperationsMenu(isDesktop),

                const SizedBox(width: 4),

                // User avatar + Logout
                _buildUserMenu(service, isAuthority),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(bool isAuthority) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAuthority
            ? AppColors.criticalRedBg
            : AppColors.safeGreenBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAuthority
              ? AppColors.criticalRedBorder
              : AppColors.safeGreenBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAuthority ? Icons.shield_rounded : Icons.person_rounded,
            size: 10,
            color: isAuthority ? AppColors.criticalRed : AppColors.safeGreen,
          ),
          const SizedBox(width: 4),
          Text(
            isAuthority ? 'NDRF COMMAND' : 'CITIZEN',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isAuthority ? AppColors.criticalRed : AppColors.safeGreen,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsMenu(bool isDesktop) {
    return PopupMenuButton<String>(
      tooltip: 'Catchment Intelligence & Analytics',
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.analytics_outlined, size: 14, color: AppColors.primary),
            if (isDesktop) ...[
              const SizedBox(width: 6),
              Text(
                'OPERATIONS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
      onSelected: (val) {
        if (val == 'pub') {
          Navigator.push(context, _slideRoute(const PubUngaugedCatchmentScreen()));
        } else if (val == 'harmonization') {
          Navigator.push(context, _slideRoute(const DataHarmonizationScreen()));
        } else if (val == 'validation') {
          Navigator.push(context, _slideRoute(const ModelValidationScreen()));
        } else if (val == 'replay') {
          Navigator.push(context, _slideRoute(const HistoricalReplayScreen()));
        } else if (val == 'status') {
          Navigator.push(context, _slideRoute(const SystemStatusScreen()));
        }
      },
      itemBuilder: (ctx) => [
        _buildPopupItem('pub', Icons.terrain_rounded, const Color(0xFF0284C7), 'Ungauged Basin Regionalization (PUB)'),
        _buildPopupItem('harmonization', Icons.satellite_alt_rounded, const Color(0xFF16A34A), 'Multi-Source Data Harmonization'),
        _buildPopupItem('validation', Icons.analytics_outlined, const Color(0xFF7C3AED), 'LCO Cross-Validation & Architecture'),
        _buildPopupItem('replay', Icons.history_edu_rounded, const Color(0xFFEA580C), 'Historical Digital Twin Replay'),
        _buildPopupItem('status', Icons.verified_user_outlined, AppColors.textPrimary, 'System Status & Telemetry'),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, Color color, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenu(DisasterDataService service, bool isAuthority) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      icon: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: isAuthority
              ? AppColors.criticalGradient
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.person_rounded, size: 18, color: Colors.white),
      ),
      onSelected: (val) {
        if (val == 'logout') service.logout();
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.currentUser?.name ?? 'User',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                isAuthority ? 'NDRF Command' : 'Citizen User',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 16, color: AppColors.criticalRed),
              SizedBox(width: 10),
              Text('Sign Out'),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // EMERGENCY BANNER
  // ─────────────────────────────────────────────────────────────
  Widget _buildEmergencyBanner(DisasterDataService service, bool isAuthority) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: AppColors.criticalGradient,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'RED ALERT: Flash flood surge active in ${service.criticalWardsCount} ward(s). Immediate evacuation advisory issued.',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => setState(() => _currentIndex = isAuthority ? 4 : 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: Text(
                'Evacuate ➔',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PREMIUM NAVIGATION RAIL (DESKTOP)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPremiumRail(bool isAuthority, int selectedIndex) {
    final destinations = isAuthority
        ? _authorityDestinations
        : _citizenDestinations;

    return Container(
      width: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.border.withAlpha(180)),
        ),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        labelType: NavigationRailLabelType.all,
        indicatorColor: AppColors.primarySurface,
        selectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        destinations: destinations,
      ),
    );
  }

  List<NavigationRailDestination> get _authorityDestinations => const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined, size: 22),
      selectedIcon: Icon(Icons.dashboard, color: AppColors.primary, size: 22),
      label: Text('Overview'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.map_outlined, size: 22),
      selectedIcon: Icon(Icons.map, color: AppColors.primary, size: 22),
      label: Text('GIS Map'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.sensors_outlined, size: 22),
      selectedIcon: Icon(Icons.sensors, color: AppColors.primary, size: 22),
      label: Text('Sensors'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.cell_tower_outlined, size: 22),
      selectedIcon: Icon(Icons.cell_tower, color: AppColors.criticalRed, size: 22),
      label: Text('5-Lvl Alert'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.navigation_outlined, size: 22),
      selectedIcon: Icon(Icons.navigation, color: AppColors.safeGreen, size: 22),
      label: Text('Evacuate'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.add_photo_alternate_outlined, size: 22),
      selectedIcon: Icon(Icons.add_photo_alternate, color: AppColors.warningOrange, size: 22),
      label: Text('Reports'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.admin_panel_settings_outlined, size: 22),
      selectedIcon: Icon(Icons.admin_panel_settings, color: AppColors.criticalRed, size: 22),
      label: Text('Command'),
    ),
  ];

  List<NavigationRailDestination> get _citizenDestinations => const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined, size: 22),
      selectedIcon: Icon(Icons.dashboard, color: AppColors.primary, size: 22),
      label: Text('My Village'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.map_outlined, size: 22),
      selectedIcon: Icon(Icons.map, color: AppColors.primary, size: 22),
      label: Text('Hazard Map'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.navigation_outlined, size: 22),
      selectedIcon: Icon(Icons.navigation, color: AppColors.safeGreen, size: 22),
      label: Text('Safe Refuge'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.add_photo_alternate_outlined, size: 22),
      selectedIcon: Icon(Icons.add_photo_alternate, color: AppColors.warningOrange, size: 22),
      label: Text('Report'),
    ),
  ];

  // ─────────────────────────────────────────────────────────────
  // PREMIUM BOTTOM NAVIGATION (MOBILE)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPremiumBottomNav(bool isAuthority, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withAlpha(180)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        elevation: 0,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: AppColors.primarySurface,
        destinations: isAuthority
            ? const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
                NavigationDestination(icon: Icon(Icons.map_outlined), label: 'GIS Map'),
                NavigationDestination(icon: Icon(Icons.sensors_outlined), label: 'Sensors'),
                NavigationDestination(icon: Icon(Icons.cell_tower_outlined), label: '5-Lvl Alert'),
                NavigationDestination(icon: Icon(Icons.navigation_outlined), label: 'Evacuate'),
                NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Command'),
              ]
            : const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'My Village'),
                NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Hazard Map'),
                NavigationDestination(icon: Icon(Icons.navigation_outlined), label: 'Safe Refuge'),
                NavigationDestination(icon: Icon(Icons.add_photo_alternate_outlined), label: 'Report Hazard'),
              ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PREMIUM DRAWER
  // ─────────────────────────────────────────────────────────────
  Drawer _buildPremiumDrawer(DisasterDataService service, bool isAuthority) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            decoration: const BoxDecoration(
              gradient: AppColors.darkGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(size: 44, borderRadius: 12, showGlow: true),
                const SizedBox(height: 16),
                Text(
                  'FLUVIA',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Catchment-Aware Flash-Flood Intelligence',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAuthority
                        ? AppColors.criticalRed.withAlpha(40)
                        : AppColors.safeGreen.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAuthority ? Icons.shield_rounded : Icons.person_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isAuthority ? 'ROLE: NDRF COMMAND' : 'ROLE: CITIZEN',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Section
          _buildDrawerSectionHeader('OPERATIONAL SCREENS'),
          _buildDrawerNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            color: AppColors.primary,
            title: 'Dashboard & Overview',
            isSelected: _currentIndex == 0,
            onTap: () => _navigateDrawer(0),
          ),
          _buildDrawerNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            color: AppColors.primary,
            title: 'Interactive GIS Map',
            isSelected: _currentIndex == 1,
            onTap: () => _navigateDrawer(1),
          ),
          if (isAuthority) ...[
            _buildDrawerNavItem(
              icon: Icons.sensors_outlined,
              activeIcon: Icons.sensors,
              color: AppColors.primary,
              title: 'IoT Sensors Telemetry',
              isSelected: _currentIndex == 2,
              onTap: () => _navigateDrawer(2),
            ),
            _buildDrawerNavItem(
              icon: Icons.cell_tower_outlined,
              activeIcon: Icons.cell_tower,
              color: AppColors.criticalRed,
              title: 'Warning Dispatch & Verification',
              isSelected: _currentIndex == 3,
              onTap: () => _navigateDrawer(3),
            ),
          ],
          _buildDrawerNavItem(
            icon: Icons.navigation_outlined,
            activeIcon: Icons.navigation,
            color: AppColors.safeGreen,
            title: 'Evacuation & Safe Havens',
            isSelected: _currentIndex == (isAuthority ? 4 : 2),
            onTap: () => _navigateDrawer(isAuthority ? 4 : 2),
          ),
          _buildDrawerNavItem(
            icon: Icons.add_photo_alternate_outlined,
            activeIcon: Icons.add_photo_alternate,
            color: AppColors.warningOrange,
            title: 'Crowdsourced Ground Reports',
            isSelected: _currentIndex == (isAuthority ? 5 : 3),
            onTap: () => _navigateDrawer(isAuthority ? 5 : 3),
          ),
          if (isAuthority)
            _buildDrawerNavItem(
              icon: Icons.admin_panel_settings_outlined,
              activeIcon: Icons.admin_panel_settings,
              color: AppColors.criticalRed,
              title: 'NDRF Command & Simulation',
              isSelected: _currentIndex == 6,
              onTap: () => _navigateDrawer(6),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32, color: AppColors.border),
          ),

          // Intelligence & Model Analytics
          _buildDrawerSectionHeader('CATCHMENT INTELLIGENCE & MODELS', color: AppColors.primary),
          _buildDrawerResearchItem(
            icon: Icons.terrain_rounded,
            color: AppColors.primary,
            title: 'Ungauged Basin Regionalization (PUB)',
            subtitle: 'Knowledge transfer from donor catchments',
            onTap: () => _navigateToScreen(const PubUngaugedCatchmentScreen()),
          ),
          _buildDrawerResearchItem(
            icon: Icons.satellite_alt_rounded,
            color: const Color(0xFF16A34A),
            title: 'Multi-Source Data Harmonization',
            subtitle: 'Catchment-averaged forcing (CARF) engine',
            onTap: () => _navigateToScreen(const DataHarmonizationScreen()),
          ),
          _buildDrawerResearchItem(
            icon: Icons.analytics_outlined,
            color: const Color(0xFF7C3AED),
            title: 'LCO Validation & Architecture',
            subtitle: 'Leave-Catchment-Out metrics & model fusion',
            onTap: () => _navigateToScreen(const ModelValidationScreen()),
          ),
          _buildDrawerResearchItem(
            icon: Icons.history_edu_rounded,
            color: AppColors.warningOrange,
            title: 'Historical Digital Twin Replay',
            subtitle: '2021 Chamoli & 2024 Wayanad simulations',
            onTap: () => _navigateToScreen(const HistoricalReplayScreen()),
          ),
          _buildDrawerResearchItem(
            icon: Icons.verified_user_outlined,
            color: AppColors.textPrimary,
            title: 'System Status & Telemetry',
            subtitle: 'Subsystem health and data quality registry',
            onTap: () => _navigateToScreen(const SystemStatusScreen()),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32, color: AppColors.border),
          ),

          // Sign Out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.criticalRedBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.criticalRed, size: 18),
              ),
              title: Text(
                'Sign Out',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.criticalRed),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onTap: () {
                Navigator.pop(context);
                service.logout();
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color ?? AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerNavItem({
    required IconData icon,
    required IconData activeIcon,
    required Color color,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? color : AppColors.textMuted,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        selected: isSelected,
        selectedTileColor: color.withAlpha(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDrawerResearchItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
      ),
    );
  }

  void _navigateDrawer(int index) {
    Navigator.pop(context);
    setState(() => _currentIndex = index);
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, _slideRoute(screen));
  }

  // Smooth page transition
  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
