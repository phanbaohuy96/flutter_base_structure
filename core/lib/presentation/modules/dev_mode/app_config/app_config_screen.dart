import 'package:flutter/material.dart';

import '../../../../core.dart';
import '../../../../di/core_micro.dart';

class AppConfigScreen extends StatefulWidget {
  static String routeName = '/app-config';

  const AppConfigScreen({Key? key}) : super(key: key);

  @override
  State<AppConfigScreen> createState() => _AppConfigScreenState();
}

class _AppConfigScreenState extends State<AppConfigScreen> {
  final _baseDomainCtrl = InputContainerController();

  final _localDataManager = injector<CoreLocalDataManager>();

  @override
  void initState() {
    _baseDomainCtrl.text = _localDataManager.domainReplacement ??
        Config.instance.appConfig.baseApiLayer;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenForm(
      title: 'App Config',
      bottomNavigationBar: _buildFooter(context),
      bgColor: themeColor.themePrimary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: InputContainer(
                controller: _baseDomainCtrl,
                title: 'Base Domain',
                helperText:
                    '''Enter the base domain for API requests, you can set it to empty string to use default value''',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return FooterWidget(
      child: Row(
        children: [
          Expanded(
            child: ThemeButton.outline(
              onPressed: () {
                _localDataManager.setDomainReplacement(null);
                Navigator.of(context).pop();
              },
              title: 'Reset',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ThemeButton.primary(
              onPressed: () {
                _localDataManager.setDomainReplacement(_baseDomainCtrl.text);
                Navigator.of(context).pop();
              },
              title: 'Save',
            ),
          ),
        ],
      ),
    );
  }
}
