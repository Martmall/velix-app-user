import 'package:go_router/go_router.dart';
import 'package:velix_core/velix_core.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/onboarding/user_onboarding_screen.dart';
import '../../features/auth/user_sign_in_screen.dart';
import '../../features/auth/user_create_account_screen.dart';
import '../../features/auth/user_otp_verification_screen.dart';
import '../../features/auth/set_up_screen.dart';
import '../../features/auth/identity_verification_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/home/car_categories_screen.dart';
import '../../features/home/car_listing_screen.dart';
import '../../features/home/car_detail_screen.dart';
import '../../features/home/favorites_screen.dart';
import '../../features/booking/booking_date_location_screen.dart';
import '../../features/booking/booking_summary_screen.dart';
import '../../features/booking/payment_card_screen.dart';
import '../../features/booking/payment_bank_screen.dart';
import '../../features/booking/payment_wallet_screen.dart';
import '../../features/booking/payment_otp_screen.dart';
import '../../features/bookings/user_booking_detail_screen.dart';
import '../../features/booking/booking_confirmation_screen.dart';
import '../../features/trip/trip_updates_screen.dart';
import '../../features/trip/vehicle_access_screen.dart';
import '../../features/trip/vehicle_secured_screen.dart';
import '../../features/trip/return_vehicle_screen.dart';
import '../../features/trip/car_returned_success_screen.dart';
import '../../features/bookings/my_bookings_screen.dart';
import '../../features/trip/leave_review_screen.dart';
import '../../features/profile/user_profile_screen.dart';
import '../../features/profile/wallet_screen.dart';
import '../../features/profile/notification_center_screen.dart';
import '../../features/profile/live_chat_screen.dart';
import '../../features/profile/help_support_screen.dart';
import '../../features/profile/submit_ticket_screen.dart';
import '../../features/dev_preview_screen.dart';
import 'routes.dart';

final GoRouter userAppRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(path: AppRoutes.devPreview, builder: (context, state) => const DevPreviewScreen()),
    GoRoute(path: AppRoutes.welcome, builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: AppRoutes.onboarding, builder: (context, state) => const UserOnboardingScreen()),
    GoRoute(path: AppRoutes.signIn, builder: (context, state) => const UserSignInScreen()),
    GoRoute(path: AppRoutes.createAccount, builder: (context, state) => const UserCreateAccountScreen()),
    GoRoute(
      path: AppRoutes.otpVerification,
      builder: (context, state) => UserOtpVerificationScreen(
        phoneNumber: state.extra is String
            ? state.extra as String
            : (state.extra is Map ? (state.extra as Map)['phone'] as String? : null),
      ),
    ),
    GoRoute(path: AppRoutes.setUp, builder: (context, state) => const SetUpScreen()),
    GoRoute(path: AppRoutes.identityVerification, builder: (context, state) => const IdentityVerificationScreen()),
    
    GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeDashboardScreen()),
    GoRoute(path: AppRoutes.carCategories, builder: (context, state) => const CarCategoriesScreen()),
    GoRoute(path: AppRoutes.carListing, builder: (context, state) => const CarListingScreen()),
    GoRoute(path: AppRoutes.carDetail, builder: (context, state) => CarDetailScreen(car: state.extra as CarModel?)),
    GoRoute(path: AppRoutes.favorites, builder: (context, state) => const FavoritesScreen()),
    
    GoRoute(path: AppRoutes.bookingDateLocation, builder: (context, state) => const BookingDateLocationScreen()),
    GoRoute(path: AppRoutes.bookingSummary, builder: (context, state) => const BookingSummaryScreen()),
    GoRoute(path: AppRoutes.paymentCard, builder: (context, state) => const PaymentCardScreen()),
    GoRoute(path: AppRoutes.paymentBank, builder: (context, state) => const PaymentBankScreen()),
    GoRoute(path: AppRoutes.paymentWallet, builder: (context, state) => const PaymentWalletScreen()),
    GoRoute(path: AppRoutes.paymentOtp, builder: (context, state) => const PaymentOtpScreen()),
    GoRoute(path: AppRoutes.bookingConfirmation, builder: (context, state) => const BookingConfirmationScreen()),
    GoRoute(path: AppRoutes.bookingDetail, builder: (context, state) => UserBookingDetailScreen(booking: state.extra as BookingModel?)),
    
    GoRoute(path: AppRoutes.tripUpdates, builder: (context, state) => const TripUpdatesScreen()),
    GoRoute(path: AppRoutes.vehicleAccess, builder: (context, state) => const VehicleAccessScreen()),
    GoRoute(path: AppRoutes.vehicleSecured, builder: (context, state) => const VehicleSecuredScreen()),
    GoRoute(path: AppRoutes.returnVehicle, builder: (context, state) => const ReturnVehicleScreen()),
    GoRoute(path: AppRoutes.carReturnedSuccess, builder: (context, state) => const CarReturnedSuccessScreen()),
    
    GoRoute(path: AppRoutes.myBookings, builder: (context, state) => const MyBookingsScreen()),
    GoRoute(path: AppRoutes.wallet, builder: (context, state) => const WalletScreen()),
    GoRoute(path: AppRoutes.leaveReview, builder: (context, state) => const LeaveReviewScreen()),
    GoRoute(path: AppRoutes.userProfile, builder: (context, state) => const UserProfileScreen()),
    GoRoute(path: AppRoutes.notificationCenter, builder: (context, state) => const NotificationCenterScreen()),
    GoRoute(path: AppRoutes.liveChat, builder: (context, state) => LiveChatScreen(extra: state.extra as Map<String, dynamic>?)),
    GoRoute(path: AppRoutes.helpSupport, builder: (context, state) => const HelpSupportScreen()),
    GoRoute(path: AppRoutes.submitTicket, builder: (context, state) => const SubmitTicketScreen()),
  ],
);
