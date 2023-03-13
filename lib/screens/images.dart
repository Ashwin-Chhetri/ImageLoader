import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:imageloader/provider/provider.dart';
import 'package:imageloader/utils/utils.dart';
import 'package:mime_type/mime_type.dart';
import 'package:provider/provider.dart';

class ImageHandler extends StatefulWidget {
  const ImageHandler({super.key});

  @override
  State<ImageHandler> createState() => _ImageState();
}

class _ImageState extends State<ImageHandler> {
  late CategoryProvider _categoryProvider;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      _categoryProvider.getImages('image');
    });
  }

  @override
  void dispose() {
    _categoryProvider.removeAll();
    super.dispose();
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    //print("Debug list lenght ${list.length}");
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder:
          (BuildContext context, CategoryProvider provider, Widget? child) {
        if (provider.loading) {
          return const Scaffold(body: CustomLoader());
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Images'),
          ),
          body: Visibility(
            visible: provider.images.isNotEmpty,
            replacement: const Center(child: Text('No Files Found')),
            child: CustomScrollView(
              primary: false,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(10.0),
                  sliver: SliverGrid.count(
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    crossAxisCount: 4,
                    children: map(
                      provider.images,
                      (index, file) {
                        String mimeType = mime(file.path) ?? '';
                        return _MediaTile(file: file, mimeType: mimeType);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MediaTile extends StatelessWidget {
  final File file;
  final String mimeType;

  const _MediaTile({required this.file, required this.mimeType});

  @override
  Widget build(BuildContext context) {
    debugInvertOversizedImages = true;
    return InkWell(
      //onTap: () => OpenFile.open(filepath),
      child: GridTile(
          child: Image(
        fit: BoxFit.cover,
        errorBuilder: (b, o, c) {
          return const Icon(Icons.image);
        },
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const Icon(Icons.image);
        },
        image: ResizeImage(
          FileImage(file),
          width: 150,
          height: 150,
        ),
      )),
    );
  }
}
