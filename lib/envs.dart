class Env {
  static const environment = 'environment';
  static const developmentMode = 'developmentMode';
  static const appName = 'appname';
  static const baseApiLayer = 'baseApiLayer';
  static const baseGraphQLUrl = 'baseGraphQLUrl';
  static const onesignalAppID = 'onesignalAppID';
  static const subDealerEnabled = 'subDealerEnabled';
  static const guestRegiterEnabled = 'guestRegiterEnabled';

  static final Map<String, dynamic> devEnv = {
    environment: 'Development',
    developmentMode: true,
    appName: 'FBS_Dev',
    baseApiLayer: '',
    baseGraphQLUrl: '',
    onesignalAppID: '',
    subDealerEnabled: false,
    guestRegiterEnabled: true,
  };

  static final Map<String, dynamic> stagingEnv = {
    environment: 'Staging',
    developmentMode: false,
    appName: 'FBS_Staging',
    baseApiLayer: '',
    baseGraphQLUrl: '',
    onesignalAppID: '',
    subDealerEnabled: false,
    guestRegiterEnabled: true,
  };

  static final Map<String, dynamic> prodEnv = {
    environment: 'Production',
    developmentMode: false,
    appName: 'FBS',
    baseApiLayer: '',
    baseGraphQLUrl: '',
    onesignalAppID: '',
    subDealerEnabled: false,
    guestRegiterEnabled: true,
  };
}
