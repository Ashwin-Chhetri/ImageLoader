import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// Get all file
  static Stream<File> getAllFiles() {
    StreamController<File> files = StreamController<File>();
    //List<Directory> storages;
    FileUtils.getStorageList().listen((List<Directory> storages) {
      for (Directory dir in storages) {
        //List<File> allFileinDir = <File>[];
        try {
          getAllFilesInPath(dir.path).listen((file) {
            files.add(file);
          });
        } catch (e) {
          //allFileinDir = [];
        }
        //files.add(allFileinDir);
      }
    });
    return files.stream;
  }

  /// 1. Return all available Storage Paths
  static Stream<List<Directory>> getStorageList() async* {
    List<Directory> paths = (await getExternalStorageDirectories())!;
    List<Directory> filteredPaths = [];
    for (Directory dir in paths) {
      filteredPaths.add(removeDataDirectory(dir.path));
    }
    yield filteredPaths;
  }

  static Directory removeDataDirectory(String path) {
    return Directory(path.split('Android')[0]);
  }

  /// Get all files
  static Stream<File> getAllFilesInPath(String path) {
    StreamController<File> files = StreamController<File>();
    Directory dir = Directory(path);
    Stream<FileSystemEntity> streamEntity = dir.list();
    streamEntity.listen((fileType) {
      if (FileSystemEntity.isFileSync(fileType.path)) {
        var file = File(fileType.path);
        if (file.lengthSync() != 0) {
          files.add(file);
        }
      } else {
        if (!fileType.path.contains('/storage/emulated/0/Android')) {
          getAllFilesInPath(fileType.path).listen((fileType) {
            files.add(fileType);
          });
        }
      }
    });
    return files.stream;
  }

  /// Get all files
  // static Future<List<File>> getAllFilesInPath(String path) async {
  //   List<File> files = <File>[];
  //   Directory dir = Directory(path);
  //   List<FileSystemEntity> entity = dir.listSync();
  //   for (FileSystemEntity fileType in entity) {
  //     if (FileSystemEntity.isFileSync(fileType.path)) {
  //       var file = File(fileType.path);
  //       if (file.lengthSync() != 0) {
  //         files.add(file);
  //       }
  //     } else {
  //       if (!fileType.path.contains('/storage/emulated/0/Android')) {
  //         files.addAll(await getAllFilesInPath(fileType.path));
  //       }
  //     }
  //   }
  //   return files;
  // }
}
