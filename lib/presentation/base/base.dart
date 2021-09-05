import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../common/components/i18n/internationalization.dart';
import '../../common/constants.dart';
import '../../common/utils.dart';
import '../../data/data_source/remote/app_api_service.dart';
import '../../data/data_source/remote/http_constants.dart';
import '../common_widget/export.dart';
import '../extentions/extention.dart';
import '../route/route_list.dart';

part 'bloc_base.dart';
part 'state_base.dart';
part 'state_base.ext.dart';
