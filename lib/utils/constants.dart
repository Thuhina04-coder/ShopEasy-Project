class AppConstants {
  static const String appName = 'ShopEasy';
  static const String currency = 'LKR';
  static const String currencySymbol = 'Rs.';
  static const double shippingFee = 350.0;
  static const double freeShippingThreshold = 5000.0;

  static String formatPrice(double price) {
    return '$currencySymbol ${price.toStringAsFixed(2)}';
  }
}
