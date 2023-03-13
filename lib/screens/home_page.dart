import 'package:flutter/material.dart';
import 'package:imageloader/screens/images.dart';
import 'package:imageloader/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Permission _permission = Permission.manageExternalStorage;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  //Get permission
  checkPermission() async {
    PermissionStatus status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  //function to get the latest permission status obtained from the [PermissionWidget]
  onChangePermissionStatus(PermissionStatus updatedPermissionStatus) {
    setState(() {
      _permissionStatus = updatedPermissionStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
    // invoke filefetch function if permission granted
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(padding: const EdgeInsets.all(10), children: [
          PermissionWidget(_permission, onChangePermissionStatus),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            enabled: _permissionStatus.isGranted ? true : false,
            title: const Text('Images'),
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              child: Icon(Icons.image,
                  size: 20,
                  color:
                      _permissionStatus.isGranted ? Colors.blue : Colors.grey),
            ),
            onTap: () {
              Navigate.pushPage(context, const ImageHandler());
            },
          ),
        ]) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
