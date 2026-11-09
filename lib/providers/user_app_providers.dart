import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velix_core/velix_core.dart';

// Repository Providers (live backend REST API)
final authRepositoryProvider = Provider<IAuthRepository>((ref) => RemoteAuthRepository());
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) => RemoteVehicleRepository());
final bookingRepositoryProvider = Provider<IBookingRepository>((ref) => RemoteBookingRepository());
final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) => RemotePaymentRepository());
final supportRepositoryProvider = Provider<ISupportRepository>((ref) => RemoteSupportRepository());

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

/// Every method reports failure via its return value and [AuthState.error] (the server's own
/// message) -- nothing is ever "succeeded" locally when the server said no.
class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _repository;
  StreamSubscription<void>? _expiry;

  AuthNotifier(this._repository) : super(AuthState()) {
    _expiry = ApiClient().onSessionExpired.listen((_) => state = AuthState());
    _init();
  }

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final currentUser = await _repository.getCurrentUser();
      if (currentUser != null) {
        state = state.copyWith(user: currentUser, isAuthenticated: true);
      }
    } catch (_) {
      // Offline at launch: stay signed out in the UI; the stored session is kept for next time.
    }
  }

  Future<bool> _run(Future<UserModel> Function() call) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await call();
      state = state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseErrorMessage(e));
      return false;
    }
  }

  Future<bool> signIn(String email, String password) =>
      _run(() => _repository.signIn(email: email, password: password));

  Future<bool> signInWithGoogle() => _run(() => _repository.signInWithGoogle());

  /// Returns the registration result (an emailed code to confirm), or null on failure.
  Future<RegistrationResult?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.registerUser(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: UserRole.user,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseErrorMessage(e));
      return null;
    }
  }

  /// Confirms the emailed registration code; this is what starts the first session.
  Future<bool> verifyRegistration(String email, String code) =>
      _run(() => _repository.verifyRegistrationOtp(email: email, code: code));

  Future<bool> resendVerificationEmail(String email) async {
    try {
      await _repository.resendVerificationEmail(email: email);
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiClient.parseErrorMessage(e));
      return false;
    }
  }

  /// Uploads driver's-licence images for review. Returns the review status, or null on failure.
  Future<VerificationStatus?> submitLicence(List<UploadFile> files) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final status = await _repository.submitVerificationDocuments(files: files, asPartner: false);
      final user = await _repository.getCurrentUser(refresh: true);
      state = state.copyWith(user: user, isLoading: false);
      return status;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseErrorMessage(e));
      return null;
    }
  }

  /// Adopts a user whose session was already stored (e.g. by the social sign-in modal).
  void updateUser(UserModel updatedUser) {
    state = state.copyWith(user: updatedUser, isAuthenticated: true);
  }

  /// Email changes need re-verification and aren't supported here; only name and phone are sent.
  Future<bool> updateProfile({required String fullName, required String phone}) =>
      _run(() => _repository.updateProfile(fullName: fullName, phone: phone));

  Future<void> refreshUser() async {
    try {
      final user = await _repository.getCurrentUser(refresh: true);
      if (user != null) state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = AuthState();
  }
}

final userAuthProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Server-side wallet balance. Invalidate after a top-up to refetch.
final walletProvider = FutureProvider<WalletSummary>((ref) async {
  final auth = ref.watch(userAuthProvider);
  if (!auth.isAuthenticated) return WalletSummary(balance: 0, currency: 'NGN');
  return ref.watch(paymentRepositoryProvider).getWallet();
});

// Vehicle List Provider with Filters
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
  /// Extras the customer asked for (chauffeur, child seat). Not priced by the backend -- they
  /// travel to the partner as a note on the booking request.
  final Set<String> requestedExtras;
  final String paymentMethod;
  final bool isProcessing;
  /// The booking as created by the server (authoritative id and totals).
  final BookingModel? lastBooking;

  String? get lastBookingId => lastBooking?.id;

  BookingDraftState({
    this.selectedCar,
    DateTime? pickupDate,
    DateTime? returnDate,
    this.pickupLocation = '',
    this.dropoffLocation = '',
    this.requestedExtras = const {},
    this.paymentMethod = 'Flutterwave',
    this.isProcessing = false,
    this.lastBooking,
  })  : pickupDate = pickupDate ?? DateTime.now().add(const Duration(days: 1)),
        returnDate = returnDate ?? DateTime.now().add(const Duration(days: 3));

  PricingBreakdown get breakdown => PricingService.calculatePrice(
        baseRatePerDay: selectedCar?.pricePerDay ?? 0,
        pickupDate: pickupDate,
        returnDate: returnDate,
      );

  int get totalDays => breakdown.days;
  bool get hasChauffeur => requestedExtras.contains(chauffeurExtra);
  bool get hasChildSeat => requestedExtras.contains(childSeatExtra);

  static const chauffeurExtra = 'Chauffeur';
  static const childSeatExtra = 'Child seat';

  BookingDraftState copyWith({
    CarModel? selectedCar,
    DateTime? pickupDate,
    DateTime? returnDate,
    String? pickupLocation,
    String? dropoffLocation,
    Set<String>? requestedExtras,
    String? paymentMethod,
    bool? isProcessing,
    BookingModel? lastBooking,
  }) {
    return BookingDraftState(
      selectedCar: selectedCar ?? this.selectedCar,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      requestedExtras: requestedExtras ?? this.requestedExtras,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      lastBooking: lastBooking ?? this.lastBooking,
    );
  }
}

class BookingDraftNotifier extends StateNotifier<BookingDraftState> {
  final IBookingRepository _bookingRepo;
  BookingDraftNotifier(this._bookingRepo) : super(BookingDraftState());

  /// Selecting a car fixes the pickup point: bookings are collected at the listing's location.
  void selectCar(CarModel car) {
    state = BookingDraftState(
      selectedCar: car,
      pickupDate: state.pickupDate,
      returnDate: state.returnDate,
      pickupLocation: car.location,
      dropoffLocation: car.location,
    );
  }

  void setDates(DateTime pickup, DateTime returnD) {
    state = state.copyWith(pickupDate: pickup, returnDate: returnD);
  }

  void setLocations(String pickup, String dropoff) {
    state = state.copyWith(pickupLocation: pickup, dropoffLocation: dropoff);
  }

  void _setExtra(String extra, bool? enabled) {
    final extras = Set<String>.from(state.requestedExtras);
    final on = enabled ?? !extras.contains(extra);
    on ? extras.add(extra) : extras.remove(extra);
    state = state.copyWith(requestedExtras: extras);
  }

  void toggleChauffeur([bool? enabled, double _ = 0]) => _setExtra(BookingDraftState.chauffeurExtra, enabled);
  void toggleChildSeat([bool? enabled, double _ = 0]) => _setExtra(BookingDraftState.childSeatExtra, enabled);

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  /// Creates the booking on the server (status PENDING until the partner confirms). Payment
  /// is then taken for [BookingDraftState.lastBooking] through Flutterwave checkout. Throws
  /// [ApiException] with the server's reason (vehicle unavailable, dates invalid, ...).
  Future<BookingModel?> confirmAndPay({UserModel? user}) async {
    final car = state.selectedCar;
    if (car == null) return null;
    state = state.copyWith(isProcessing: true);
    try {
      final booking = await _bookingRepo.createBooking(
        car: car,
        pickupAt: state.pickupDate,
        dropoffAt: state.returnDate,
        notes: state.requestedExtras.isEmpty ? null : 'Requested extras: ${state.requestedExtras.join(', ')}',
      );
      state = state.copyWith(isProcessing: false, lastBooking: booking);
      return booking;
    } catch (_) {
      state = state.copyWith(isProcessing: false);
      rethrow;
    }
  }
}

final bookingDraftProvider = StateNotifierProvider<BookingDraftNotifier, BookingDraftState>((ref) {
  return BookingDraftNotifier(ref.watch(bookingRepositoryProvider));
});

// The signed-in customer's bookings, refreshed periodically.
final userBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  final auth = ref.watch(userAuthProvider);
  if (!auth.isAuthenticated) return Stream.value(<BookingModel>[]);
  return repo.streamMyBookings();
});

// User Support Tickets Provider
final userSupportTicketsProvider = FutureProvider<List<SupportTicketModel>>((ref) async {
  final repo = ref.watch(supportRepositoryProvider);
  final auth = ref.watch(userAuthProvider);
  if (!auth.isAuthenticated) return <SupportTicketModel>[];
  return repo.getMyTickets();
});

final userNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final auth = ref.watch(userAuthProvider);
  if (!auth.isAuthenticated) return <NotificationModel>[];
  return ref.watch(supportRepositoryProvider).getNotifications();
});

/// The customer's ongoing trip (ACTIVE, else the next CONFIRMED one), from their bookings.
final currentTripProvider = Provider<BookingModel?>((ref) {
  final bookings = ref.watch(userBookingsProvider).valueOrNull ?? const <BookingModel>[];
  for (final status in [BookingStatus.active, BookingStatus.confirmed]) {
    for (final booking in bookings) {
      if (booking.status == status) return booking;
    }
  }
  return null;
});

/// The most recent completed trip -- the one a review is for.
final lastCompletedTripProvider = Provider<BookingModel?>((ref) {
  final bookings = ref.watch(userBookingsProvider).valueOrNull ?? const <BookingModel>[];
  final completed = bookings.where((b) => b.status == BookingStatus.completed).toList()
    ..sort((a, b) => b.endDate.compareTo(a.endDate));
  return completed.isEmpty ? null : completed.first;
});
