import 'dart:io';

final RegExp _dartConstant = RegExp(
  r'''static\s+const\s+String\s+(\w+)\s*=\s*["']([^"']+)["']''',
);
final RegExp _androidConstant = RegExp(
  r'''static\s+final\s+String\s+(\w+)\s*=\s*["']([^"']+)["']''',
);
final RegExp _iosConstant = RegExp(
  r'''static\s+NSString\s*\*\s*const\s+(\w+)\s*=\s*@["']([^"']+)["']''',
);
final RegExp _dartInvocation = RegExp(
  r'callNativeMethod\s*\(\s*ChatMethodKeys\.(\w+)',
  multiLine: true,
);

List<String> checkContracts(String repositoryRoot) {
  final layout = _ContractLayout.fromRoot(repositoryRoot);
  final dartConstants = _readConstants(layout.dartConstants, _dartConstant);
  final androidConstants =
      _readConstants(layout.androidConstants, _androidConstant);
  final iosConstants = _readConstants(layout.iosConstants, _iosConstant);
  final androidNamesByValue = <String, String>{
    for (final entry in androidConstants.entries) entry.value: entry.key,
  };
  final iosNamesByValue = <String, String>{
    for (final entry in iosConstants.entries) entry.value: entry.key,
  };
  final invokedNames = _readDartInvocations(layout.dartSourceDirectory);
  final androidRoutes = _readFiles(layout.androidRoutes, '.java');
  final iosRoutes = _readFiles(layout.iosRoutes, '.m');
  final errors = <String>[];

  for (final name in invokedNames.toList()..sort()) {
    final dartValue = dartConstants[name];
    final androidName = dartValue == null
        ? null
        : _matchingPlatformName(
            dartName: name,
            dartValue: dartValue,
            platformConstants: androidConstants,
            namesByValue: androidNamesByValue,
          );
    final androidValue =
        androidName == null ? null : androidConstants[androidName];
    final iosName = dartValue == null ? null : iosNamesByValue[dartValue];
    final iosValue = iosName == null ? null : iosConstants[iosName];
    final requiresAndroid = name != 'updateAPNsPushToken';
    final requiresIos = name != 'updateHMSPushToken';

    if (dartValue == null ||
        (requiresAndroid &&
            (androidValue == null || dartValue != androidValue)) ||
        (requiresIos && (iosValue == null || dartValue != iosValue))) {
      errors.add(
        'Method key mismatch: $name '
        'dart=${dartValue ?? '<missing>'} '
        'android=${androidValue ?? '<missing>'} '
        'ios=${iosValue ?? '<missing>'}',
      );
      continue;
    }

    if (requiresAndroid &&
        !androidRoutes.contains('MethodKey.${androidName!}')) {
      errors.add('Android route missing: $name');
    }
    if (requiresIos && !iosRoutes.contains(iosName!)) {
      errors.add('iOS route missing: $name');
    }
  }

  return errors;
}

String? _matchingPlatformName({
  required String dartName,
  required String dartValue,
  required Map<String, String> platformConstants,
  required Map<String, String> namesByValue,
}) {
  final sameNameValue = platformConstants[dartName];
  if (sameNameValue != null) {
    return dartName;
  }
  return namesByValue[dartValue];
}

Map<String, String> _readConstants(File file, RegExp pattern) {
  if (!file.existsSync()) {
    return const {};
  }
  return <String, String>{
    for (final match in pattern.allMatches(file.readAsStringSync()))
      match.group(1)!: match.group(2)!,
  };
}

Set<String> _readDartInvocations(Directory directory) {
  if (!directory.existsSync()) {
    return const {};
  }
  final names = <String>{};
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    for (final match in _dartInvocation.allMatches(entity.readAsStringSync())) {
      names.add(match.group(1)!);
    }
  }
  return names;
}

String _readFiles(Directory directory, String extension) {
  if (!directory.existsSync()) {
    return '';
  }
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith(extension))
      .map((file) => file.readAsStringSync())
      .join('\n');
}

final class _ContractLayout {
  const _ContractLayout({
    required this.dartConstants,
    required this.dartSourceDirectory,
    required this.androidConstants,
    required this.androidRoutes,
    required this.iosConstants,
    required this.iosRoutes,
  });

  factory _ContractLayout.fromRoot(String root) {
    final fixtureDart = Directory('$root/dart');
    if (fixtureDart.existsSync()) {
      return _ContractLayout(
        dartConstants: File('$root/dart/chat_method_keys.dart'),
        dartSourceDirectory: fixtureDart,
        androidConstants: File('$root/android/MethodKey.java'),
        androidRoutes: Directory('$root/android'),
        iosConstants: File('$root/ios/MethodKeys.h'),
        iosRoutes: Directory('$root/ios'),
      );
    }

    return _ContractLayout(
      dartConstants: File(
        '$root/im_flutter_sdk/lib/src/internal/chat_method_keys.dart',
      ),
      dartSourceDirectory: Directory('$root/im_flutter_sdk/lib/src'),
      androidConstants: File(
        '$root/im_flutter_sdk_android/android/src/main/java/'
        'com/easemob/im_flutter_sdk/MethodKey.java',
      ),
      androidRoutes: Directory(
        '$root/im_flutter_sdk_android/android/src/main/java/'
        'com/easemob/im_flutter_sdk',
      ),
      iosConstants: File(
        '$root/im_flutter_sdk_ios/ios/Classes/MethodKeys.h',
      ),
      iosRoutes: Directory('$root/im_flutter_sdk_ios/ios/Classes'),
    );
  }

  final File dartConstants;
  final Directory dartSourceDirectory;
  final File androidConstants;
  final Directory androidRoutes;
  final File iosConstants;
  final Directory iosRoutes;
}
