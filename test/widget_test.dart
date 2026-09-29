import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:hydroshield/main.dart';
import 'package:hydroshield/services/disaster_data_service.dart';
import 'package:hydroshield/screens/dashboard_screen.dart';
import 'package:hydroshield/screens/pub_ungauged_catchment_screen.dart';
import 'package:hydroshield/screens/data_harmonization_screen.dart';
import 'package:hydroshield/screens/model_validation_screen.dart';
import 'package:hydroshield/screens/historical_replay_screen.dart';
import 'package:hydroshield/screens/system_status_screen.dart';
import 'package:hydroshield/screens/command_center_screen.dart';
import 'package:hydroshield/screens/evacuation_hub_screen.dart';
import 'package:hydroshield/screens/citizen_report_screen.dart';
import 'package:hydroshield/screens/iot_sensors_screen.dart';
import 'package:hydroshield/screens/warning_dispatch_screen.dart';
import 'package:hydroshield/screens/login_screen.dart';
import 'package:hydroshield/widgets/fluvia_sensing_matrix_card.dart';
import 'package:hydroshield/widgets/affected_locations_view.dart';
import 'package:hydroshield/widgets/simulation_control_panel.dart';
import 'package:hydroshield/widgets/end_to_end_demo_wizard.dart';

Widget _wrapWithService(Widget child, DisasterDataService service) {
  return ChangeNotifierProvider<DisasterDataService>.value(
    value: service,
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FLUVIA UI Layout & Overflow Verification Across Screen Formats', () {
    late DisasterDataService service;

    setUp(() {
      service = DisasterDataService();
    });

    final testSizes = [
      const Size(320, 640),  // Small mobile portrait
      const Size(375, 812),  // Standard mobile portrait
      const Size(812, 375),  // Mobile landscape
      const Size(1200, 800), // Tablet / Desktop
    ];

    testWidgets('Smoke test FluviaApp', (tester) async {
      await tester.pumpWidget(const FluviaApp());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(FluviaApp), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    for (final size in testSizes) {
      testWidgets('Verify Dashboard & Shell at ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Citizen Mode
        service.loginAsCitizen(
          name: 'Aarav Rawat',
          phone: '+91 98451 22910',
          wardId: 'W-02',
          wardName: 'Alaknanda Riverfront',
          location: const LatLng(30.5470, 79.5520),
        );
        await tester.pumpWidget(_wrapWithService(DashboardScreen(onNavigateTab: (_) {}), service));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());

        // Authority Mode
        service.loginAsOfficial(
          name: 'Inspector Rajesh Varma',
          badgeId: 'NDRF-UK-8842',
          department: 'NDRF 8th Battalion Command',
        );
        await tester.pumpWidget(_wrapWithService(DashboardScreen(onNavigateTab: (_) {}), service));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('Verify Operational & Specialized Screens at ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final screens = <Widget>[
          const PubUngaugedCatchmentScreen(),
          const DataHarmonizationScreen(),
          const ModelValidationScreen(),
          const SystemStatusScreen(),
          const HistoricalReplayScreen(),
          const CommandCenterScreen(),
          const EvacuationHubScreen(),
          const CitizenReportScreen(),
          const IoTSensorsScreen(),
          const WarningDispatchScreen(),
          LoginScreen(onLoginSuccess: () {}),
        ];

        for (final screen in screens) {
          await tester.pumpWidget(_wrapWithService(screen, service));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull, reason: 'Failed on screen: ${screen.runtimeType} at ${size.width}x${size.height}');
          await tester.pumpWidget(const SizedBox());
        }
      });

      testWidgets('Verify Component Cards & Panels at ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final components = <Widget>[
          const Scaffold(body: SingleChildScrollView(child: FluviaSensingMatrixCard())),
          const Scaffold(body: SingleChildScrollView(child: AffectedLocationsView())),
          const Scaffold(body: SingleChildScrollView(child: SimulationControlPanel())),
          const Scaffold(body: SingleChildScrollView(child: EndToEndDemoWizard())),
        ];

        for (final comp in components) {
          await tester.pumpWidget(_wrapWithService(comp, service));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull, reason: 'Failed on component: ${comp.runtimeType} at ${size.width}x${size.height}');
          await tester.pumpWidget(const SizedBox());
        }
      });
    }
  });
}
