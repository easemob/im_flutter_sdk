import 'runner_info.dart';

class CapabilityRegistry {
  CapabilityRegistry(this.runnerInfo);

  final RunnerInfo runnerInfo;

  bool supports(String manager, String cmd) {
    return runnerInfo.capabilities.contains('$manager.$cmd');
  }
}
