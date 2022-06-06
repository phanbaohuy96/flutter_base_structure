import 'package:flutter/material.dart';

import '../../../common/utils.dart';
import '../../extentions/extention.dart';
import '../../theme/shadow.dart';
import '../../theme/theme_button.dart';

class SubmitScreenForm extends StatelessWidget {
  final String? submitBtnTitle;
  final String? cancelBtnTitle;
  final Widget? child;
  final Function()? onCancel;
  final Function()? onConfirm;
  final String? title;
  final bool isBackButtonVisible;

  const SubmitScreenForm({
    Key? key,
    this.submitBtnTitle,
    this.cancelBtnTitle,
    this.child,
    this.onCancel,
    this.onConfirm,
    this.title,
    this.isBackButtonVisible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.of(context);
    final _themeData = Theme.of(context);
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(
                title!,
                style: _themeData.textTheme.headline5,
              ),
              leading: isBackButtonVisible
                  ? IconButton(
                      icon: const Icon(
                        Icons.chevron_left_outlined,
                        size: 18,
                      ),
                      onPressed: onCancel,
                    )
                  : null,
              centerTitle: true,
              automaticallyImplyLeading: false,
              elevation: 3,
              titleSpacing: 0,
            )
          : null,
      body: GestureDetector(
        onTap: () => CommonFunction.hideKeyBoard(context),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: child ?? const SizedBox(),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 18,
                  bottom: 18 + device.padding.bottom,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  color: _themeData.scaffoldBackgroundColor,
                  boxShadow: boxShadowMedium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ThemeButton.notRecommend(
                        context: context,
                        title: cancelBtnTitle ?? translate(context).cancel,
                        onPressed: onCancel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ThemeButton.recommend(
                        context: context,
                        title: submitBtnTitle ?? translate(context).confirm,
                        onPressed: onConfirm,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
