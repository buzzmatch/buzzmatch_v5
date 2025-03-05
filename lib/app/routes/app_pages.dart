import 'package:get/get.dart';

import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';

import '../modules/authentication/bindings/auth_binding.dart';
import '../modules/authentication/views/login_view.dart';
import '../modules/authentication/views/signup_view.dart';

import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/brand_dashboard_view.dart';
import '../modules/dashboard/views/creator_dashboard_view.dart';

import '../modules/campaign/bindings/campaign_binding.dart';
import '../modules/campaign/views/campaign_create_view.dart';
import '../modules/campaign/views/campaign_detail_view.dart';

import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_list_view.dart';
import '../modules/chat/views/chat_detail_view.dart';

import '../modules/payment/bindings/payment_binding.dart';
import '../modules/payment/views/wallet_view.dart';
import '../modules/payment/views/payment_method_view.dart';

import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.BRAND_DASHBOARD,
      page: () => const BrandDashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.CREATOR_DASHBOARD,
      page: () => const CreatorDashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.CAMPAIGN_CREATE,
      page: () => const CampaignCreateView(),
      binding: CampaignBinding(),
    ),
    GetPage(
      name: _Paths.CAMPAIGN_DETAIL,
      page: () => const CampaignDetailView(),
      binding: CampaignBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_LIST,
      page: () => const ChatListView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_DETAIL,
      page: () => const ChatDetailView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.WALLET,
      page: () => const WalletView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_METHOD,
      page: () => const PaymentMethodView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}


class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile View'),
      ),
    );
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Add your dependencies here
  }
}
