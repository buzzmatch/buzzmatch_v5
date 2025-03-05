part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const WELCOME = _Paths.WELCOME;
  static const LOGIN = _Paths.LOGIN;
  static const SIGNUP = _Paths.SIGNUP;
  static const BRAND_DASHBOARD = _Paths.BRAND_DASHBOARD;
  static const CREATOR_DASHBOARD = _Paths.CREATOR_DASHBOARD;
  static const CAMPAIGN_CREATE = _Paths.CAMPAIGN_CREATE;
  static const CAMPAIGN_DETAIL = _Paths.CAMPAIGN_DETAIL;
  static const CHAT_LIST = _Paths.CHAT_LIST;
  static const CHAT_DETAIL = _Paths.CHAT_DETAIL;
  static const WALLET = _Paths.WALLET;
  static const PAYMENT_METHOD = _Paths.PAYMENT_METHOD;
  static const PROFILE = _Paths.PROFILE;
}

abstract class _Paths {
  static const SPLASH = '/splash';
  static const WELCOME = '/welcome';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const BRAND_DASHBOARD = '/brand-dashboard';
  static const CREATOR_DASHBOARD = '/creator-dashboard';
  static const CAMPAIGN_CREATE = '/campaign-create';
  static const CAMPAIGN_DETAIL = '/campaign-detail';
  static const CHAT_LIST = '/chat-list';
  static const CHAT_DETAIL = '/chat-detail';
  static const WALLET = '/wallet';
  static const PAYMENT_METHOD = '/payment-method';
  static const PROFILE = '/profile';
}
