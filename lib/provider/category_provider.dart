import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:imageloader/utils/file_utils.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:mime_type/mime_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider extends ChangeNotifier {
  bool loading = false;
  List<File> images = <File>[];
  bool showHidden = false;

  final isolates = IsolateHandler();

  getImages(String type) {
    images.clear();
    String isolateName = type;
    isolates.spawn<String>(
      getAllFilesWithIsolate,
      name: isolateName,
      onReceive: (val) {
        isolates.kill(isolateName);
      },
      onInitialized: () => isolates.send('hey', to: isolateName),
    );
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, '${isolateName}_2');
    port.listen((files) {
      images.add(files);
      notifyListeners();
    }).onDone(() {
      port.close();
      IsolateNameServer.removePortNameMapping('${isolateName}_2');
    });
  }

  static getAllFilesWithIsolate(Map<String, dynamic> context) {
    String isolateName = context['name'];
    final SendPort? send =
        IsolateNameServer.lookupPortByName('${isolateName}_2');

    FileUtils.getAllFiles().listen((file) {
      String mimeType = mime(file.path) ?? '';
      if (mimeType.split('/')[0] == isolateName) {
        if (file.lengthSync() != 0) {
          send!.send(file);
        }
      }
    });
  }

  void setLoading(value) {
    loading = value;
    notifyListeners();
  }

  setHidden(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hidden', value);
    showHidden = value;
    notifyListeners();
  }

  getHidden() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool h = prefs.getBool('hidden') ?? false;
    setHidden(h);
  }

  //clean up
  void removeAll() {
    print('Isolate are disposed.');
    isolates.kill('image');
    ReceivePort port = ReceivePort();
    port.close();
    IsolateNameServer.removePortNameMapping('image_2');
  }
}
