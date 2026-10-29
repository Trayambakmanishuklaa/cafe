class ApiConstants {
  // Live Render Backend URL
  static const String baseUrl = 'https://cafe-6jer.onrender.com/api/v1';

  // Auth Endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String me = '$baseUrl/auth/me';

  // Categories & Products
  static const String categories = '$baseUrl/categories';
  static const String products = '$baseUrl/products';
  static const String combos = '$baseUrl/products/combos';

  // Orders
  static const String orders = '$baseUrl/orders';
  static const String myOrders = '$baseUrl/orders/my';

  // Bookings & Seating
  static const String tables = '$baseUrl/bookings/tables';
  static const String checkAvailability = '$baseUrl/bookings/availability';
  static const String createHold = '$baseUrl/bookings/hold';
  static const String bookings = '$baseUrl/bookings';
  static const String myBookings = '$baseUrl/bookings/my';

  // Payments
  static const String createPayment = '$baseUrl/payments/create';
  static const String verifyPayment = '$baseUrl/payments/verify';

  // Loyalty & Passport
  static const String loyaltyPassport = '$baseUrl/loyalty/me';
  static const String rewards = '$baseUrl/loyalty/rewards';
  static const String redeemReward = '$baseUrl/loyalty/redeem';

  // Storage Keys
  static const String tokenKey = 'CAFE_AUTH_TOKEN';
  static const String userKey = 'CAFE_USER_DATA';
}
