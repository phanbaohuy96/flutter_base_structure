import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/localization_ext.dart';
import '../../presentation/extentions/extention.dart';

export 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> _requestPermission(
    Permission ps,
    BuildContext context, {
    bool required = true,
  }) async {
    var status = await ps.status;

    // If the user denied the permission for a second
    // time.
    // Android device: isDenied : true, isPermanentlyDenied: true
    // iOS device: isDenied : false, isPermanentlyDenied: true
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await ps.request();

      if (status.isPermanentlyDenied && required) {
        unawaited(_showPermissionWarningDialog(context));

        return false;
      }
    }

    return !status.isDenied && !status.isPermanentlyDenied;
  }

  //////////////////////////////////////////////////////////////////
  ///                         Publish api                        ///
  //////////////////////////////////////////////////////////////////

  Future<bool> checkPermission(
    Permission ps,
    BuildContext context,
  ) async {
    final status = await ps.status;

    return !status.isDenied &&
        !status.isPermanentlyDenied &&
        !status.isRestricted;
  }

  Future<bool> requestPermission(
    Permission ps,
    BuildContext context, {
    bool required = true,
  }) async {
    var isGranted = await checkPermission(ps, context);

    if (!isGranted) {
      isGranted = await _requestPermission(
        ps,
        context,
        required: required,
      );
    }
    return isGranted;
  }

  Future<List<bool>> requestPermissions(
    List<Permission> pss,
    BuildContext context, {
    bool required = true,
  }) async {
    final result = <bool>[];
    for (final ps in pss) {
      result.add(
        await requestPermission(
          ps,
          context,
          required: required,
        ),
      );
    }
    return result;
  }

  Future<void> _showPermissionWarningDialog(BuildContext context) {
    final l10n = context.coreL10n;
    return showActionDialog(
      context,
      title: l10n.requestPermission,
      subTitle: l10n.haveNoPermission,
      titleBottomBtn: l10n.cancel,
      actions: {
        l10n.openSetting: openAppSettings,
      },
    );
  }
}
