import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'storage_service.dart';

class BackupService {
  static Map<String, dynamic> createBackupData() {
    return {
      'format': 'SHARTENDU_OS_BACKUP',
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'knowledge': StorageService.knowledgeBox.values.toList(),
      'reflections': StorageService.reflectionBox.values.toList(),
      'decisions': StorageService.decisionBox.values.toList(),
      'tasks': StorageService.taskBox.values.toList(),
      'focus': StorageService.focusBox.values.toList(),
      'ideas': StorageService.ideaBox.values.toList(),
    };
  }

  static Future<File> createBackupFile() async {
    final directory = await getTemporaryDirectory();

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;

    final file = File(
      '${directory.path}/Shartendu_OS_Backup_$timestamp.json',
    );

    final json = const JsonEncoder.withIndent('  ')
        .convert(createBackupData());

    await file.writeAsString(json);

    return file;
  }

  static Future<void> shareBackup() async {
    final file = await createBackupFile();

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(file.path),
        ],
        subject: 'Shartendu OS Backup',
        text: 'Shartendu OS personal data backup',
      ),
    );
  }

  static Future<bool> restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null) {
      return false;
    }

    final selected = result.files.single;

    String jsonText;

    if (selected.bytes != null) {
      jsonText = utf8.decode(selected.bytes!);
    } else if (selected.path != null) {
      jsonText = await File(selected.path!).readAsString();
    } else {
      throw Exception('Unable to read selected backup file.');
    }

    final decoded = jsonDecode(jsonText);

    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'SHARTENDU_OS_BACKUP') {
      throw Exception('This is not a valid Shartendu OS backup.');
    }

    final version = decoded['version'];

    if (version != 1) {
      throw Exception('Unsupported backup version.');
    }

    await _restoreBox(
      StorageService.knowledgeBox,
      decoded['knowledge'],
    );

    await _restoreBox(
      StorageService.reflectionBox,
      decoded['reflections'],
    );

    await _restoreBox(
      StorageService.decisionBox,
      decoded['decisions'],
    );

    await _restoreBox(
      StorageService.taskBox,
      decoded['tasks'],
    );

    await _restoreBox(
      StorageService.focusBox,
      decoded['focus'],
    );

    await _restoreBox(
      StorageService.ideaBox,
      decoded['ideas'],
    );

    return true;
  }

  static Future<void> _restoreBox(
    dynamic box,
    dynamic data,
  ) async {
    if (data is! List) {
      return;
    }

    await box.clear();

    for (final item in data) {
      if (item is Map) {
        final id = item['id']?.toString();

        if (id != null && id.isNotEmpty) {
          await box.put(
            id,
            Map<dynamic, dynamic>.from(item),
          );
        }
      }
    }
  }
}
