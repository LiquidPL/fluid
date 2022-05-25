import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> status(Permission permission) async {
    return permission.status;
  }

  Future<PermissionStatus> request(Permission permission) async {
    return permission.request();
  }
}

final permissionServiceProvider =
    Provider<PermissionService>((ref) => PermissionService());
