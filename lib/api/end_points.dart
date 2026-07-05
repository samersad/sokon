class EndPoints {
  static const String registerApi = "/auth/register";
  static const String loginApi = "/auth/login";
  static const String authExchangeApi = "/auth/exchange";
  static const String meApi = "/auth/me";
  static const String logoutApi = "/auth/logout";
  static const String passwordResetApi = "/auth/password-reset";
  static const String passwordResetVerifyOtpApi =
      "/auth/password-reset/verify-otp";
  static const String passwordResetConfirmApi = "/auth/password-reset/confirm";
  static const String phoneOtpApi = "/auth/phone/send-otp";
  static const String phoneOtpVerifyApi = "/auth/phone/verify-otp";
  static const String passwordApi = "/auth/password";
  static const String deleteAccountApi = "/auth/account";
  static const String usersApi = "/users";
  static const String apartmentsApi = "/apartments";
  static const String apartmentsSearchApi = "/apartments/search";
  static const String bookingsApi = "/bookings";
  static const String chatsApi = "/chats";
  static const String messagesApi = "/messages";
  static const String notificationsApi = "/notifications";
  static const String bookingActiveCheckApi = "/bookings/active/check";
  static const String updateBookingStatusWithCapacityApi =
      "/rpc/update_booking_status_with_capacity";

  static String userApi(String userId) => "/users/$userId";
  static String apartmentApi(String apartmentId) => "/apartments/$apartmentId";
  static String apartmentVerifyApi(String apartmentId) =>
      "/apartments/$apartmentId/verify";
  static String bookingStatusApi(String bookingId) =>
      "/bookings/$bookingId/status";
  static String bookingRatingApi(String bookingId) =>
      "/bookings/$bookingId/rating";
  static String chatApi(String chatId) => "/chats/$chatId";
  static String chatMessagesApi(String chatId) => "/chats/$chatId/messages";
  static String messageApi(String messageId) => "/messages/$messageId";
  static String notificationReadApi(String notificationId) =>
      "/notifications/$notificationId/read";
  static String notificationsReadAllApi(String userId) =>
      "/notifications/read-all/$userId";
}
