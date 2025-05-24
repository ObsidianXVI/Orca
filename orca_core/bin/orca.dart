import 'package:orca_core/orca.dart';

void main(List<String> _) async {
  print("Launching daemon...");
  await OrcaCore.init();
  print("Daemon launched successfully!\n===");
}
