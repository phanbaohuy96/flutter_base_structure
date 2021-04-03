import 'package:flutter/material.dart';

import '../extentions/extention.dart';
import '../theme/theme_color.dart';

class StatusWidget extends StatelessWidget {
  final bool isSuccess;

  const StatusWidget({Key key, this.isSuccess}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: isSuccess == true ? AppColor.green : AppColor.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isSuccess == true
            ? translate(context)('common.succeed')
            : translate(context)('common.failed'),
        style: Theme.of(context).textTheme.subtitle1.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
