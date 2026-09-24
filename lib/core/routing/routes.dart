class AppRoutes {
  static const String welcome = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/auth/signin';
  static const String createAccount = '/auth/create-account';
  static const String otpVerification = '/auth/otp';
  static const String setUp = '/auth/setup';
  static const String identityVerification = '/auth/kyc';
  
  static const String home = '/user/home';
  static const String carCategories = '/user/categories';
  static const String carListing = '/user/cars';
  static const String carDetail = '/user/car-detail';
  static const String favorites = '/user/favorites';
  
  static const String bookingDateLocation = '/user/booking/step1';
  static const String bookingSummary = '/user/booking/step2';
  static const String paymentCard = '/user/payment/card';
  static const String paymentBank = '/user/payment/bank';
  static const String paymentWallet = '/user/payment/wallet';
  static const String paymentOtp = '/user/payment/otp';
  static const String bookingConfirmation = '/user/booking/success';
  static const String bookingDetail = '/user/booking/detail';
  
  static const String tripUpdates = '/user/trip';
  static const String vehicleAccess = '/user/vehicle-access';
  static const String vehicleSecured = '/user/vehicle-secured';
  static const String returnVehicle = '/user/return-vehicle';
  static const String carReturnedSuccess = '/user/return-success';
  
  static const String myBookings = '/user/bookings';
  static const String wallet = '/user/wallet';
  static const String leaveReview = '/user/review';
  static const String userProfile = '/user/profile';
  static const String notificationCenter = '/user/notifications';
  static const String liveChat = '/user/chat';
  static const String helpSupport = '/user/help';
  static const String submitTicket = '/user/ticket';
  static const String devPreview = '/dev-preview';
}
