import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rc_fl_gopoolar/screens/auth/forgot_password.dart';
import 'package:rc_fl_gopoolar/screens/screens.dart';
import 'package:rc_fl_gopoolar/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important for plugins
  await Firebase.initializeApp(); // If using Firebase
  await SharedPreferences.getInstance(); // Register shared_preferences
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return MaterialApp(
      title: 'Chap Lifti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        primaryColor: primaryColor,
        fontFamily: 'Montserrat',
      ),
      home: const SplashScreen(),
      onGenerateRoute: routes,
    );
  }

  Route<dynamic>? routes(settings) {
    switch (settings.name) {
      case '/':
        return PageTransition(
            child: const SplashScreen(),
            type: PageTransitionType.fade,
            settings: settings);
      case '/onboarding':
        return PageTransition(
            child: const OnboardingScreen(),
            type: PageTransitionType.fade,
            settings: settings);
      case '/login':
        return PageTransition(
            child: const LoginScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/register':
        return PageTransition(
            child: const RegisterScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/otp':
        return PageTransition(
            child: const OTPVerificationScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/bottomBar':
        return PageTransition(
            child: const BottomBar(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/home':
        return PageTransition(
            child: const HomeScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/pickLocation':
        return PageTransition(
            child: const PickLocationScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/findRide':
        return PageTransition(
            child: const FindRideScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/rideDetail':
        return PageTransition(
            child: const RideDetailScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/review':
        return PageTransition(
            child: const ReviewScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/messages':
        return PageTransition(
            child: const MessagesScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/success':
        return PageTransition(
            child: const SuccessScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/mapView':
        return PageTransition(
            child: const MapViewScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/offerRide':
        return PageTransition(
            child: const OfferRideScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/notification':
        return PageTransition(
            child: const NotificationScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/myRides':
        return PageTransition(
            child: const MyRidesScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/rideRequest':
        return PageTransition(
            child: const RideRequestScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/startRide':
        return PageTransition(
            child: const StartRideScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/startRideRequester':
        return PageTransition(
            child: const StartRideRequesterScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/roadMap':
        return PageTransition(
            child: const RoadMapScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/endRide':
        return PageTransition(
            child: const EndRideScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/wallet':
        return PageTransition(
            child: const WalletScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/walletTransaction':
        return PageTransition(
            child: const WalletTransactionScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/addAndSendMoney':
        return PageTransition(
            child: const AddAndSendMoneyScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/paymentMethod':
        return PageTransition(
            child: const PaymentMethodScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/bankInformation':
        return PageTransition(
            child: const BankInformationScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/creditCard':
        return PageTransition(
            child: const CreditCardScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/paymentSuccess':
        return PageTransition(
            child: const PaymentSuccessScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/profile':
        return PageTransition(
            child: const ProfileScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/editProfile':
        return PageTransition(
            child: const EditProfileScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/myVehicle':
        return PageTransition(
            child: const MyVehicleScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/addNewVehicle':
        return PageTransition(
            child: const AddNewVehicleScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/rideHistory':
        return PageTransition(
            child: const RideHistoryScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/historyRideDetail':
        return PageTransition(
            child: const HistoryRideDetailScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/termsAndCondition':
        return PageTransition(
            child: const TermsAndConditionScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/privacyPolicy':
        return PageTransition(
            child: const PrivacyPolicyScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/customerSupport':
        return PageTransition(
            child: const CustomerSupportScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/faqs':
        return PageTransition(
            child: const FAQsScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      case '/forgot':
        return PageTransition(
            child: const ForgotPassword(),
            type: PageTransitionType.rightToLeft,
            settings: settings);
      default:
        return null;
    }
  }
}
