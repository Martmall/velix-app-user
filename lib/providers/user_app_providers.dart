import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velix_core/velix_core.dart';

// Repository Providers (Live Backend & Supabase Realtime)
final authRepositoryProvider = Provider<IAuthRepository>((ref) => RemoteAuthRepository());
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) => RemoteVehicleRepository());
final bookingRepositoryProvider = Provider<IBookingRepository>((ref) => RemoteBookingRepository());
final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) => RemotePaymentRepository());
final supportRepositoryProvider = Provider<ISupportRepository>((ref) => RemoteSupportRepository());
final fileUploadServiceProvider = Provider<FileUploadService>((ref) => RemoteFileUploadService());

// User Auth State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _repository;
  AuthNotifier(this._repository) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final currentUser = await _repository.getCurrentUser();
    if (currentUser != null) {
      state = state.copyWith(user: currentUser, isAuthenticated: true);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signIn(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: UserRole.user,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    final ok = await _repository.verifyOtp(phone: phone, code: code);
    state = state.copyWith(isLoading: false, isAuthenticated: ok);
    return ok;
  }

  Future<void> completeKyc(String licenseNumber, String docPath) async {
    state = state.copyWith(isLoading: true);
    final updated = await _repository.completeKyc(licenseNumber: licenseNumber, documentPath: docPath);
    state = state.copyWith(user: updated, isLoading: false);
  }

  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser);
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? avatarUrl,
    String? licenseNumber,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repository.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        licenseNumber: licenseNumber,
      );
      state = state.copyWith(user: updated, isLoading: false);
    } catch (_) {
      if (state.user != null) {
        final fallback = state.user!.copyWith(
          fullName: fullName,
          email: email,
          phone: phone,
          avatarUrl: avatarUrl ?? state.user!.avatarUrl,
          licenseNumber: licenseNumber ?? state.user!.licenseNumber,
        );
        state = state.copyWith(user: fallback, isLoading: false);
      }
    }
  }

  Future<void> updateAvatar(String avatarUrl) async {
    if (state.user != null) {
      await updateProfile(
        fullName: state.user!.fullName,
        email: state.user!.email,
        phone: state.user!.phone,
        avatarUrl: avatarUrl,
        licenseNumber: state.user!.licenseNumber,
      );
    }
  }

  Future<void> topUpWallet(double amount) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repository.topUpWallet(amount: amount, userId: state.user?.id);
      state = state.copyWith(user: updated, isLoading: false);
    } catch (_) {
      if (state.user != null) {
        final newBal = (state.user!.walletBalance) + amount;
        state = state.copyWith(
          user: state.user!.copyWith(walletBalance: newBal),
          isLoading: false,
        );
      }
    }
  }

  Future<bool> deductWallet(double amount, {String? bookingId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repository.deductWallet(amount: amount, userId: state.user?.id, bookingId: bookingId);
      state = state.copyWith(user: updated, isLoading: false);
      return true;
    } catch (_) {
      if (state.user != null) {
        final newBal = (state.user!.walletBalance) - amount;
        state = state.copyWith(
          user: state.user!.copyWith(walletBalance: newBal < 0 ? 0.0 : newBal),
          isLoading: false,
        );
        return true;
      }
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = AuthState();
  }
}

final userAuthProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// Vehicle List Provider with Real-Time Streams and Filters
final vehicleSearchCategoryProvider = StateProvider<String>((ref) => 'All');
final vehicleSearchQueryProvider = StateProvider<String>((ref) => '');

final vehicleListProvider = StreamProvider<List<CarModel>>((ref) {
  final repo = ref.watch(vehicleRepositoryProvider);
  final cat = ref.watch(vehicleSearchCategoryProvider);
  final query = ref.watch(vehicleSearchQueryProvider);
  return repo.streamVehicles(category: cat, searchQuery: query);
});

// Active Draft Booking Flow State
class BookingDraftState {
  final CarModel? selectedCar;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupLocation;
  final String dropoffLocation;
  final List<double> selectedAddOnPrices;
  final String? promoCode;
  final String paymentMethod;
  final bool isProcessing;
  final String? lastBookingId;

  BookingDraftState({
    this.selectedCar,
    DateTime? pickupDate,
    DateTime? returnDate,
    this.pickupLocation = 'Lekki Phase 1, Lagos',
    this.dropoffLocation = 'Lekki Phase 1, Lagos',
    this.selectedAddOnPrices = const [],
    this.promoCode,
    this.paymentMethod = 'Visa ending in 4242',
    this.isProcessing = false,
    this.lastBookingId,
  })  : pickupDate = pickupDate ?? DateTime.now().add(const Duration(days: 1)),
        returnDate = returnDate ?? DateTime.now().add(const Duration(days: 3));

  PricingBreakdown get breakdown {
    final rate = selectedCar?.pricePerDay ?? 25000.0;
    return PricingService.calculatePrice(
      baseRatePerDay: rate,
      pickupDate: pickupDate,
      returnDate: returnDate,
      selectedAddOnPrices: selectedAddOnPrices,
      promoCode: promoCode,
    );
  }

  int get totalDays => breakdown.days;
  bool get hasChauffeur => selectedAddOnPrices.contains(15000.0);
  bool get hasChildSeat => selectedAddOnPrices.contains(3500.0);

  BookingDraftState copyWith({
    CarModel? selectedCar,
    DateTime? pickupDate,
    DateTime? returnDate,
    String? pickupLocation,
    String? dropoffLocation,
    List<double>? selectedAddOnPrices,
    String? promoCode,
    String? paymentMethod,
    bool? isProcessing,
    String? lastBookingId,
  }) {
    return BookingDraftState(
      selectedCar: selectedCar ?? this.selectedCar,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      selectedAddOnPrices: selectedAddOnPrices ?? this.selectedAddOnPrices,
      promoCode: promoCode ?? this.promoCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      lastBookingId: lastBookingId ?? this.lastBookingId,
    );
  }
}

class BookingDraftNotifier extends StateNotifier<BookingDraftState> {
  final IBookingRepository _bookingRepo;
  BookingDraftNotifier(this._bookingRepo) : super(BookingDraftState());

  void selectCar(CarModel car) {
    state = state.copyWith(selectedCar: car);
  }

  void setDates(DateTime pickup, DateTime returnD) {
    state = state.copyWith(pickupDate: pickup, returnDate: returnD);
  }

  void setLocations(String pickup, String dropoff) {
    state = state.copyWith(pickupLocation: pickup, dropoffLocation: dropoff);
  }

  void toggleAddOnPrice(double price) {
    final current = List<double>.from(state.selectedAddOnPrices);
    if (current.contains(price)) {
      current.remove(price);
    } else {
      current.add(price);
    }
    state = state.copyWith(selectedAddOnPrices: current);
  }

  void toggleChauffeur([bool? enabled, double price = 15000.0]) {
    final current = List<double>.from(state.selectedAddOnPrices);
    if (enabled == true) {
      if (!current.contains(price)) current.add(price);
    } else if (enabled == false) {
      current.remove(price);
    } else {
      if (current.contains(price)) {
        current.remove(price);
      } else {
        current.add(price);
      }
    }
    state = state.copyWith(selectedAddOnPrices: current);
  }

  void toggleChildSeat([bool? enabled, double price = 5000.0]) {
    final current = List<double>.from(state.selectedAddOnPrices);
    if (enabled == true) {
      if (!current.contains(price)) current.add(price);
    } else if (enabled == false) {
      current.remove(price);
    } else {
      if (current.contains(price)) {
        current.remove(price);
      } else {
        current.add(price);
      }
    }
    state = state.copyWith(selectedAddOnPrices: current);
  }

  void setPromoCode(String code) {
    state = state.copyWith(promoCode: code);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  Future<BookingModel?> confirmAndPay({UserModel? user}) async {
    if (state.selectedCar == null) return null;
    state = state.copyWith(isProcessing: true);
    final car = state.selectedCar!;
    final userId = user?.id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Valued Customer';
    final booking = await _bookingRepo.createBooking(
      carId: car.id,
      carName: car.name,
      carImage: car.imageUrl,
      userId: userId,
      userName: userName,
      partnerId: car.partnerId,
      startDate: state.pickupDate,
      endDate: state.returnDate,
      pickupLocation: state.pickupLocation,
      dropoffLocation: state.dropoffLocation,
      totalPrice: state.breakdown.grandTotal,
      paymentMethod: state.paymentMethod,
    );
    state = state.copyWith(isProcessing: false, lastBookingId: booking.id);
    return booking;
  }
}

final bookingDraftProvider = StateNotifierProvider<BookingDraftNotifier, BookingDraftState>((ref) {
  return BookingDraftNotifier(ref.watch(bookingRepositoryProvider));
});

// Bookings List Real-Time Stream Provider
final userBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  final auth = ref.watch(userAuthProvider);
  final userId = auth.user?.id;
  if (userId == null || userId.isEmpty) {
    return Stream.value(<BookingModel>[]);
  }
  return repo.streamUserBookings(userId);
});

// User Support Tickets Provider
final userSupportTicketsProvider = FutureProvider<List<SupportTicketModel>>((ref) async {
  final repo = ref.watch(supportRepositoryProvider);
  final auth = ref.watch(userAuthProvider);
  final userId = auth.user?.id;
  if (userId == null || userId.isEmpty) {
    return <SupportTicketModel>[];
  }
  return repo.getUserTickets(userId);
});

