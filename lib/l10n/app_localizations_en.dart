// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get findBestRecommendations =>
      'Find the best recommendations place to live';

  @override
  String get featuredEstates => 'Featured Estates';

  @override
  String get nearbyEstate => 'Nearby Estate';

  @override
  String get viewAll => 'View all';

  @override
  String get viewAllOnMap => 'View all apartments on map';

  @override
  String get apartmentsOnMap => 'Apartments on Map';

  @override
  String get noFeaturedEstates => 'No featured estates available';

  @override
  String get noNearbyEstates => 'No nearby estates available';

  @override
  String get noEstatesFound => 'No estates found.';

  @override
  String get notVerified => 'Not Verified';

  @override
  String get verified => 'Verified';

  @override
  String get notVerifiedBanner =>
      'This apartment is not verified yet by Sokon administrator.';

  @override
  String get lookingFor => 'Looking for';

  @override
  String get recent => 'Recent';

  @override
  String get recentSearch => 'Recent Search';

  @override
  String get noApartmentsFound => 'No apartments found';

  @override
  String apartmentsCount(Object count) {
    return '$count apartments';
  }

  @override
  String apartmentsInDistrictCount(Object count) {
    return '$count apartments in this district';
  }

  @override
  String apartmentsOnMapCount(Object count) {
    return '$count apartments with map locations';
  }

  @override
  String get topLocation => 'Top Location';

  @override
  String get noDistrictsFound => 'No districts found';

  @override
  String get noDistrictsAvailable => 'No districts available';

  @override
  String get districtsRanked =>
      'Districts ranked by how many apartments they have';

  @override
  String get aboutThisApartment => 'About this apartment';

  @override
  String get about => 'About';

  @override
  String get facilities => 'Facilities';

  @override
  String get bedrooms => 'Bedrooms';

  @override
  String get bathrooms => 'Bathrooms';

  @override
  String get livingRooms => 'Living rooms';

  @override
  String get bedroom => 'Bedroom';

  @override
  String get bathtub => 'Bathtub';

  @override
  String floor(Object floor) {
    return 'Floor $floor';
  }

  @override
  String get forRent => 'For Rent';

  @override
  String get forSale => 'For Sale';

  @override
  String get noDescription => 'No description available.';

  @override
  String get description => 'Description.';

  @override
  String get ownerContactNotAvailable =>
      'Owner contact information not available';

  @override
  String get ownerNoAddress => 'Owner did not add an address yet.';

  @override
  String get rentNow => 'Rent Now';

  @override
  String reviewsCount(Object count) {
    return '($count reviews)';
  }

  @override
  String get ratingSaved => 'Rating saved';

  @override
  String failedToSaveRating(Object error) {
    return 'Failed to save rating: $error';
  }

  @override
  String get alreadyRented =>
      'You already rented this apartment. You can book it again after your current period ends.';

  @override
  String get pleaseLoginToBook => 'Please login to book';

  @override
  String get openInMap => 'Open in Map';

  @override
  String get takeLookInside => 'Take a look inside';

  @override
  String get confirmAndPay => 'Confirm and Pay';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectDateRange => 'Please select a date range';

  @override
  String get priceDetails => 'Price Details';

  @override
  String get monthlyPayment => 'Monthly payment';

  @override
  String get tax => 'Tax';

  @override
  String get total => 'Total';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get payment => 'Payment';

  @override
  String get payments => 'Payments';

  @override
  String get cardHolder => 'Card Holder';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get validThru => 'VALID THRU';

  @override
  String get enterVoucher => 'Enter a Voucher';

  @override
  String get checkDateBeforePayment =>
      'Make sure to check your date before making any sort of payments';

  @override
  String get noCardAdded => 'No Card Added';

  @override
  String get myBank => 'My Bank';

  @override
  String get addCard => 'Add Card';

  @override
  String get addCardSuccess => 'Card added successfully';

  @override
  String get bookingSuccessTitle => 'Yey, your booking success';

  @override
  String get bookingSuccessSub =>
      'you have successfully booked a property, enjoy your property';

  @override
  String get period => 'Period';

  @override
  String get periodTime => 'Period time';

  @override
  String get people => 'People';

  @override
  String peopleCount(Object count) {
    return 'People: $count';
  }

  @override
  String get rateYourStay => 'Rate your stay';

  @override
  String get yourRating => 'Your rating';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get saveChanges => 'Save Change';

  @override
  String get myApartments => 'My Apartments';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get bookingRequests => 'Booking Requests';

  @override
  String get noBookingsFound => 'No bookings found';

  @override
  String get noApartmentsListed =>
      'You haven\'t listed any apartments yet.\nStart by adding your first property!';

  @override
  String get trackYourApartmentBookings => 'Track your apartment bookings';

  @override
  String get reviewLiveBookingActivity =>
      'Review live booking activity for your apartments';

  @override
  String get manageYourProperties => 'Manage your properties';

  @override
  String get newBookingActivity =>
      'New booking activity for your apartments will appear here in real time.';

  @override
  String get noBookingRequestsYet => 'No booking requests yet';

  @override
  String get pleaseLoginToSeeBookings => 'Please login to see your bookings';

  @override
  String get pleaseLoginToManageRequests =>
      'Please login to manage your booking requests';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get acceptBooking => 'Accept booking';

  @override
  String get rejectBooking => 'Reject booking';

  @override
  String get cancelBooking => 'Cancel Booking';

  @override
  String get confirmAcceptBooking =>
      'Do you want to accept this booking request?';

  @override
  String get confirmRejectBooking =>
      'Do you want to reject this booking request?';

  @override
  String get confirmCancelBooking => 'Do you want to cancel this booking?';

  @override
  String get confirmCancelBookingRequest =>
      'Do you want to cancel this booking request?';

  @override
  String get bookingAccepted => 'Booking accepted';

  @override
  String get bookingCancelled => 'Booking cancelled';

  @override
  String get bookingRejected => 'Booking rejected';

  @override
  String failedToCancelBooking(Object error) {
    return 'Failed to cancel booking: $error';
  }

  @override
  String failedToUpdateBooking(Object error) {
    return 'Failed to update booking: $error';
  }

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete Your Account?';

  @override
  String get deleteAccountWarning =>
      'This action is permanent. All your data including apartments, bookings, chats, and notifications will be deleted forever.';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully';

  @override
  String get addNewListing => 'Add New Listing';

  @override
  String get editListing => 'Edit Listing';

  @override
  String get addApartment => 'Add Apartment';

  @override
  String get updateApartment => 'Update Apartment';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get apartmentNameLabel => 'Apartment Name';

  @override
  String get apartmentNameHint =>
      'Provide a clear, brief name for the apartment (e.g. \'Cozy Private Studio near Faculty of Engineering\'). This will be shown in listings.';

  @override
  String get apartmentNameRequired => 'Apartment name is required';

  @override
  String get propertyDetails => 'Property Details';

  @override
  String get propertyDetailsHint =>
      'Describe the property details. Mention utilities included, rules, roommate details, security deposit, and distance to universities.';

  @override
  String get propertyDetailsPlaceholder =>
      'Describe the property features, view, and utilities...';

  @override
  String get propertyType => 'Property Type';

  @override
  String get monthlyPriceLabel => 'Monthly Price (EGP)';

  @override
  String get monthlyPriceHint =>
      'Enter the rent price per month in Egyptian Pounds (EGP). Be precise about the price.';

  @override
  String get selectFloor =>
      'Select which floor the apartment is located on (e.g. Ground Floor = 0, First Floor = 1, etc.).';

  @override
  String get selectBathrooms =>
      'Select the number of fully functional bathrooms.';

  @override
  String get selectBedrooms => 'Select the number of bedrooms.';

  @override
  String get selectLivingRooms =>
      'Select the number of fully functional living rooms.';

  @override
  String get livingCapacity => 'Living Capacity';

  @override
  String get selectLivingCapacity =>
      'Select the maximum number of people allowed to rent and live in this apartment together.';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get city => 'City';

  @override
  String get selectCity => 'Select the city where the apartment is located.';

  @override
  String get district => 'District';

  @override
  String get selectDistrict =>
      'Select the district or neighborhood of the apartment to help users search by proximity.';

  @override
  String get streetAddressLabel => 'Street number and name';

  @override
  String get streetAddressHint =>
      'Enter the detailed street address, building number, and apartment number so clients can find it easily.';

  @override
  String get pickApartmentLocation => 'Pick Apartment Location';

  @override
  String get tapMapToPlaceMarker =>
      'Tap the map to place the apartment marker.';

  @override
  String get confirmLocation => 'Confirm Location';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get previewSelectedPhotos => 'Preview selected photos';

  @override
  String get pleaseAddOneImage => 'Please add at least one image';

  @override
  String get addVideo => 'Add Video';

  @override
  String get videoAdded => 'Video Added';

  @override
  String get videoDurationLimit =>
      'The video duration should not exceed 10 minutes.';

  @override
  String get savingApartmentData => 'Saving apartment data...';

  @override
  String get updatingApartmentData => 'Updating apartment data...';

  @override
  String get deleteListingTitle => 'Delete Listing';

  @override
  String get deleteListingConfirm =>
      'Are you sure you want to delete this property? This action cannot be undone and the listing will be removed immediately.';

  @override
  String get pleaseLoginBeforeAdding =>
      'Please login again before adding an apartment.';

  @override
  String get pleaseLoginBeforeUpdating =>
      'Please login again before updating this apartment.';

  @override
  String get capacityLowerThanRenters =>
      'People capacity cannot be lower than the number already renting this apartment.';

  @override
  String onlyAvailableCapacity(Object count) {
    return 'Only $count people can be added to this apartment right now.';
  }

  @override
  String get peopleRenting => 'People renting';

  @override
  String get fullyBooked => 'Fully Booked';

  @override
  String get thisApartmentFullyBooked => 'This apartment is fully booked.';

  @override
  String get pickYourLocation => 'Pick Your Location';

  @override
  String get tapMapConfirmLocation =>
      'Tap the map, then confirm your location.';

  @override
  String get confirm => 'Confirm';

  @override
  String get loadingSelectedAddress => 'Loading selected address...';

  @override
  String selectedOnMap(Object address) {
    return 'Selected on map: $address';
  }

  @override
  String get noLocationSelected => 'No location selected yet.';

  @override
  String get myLocation => 'My Location';

  @override
  String get userLocation => 'User Location';

  @override
  String get startConversation => 'Start the conversation';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get savedChat => 'Saved chat';

  @override
  String get sentPhoto => 'Sent a photo';

  @override
  String get unableToSendPhoto => 'Unable to send photo';

  @override
  String errorLoadingChats(Object error) {
    return 'Error loading chats: $error';
  }

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'Ok';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get submit => 'Submit';

  @override
  String get continueButton => 'Continue';

  @override
  String get finish => 'Finish';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get loading => 'Loading...';

  @override
  String get processing => 'Processing...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String errorLabel(Object error) {
    return 'Error: $error';
  }

  @override
  String get noAddress => 'No Address';

  @override
  String get noName => 'No Name';

  @override
  String get noEmail => 'No Email';

  @override
  String get unknown => 'Unknown';

  @override
  String get videoPlaybackFailed => 'Video playback failed.';

  @override
  String get videoPlaybackUnavailable => 'Video playback is unavailable.';

  @override
  String get couldNotOpenGoogleMaps => 'Could not open Google Maps';

  @override
  String get selectUniversity =>
      'Select your University to get the apartment near by your University';

  @override
  String get assiutUniversity => 'Assiut University';

  @override
  String get assiutNationalUniversity => 'Assiut National University';

  @override
  String get badrUniversityAssiut => 'Badr University Assiut';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordValidation =>
      'Password must be at least 8 characters and include letters and numbers';

  @override
  String get passwordsNotMatching => 'Passwords do not match';

  @override
  String get enterValidUsername => 'Enter a valid username';

  @override
  String get enterNumbersOnly => 'Enter numbers only';

  @override
  String get phoneValidation => 'Phone number must be 11 digits';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get enterEmailAddress => 'Enter your email address';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get selectYourRole => 'Select your role';

  @override
  String get owner => 'Owner';

  @override
  String get client => 'Client';

  @override
  String get signUp => 'Sign Up';

  @override
  String get username => 'Username';

  @override
  String get role => 'Role';

  @override
  String get college => 'College';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get selectedMedia => 'Selected Media';

  @override
  String get apartmentNameHintText => 'e.g. Modern Studio in Downtown';

  @override
  String get zeroPriceHint => '0.00';

  @override
  String get assiutHint => 'e.g. Assuit';

  @override
  String get cityHint => 'e.g. City';

  @override
  String get noVideoAvailable => 'No video available';

  @override
  String get address => 'Address';

  @override
  String get booking => 'Booking';

  @override
  String get date => 'Date';

  @override
  String get noApartmentsInDistrict => 'No apartments found in this district';

  @override
  String get noFeaturedApartmentsFound => 'No featured apartments found';

  @override
  String get noApartmentsFoundNearby => 'No apartments found';

  @override
  String get announcement => 'Announcement';

  @override
  String get newApartment => 'New Apartment';

  @override
  String get bookingRequestReceived => 'Booking Request Received';

  @override
  String get bookingApproved => 'Booking Approved';

  @override
  String get newMessage => 'New Message';

  @override
  String get fit => 'Fit';

  @override
  String get messages => 'Messages';

  @override
  String get search => 'Search';

  @override
  String get cardNumberPlaceholder => 'XXXX XXXX XXXX XXXX';

  @override
  String get expiryDatePlaceholder => 'MM/YY';

  @override
  String get cvvLabel => 'CVV';

  @override
  String get cvvPlaceholder => 'XXX';

  @override
  String get acceptedStatus => 'ACCEPTED';

  @override
  String get cancelledStatus => 'CANCELLED';

  @override
  String get pendingStatus => 'PENDING';

  @override
  String get bookingIdRequired => 'Booking ID is required';

  @override
  String get gender => 'Gender';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get result => 'Result';

  @override
  String get priceRange => 'Price Range';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Have an account?';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get logout => 'Logout';

  @override
  String get notification => 'Notification';

  @override
  String get aboutMenu => 'About';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get close => 'Close';

  @override
  String get uploading => 'Uploading...';

  @override
  String get updating => 'Updating...';

  @override
  String get sendingOtp => 'Sending OTP...';

  @override
  String get verifyingOtp => 'Verifying OTP...';

  @override
  String get updatingPassword => 'Updating password...';

  @override
  String get apartmentAddedSuccess => 'Apartment added successfully';

  @override
  String get apartmentUpdatedSuccess => 'Apartment updated successfully';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get enterPasswordToConfirm => 'Enter your password to confirm:';

  @override
  String get passwordResetSuccess =>
      'Password reset successfully. Please login with your new password.';

  @override
  String get verification => 'Verification';

  @override
  String get verificationDesc =>
      '* We will send you a message to reset your password';

  @override
  String get enterCodeSent => 'Enter the 6-digit code sent to:';

  @override
  String resendCodeIn(Object seconds) {
    return 'Resend code in $seconds s';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get register => 'Register';

  @override
  String get pleaseSelectRole => 'Please select a role';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get pleaseFillAllFields => 'Please fill all fields';

  @override
  String get invalidEmailOrPassword => 'Invalid email or password';

  @override
  String get failedToUploadImage => 'Failed to upload image';

  @override
  String get failedToUploadVideo => 'Failed to upload video';

  @override
  String get egp => 'EGP';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(Object count) {
    return '${count}d ago';
  }
}
