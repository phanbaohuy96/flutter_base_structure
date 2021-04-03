import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../extentions/extention.dart';

class EmptyData extends StatelessWidget {
  final Function() onTap;

  const EmptyData({Key key, this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              ImageConstant.iconEmpty,
              width: MediaQuery.of(context).size.width / 3,
            ),
            const SizedBox(height: 8),
            Text(
              translate(context)('No data'),
              style: Theme.of(context).textTheme.subtitle2,
            )
          ],
        ),
      ),
    );
  }
}
