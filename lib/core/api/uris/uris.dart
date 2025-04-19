import 'package:mentor_mobile_app/imports_bindings.dart';

///* This class contains Api uris
@immutable
final class ApiUris {
  ///* BASE URL
  static const _baseUrl = String.fromEnvironment('baseUrl');

  ///============================= AUTH MODULE =============================\\\
  ///* Send OTP
  static const loginSendOtp = '$_baseUrl/auth/verification/mobile/';

  ///* Verify OTP
  static const verifyOTP = '$_baseUrl/auth/verification/mobile/confirm/';

  ///* Verify OTP
  static const customerOrVendorReg = '$_baseUrl/auth/registration/';

  ///* Send OTP to Mail
  static const sendOtpToMail = '$_baseUrl/auth/verification/email/';

  ///* Mail OTP verification
  static const mailOtpVerification = '$_baseUrl/auth/verification/email/confirm/';

  ///* Logout
  static const logout = '$_baseUrl/auth/logout/';

  /// ============================ ADDRESS MODULE ============================ \\\
  ///* Create Address
  static const addressCrud = '$_baseUrl/address/';

  /// ============================ profile MODULE ============================ \\\
  /// get customer details
  static const customerProfile = '$_baseUrl/customer/';

  /// get vendor details
  static const vendorProfile = '$_baseUrl/vendor/vendors/';

  /// =========================Vendor product Management MODULE ============================ \\\
  static const myProductsList = '$_baseUrl/catalogue/vendor-product-management/';

  ///* Product Variant List
  static const productVariantList = '$_baseUrl/catalogue/vendor-product-stock/';

  ///* Update Product Stock
  static const updateProductStock = '$_baseUrl/catalogue/vendor-product-stock-update/';

  ///* Product
  static String productDetails(String id) => '$_baseUrl/catalogue/product/$id/';
  static String vendorProductDetails(String id) => '$_baseUrl/catalogue/vendor-product-details/$id/';
  static const productReviews = '$_baseUrl/catalogue/product-review/';
  static const productSearchSuggestions = '$_baseUrl/catalogue/products/suggestions/';
  static const productsList = '$_baseUrl/catalogue/products/';
  static const filterOptions = '$_baseUrl/catalogue/filter-options/';
  static const categoriesList = '$_baseUrl/catalogue/category-list/';

  /// ============================ profile MODULE ============================ \\\

  /// update vendor detials
  static const vendorUpadteProfile = '$_baseUrl/vendor/vendors/update/';

  /// Global product listing
  static const globalProductListing = '$_baseUrl/catalogue/global-product-management/';

  ///* Add To Local Product
  static const addToLocalProduct = '$_baseUrl/catalogue/vendor-product-onboards/';
  static const removeProductFromWishlist = '$_baseUrl/wishlists/wishlist/';

  ///* Wishlist
  static const wishlistProducts = '$_baseUrl/wishlists/wishlist/';

  ///* Cart
  static const manageProductToCart = '$_baseUrl/basket/add-product/';
  static const fetchCartProducts = '$_baseUrl/basket/get-basket/';

  ///* Basket
  static const fetchBasket = '$_baseUrl/basket/get-basket/';
  static const manageProductBasket = '$_baseUrl/basket/add-product/';

  ///* ============================ Stock Management ============================ \\\
  static const stockManagementProduct = '$_baseUrl/catalogue/stock-management/';

  ///* ============================ RFQ MODULE ============================ \\\
  ///* Create RFQ
  static const createRfq = '$_baseUrl/rfq/create-rfq/';

  ///* Get RFQ List
  static const getRfq = '$_baseUrl/rfq/';

  ///* Get RFQ Details
  static String getRfqDetails(String id) => '$_baseUrl/rfq/$id/';

  ///* search rfq products
  static const searchRfqProducts = '$_baseUrl/rfq/search-product/';

  ///* ============================ Order Management ============================ \\\
  static const validateCheckout = '$_baseUrl/basket/validate-checkout/';

  static const createOrder = '$_baseUrl/payment/create-order/';

  static const checkCustomerPaymentStatus = '$_baseUrl/payment/payment-success/';

  static const findPaymentPercentage = '$_baseUrl/administrator/site-config/';

  static const customerOrdersListing = '$_baseUrl/order/';

  static String customerOrderDetails(int id) => '$_baseUrl/order/$id/';

  static const fetchPaymentConfigs = 'https://marketplace.dn.fegno.com/api/v1/administrator/site-config/';
}
