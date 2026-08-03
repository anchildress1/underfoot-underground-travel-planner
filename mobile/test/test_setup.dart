import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void setupGoogleFontsForTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
}
