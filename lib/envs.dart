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
    appName: 'DaikinSales_Dev',
    baseApiLayer: 'https://dev.authorization.daikin-sales.nexlab.vn/',
    baseGraphQLUrl: 'https://dev.graphql.daikin-sales.nexlab.vn/v1/graphql',
    onesignalAppID: 'f826e303-49d1-4062-829f-27a40a092c11',
    subDealerEnabled: false,
    guestRegiterEnabled: true,
  };

  static final Map<String, dynamic> stagingEnv = {
    environment: 'Staging',
    developmentMode: false,
    appName: 'DaikinSales_Staging',
    baseApiLayer: '',
    baseGraphQLUrl: '',
    onesignalAppID: '',
    subDealerEnabled: false,
    guestRegiterEnabled: true,
  };

  static final Map<String, dynamic> prodEnv = {
    environment: 'Production',
    developmentMode: false,
    appName: 'DAIKIN Dealer',
    baseApiLayer: '',
    baseGraphQLUrl: '',
    onesignalAppID: '',
    subDealerEnabled: false,
    guestRegiterEnabled: true,
  };
}
