import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @findBestRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Find the best recommendations place to live'**
  String get findBestRecommendations;

  /// No description provided for @featuredEstates.
  ///
  /// In en, this message translates to:
  /// **'Featured Estates'**
  String get featuredEstates;

  /// No description provided for @nearbyEstate.
  ///
  /// In en, this message translates to:
  /// **'Nearby Estate'**
  String get nearbyEstate;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @viewAllOnMap.
  ///
  /// In en, this message translates to:
  /// **'View all apartments on map'**
  String get viewAllOnMap;

  /// No description provided for @apartmentsOnMap.
  ///
  /// In en, this message translates to:
  /// **'Apartments on Map'**
  String get apartmentsOnMap;

  /// No description provided for @noFeaturedEstates.
  ///
  /// In en, this message translates to:
  /// **'No featured estates available'**
  String get noFeaturedEstates;

  /// No description provided for @noNearbyEstates.
  ///
  /// In en, this message translates to:
  /// **'No nearby estates available'**
  String get noNearbyEstates;

  /// No description provided for @noEstatesFound.
  ///
  /// In en, this message translates to:
  /// **'No estates found.'**
  String get noEstatesFound;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get notVerified;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @notVerifiedBanner.
  ///
  /// In en, this message translates to:
  /// **'This apartment is not verified yet by Sokon administrator.'**
  String get notVerifiedBanner;

  /// No description provided for @lookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get lookingFor;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @recentSearch.
  ///
  /// In en, this message translates to:
  /// **'Recent Search'**
  String get recentSearch;

  /// No description provided for @noApartmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No apartments found'**
  String get noApartmentsFound;

  /// No description provided for @topLocation.
  ///
  /// In en, this message translates to:
  /// **'Top Location'**
  String get topLocation;

  /// No description provided for @noDistrictsFound.
  ///
  /// In en, this message translates to:
  /// **'No districts found'**
  String get noDistrictsFound;

  /// No description provided for @noDistrictsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No districts available'**
  String get noDistrictsAvailable;

  /// No description provided for @districtsRanked.
  ///
  /// In en, this message translates to:
  /// **'Districts ranked by how many apartments they have'**
  String get districtsRanked;

  /// No description provided for @aboutThisApartment.
  ///
  /// In en, this message translates to:
  /// **'About this apartment'**
  String get aboutThisApartment;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities;

  /// No description provided for @bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// No description provided for @livingRooms.
  ///
  /// In en, this message translates to:
  /// **'Living rooms'**
  String get livingRooms;

  /// No description provided for @bedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get bedroom;

  /// No description provided for @bathtub.
  ///
  /// In en, this message translates to:
  /// **'Bathtub'**
  String get bathtub;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor {floor}'**
  String floor(Object floor);

  /// No description provided for @forRent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get forRent;

  /// No description provided for @forSale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get forSale;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescription;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description.'**
  String get description;

  /// No description provided for @ownerContactNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Owner contact information not available'**
  String get ownerContactNotAvailable;

  /// No description provided for @ownerNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Owner did not add an address yet.'**
  String get ownerNoAddress;

  /// No description provided for @rentNow.
  ///
  /// In en, this message translates to:
  /// **'Rent Now'**
  String get rentNow;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String reviewsCount(Object count);

  /// No description provided for @ratingSaved.
  ///
  /// In en, this message translates to:
  /// **'Rating saved'**
  String get ratingSaved;

  /// No description provided for @failedToSaveRating.
  ///
  /// In en, this message translates to:
  /// **'Failed to save rating: {error}'**
  String failedToSaveRating(Object error);

  /// No description provided for @alreadyRented.
  ///
  /// In en, this message translates to:
  /// **'You already rented this apartment. You can book it again after your current period ends.'**
  String get alreadyRented;

  /// No description provided for @pleaseLoginToBook.
  ///
  /// In en, this message translates to:
  /// **'Please login to book'**
  String get pleaseLoginToBook;

  /// No description provided for @openInMap.
  ///
  /// In en, this message translates to:
  /// **'Open in Map'**
  String get openInMap;

  /// No description provided for @takeLookInside.
  ///
  /// In en, this message translates to:
  /// **'Take a look inside'**
  String get takeLookInside;

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Pay'**
  String get confirmAndPay;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Please select a date range'**
  String get selectDateRange;

  /// No description provided for @priceDetails.
  ///
  /// In en, this message translates to:
  /// **'Price Details'**
  String get priceDetails;

  /// No description provided for @monthlyPayment.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment'**
  String get monthlyPayment;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'Card Holder'**
  String get cardHolder;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @validThru.
  ///
  /// In en, this message translates to:
  /// **'VALID THRU'**
  String get validThru;

  /// No description provided for @enterVoucher.
  ///
  /// In en, this message translates to:
  /// **'Enter a Voucher'**
  String get enterVoucher;

  /// No description provided for @checkDateBeforePayment.
  ///
  /// In en, this message translates to:
  /// **'Make sure to check your date before making any sort of payments'**
  String get checkDateBeforePayment;

  /// No description provided for @noCardAdded.
  ///
  /// In en, this message translates to:
  /// **'No Card Added'**
  String get noCardAdded;

  /// No description provided for @myBank.
  ///
  /// In en, this message translates to:
  /// **'My Bank'**
  String get myBank;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @addCardSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get addCardSuccess;

  /// No description provided for @bookingSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Yey, your booking success'**
  String get bookingSuccessTitle;

  /// No description provided for @bookingSuccessSub.
  ///
  /// In en, this message translates to:
  /// **'you have successfully booked a property, enjoy your property'**
  String get bookingSuccessSub;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @periodTime.
  ///
  /// In en, this message translates to:
  /// **'Period time'**
  String get periodTime;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'People: {count}'**
  String peopleCount(Object count);

  /// No description provided for @rateYourStay.
  ///
  /// In en, this message translates to:
  /// **'Rate your stay'**
  String get rateYourStay;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Change'**
  String get saveChanges;

  /// No description provided for @myApartments.
  ///
  /// In en, this message translates to:
  /// **'My Apartments'**
  String get myApartments;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @bookingRequests.
  ///
  /// In en, this message translates to:
  /// **'Booking Requests'**
  String get bookingRequests;

  /// No description provided for @noBookingsFound.
  ///
  /// In en, this message translates to:
  /// **'No bookings found'**
  String get noBookingsFound;

  /// No description provided for @noApartmentsListed.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t listed any apartments yet.\nStart by adding your first property!'**
  String get noApartmentsListed;

  /// No description provided for @trackYourApartmentBookings.
  ///
  /// In en, this message translates to:
  /// **'Track your apartment bookings'**
  String get trackYourApartmentBookings;

  /// No description provided for @reviewLiveBookingActivity.
  ///
  /// In en, this message translates to:
  /// **'Review live booking activity for your apartments'**
  String get reviewLiveBookingActivity;

  /// No description provided for @manageYourProperties.
  ///
  /// In en, this message translates to:
  /// **'Manage your properties'**
  String get manageYourProperties;

  /// No description provided for @newBookingActivity.
  ///
  /// In en, this message translates to:
  /// **'New booking activity for your apartments will appear here in real time.'**
  String get newBookingActivity;

  /// No description provided for @noBookingRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No booking requests yet'**
  String get noBookingRequestsYet;

  /// No description provided for @pleaseLoginToSeeBookings.
  ///
  /// In en, this message translates to:
  /// **'Please login to see your bookings'**
  String get pleaseLoginToSeeBookings;

  /// No description provided for @pleaseLoginToManageRequests.
  ///
  /// In en, this message translates to:
  /// **'Please login to manage your booking requests'**
  String get pleaseLoginToManageRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @acceptBooking.
  ///
  /// In en, this message translates to:
  /// **'Accept booking'**
  String get acceptBooking;

  /// No description provided for @rejectBooking.
  ///
  /// In en, this message translates to:
  /// **'Reject booking'**
  String get rejectBooking;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBooking;

  /// No description provided for @confirmAcceptBooking.
  ///
  /// In en, this message translates to:
  /// **'Do you want to accept this booking request?'**
  String get confirmAcceptBooking;

  /// No description provided for @confirmRejectBooking.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reject this booking request?'**
  String get confirmRejectBooking;

  /// No description provided for @confirmCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel this booking?'**
  String get confirmCancelBooking;

  /// No description provided for @confirmCancelBookingRequest.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel this booking request?'**
  String get confirmCancelBookingRequest;

  /// No description provided for @bookingAccepted.
  ///
  /// In en, this message translates to:
  /// **'Booking accepted'**
  String get bookingAccepted;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get bookingCancelled;

  /// No description provided for @bookingRejected.
  ///
  /// In en, this message translates to:
  /// **'Booking rejected'**
  String get bookingRejected;

  /// No description provided for @failedToCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel booking: {error}'**
  String failedToCancelBooking(Object error);

  /// No description provided for @failedToUpdateBooking.
  ///
  /// In en, this message translates to:
  /// **'Failed to update booking: {error}'**
  String failedToUpdateBooking(Object error);

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Your Account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. All your data including apartments, bookings, chats, and notifications will be deleted forever.'**
  String get deleteAccountWarning;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccess;

  /// No description provided for @addNewListing.
  ///
  /// In en, this message translates to:
  /// **'Add New Listing'**
  String get addNewListing;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editListing;

  /// No description provided for @addApartment.
  ///
  /// In en, this message translates to:
  /// **'Add Apartment'**
  String get addApartment;

  /// No description provided for @updateApartment.
  ///
  /// In en, this message translates to:
  /// **'Update Apartment'**
  String get updateApartment;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @apartmentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Apartment Name'**
  String get apartmentNameLabel;

  /// No description provided for @apartmentNameHint.
  ///
  /// In en, this message translates to:
  /// **'Provide a clear, brief name for the apartment (e.g. \'Cozy Private Studio near Faculty of Engineering\'). This will be shown in listings.'**
  String get apartmentNameHint;

  /// No description provided for @apartmentNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Apartment name is required'**
  String get apartmentNameRequired;

  /// No description provided for @propertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetails;

  /// No description provided for @propertyDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the property details. Mention utilities included, rules, roommate details, security deposit, and distance to universities.'**
  String get propertyDetailsHint;

  /// No description provided for @propertyDetailsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the property features, view, and utilities...'**
  String get propertyDetailsPlaceholder;

  /// No description provided for @propertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyType;

  /// No description provided for @monthlyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Price (EGP)'**
  String get monthlyPriceLabel;

  /// No description provided for @monthlyPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the rent price per month in Egyptian Pounds (EGP). Be precise about the price.'**
  String get monthlyPriceHint;

  /// No description provided for @selectFloor.
  ///
  /// In en, this message translates to:
  /// **'Select which floor the apartment is located on (e.g. Ground Floor = 0, First Floor = 1, etc.).'**
  String get selectFloor;

  /// No description provided for @selectBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Select the number of fully functional bathrooms.'**
  String get selectBathrooms;

  /// No description provided for @selectBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Select the number of bedrooms.'**
  String get selectBedrooms;

  /// No description provided for @selectLivingRooms.
  ///
  /// In en, this message translates to:
  /// **'Select the number of fully functional living rooms.'**
  String get selectLivingRooms;

  /// No description provided for @livingCapacity.
  ///
  /// In en, this message translates to:
  /// **'Living Capacity'**
  String get livingCapacity;

  /// No description provided for @selectLivingCapacity.
  ///
  /// In en, this message translates to:
  /// **'Select the maximum number of people allowed to rent and live in this apartment together.'**
  String get selectLivingCapacity;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select the city where the apartment is located.'**
  String get selectCity;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select the district or neighborhood of the apartment to help users search by proximity.'**
  String get selectDistrict;

  /// No description provided for @streetAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Street number and name'**
  String get streetAddressLabel;

  /// No description provided for @streetAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the detailed street address, building number, and apartment number so clients can find it easily.'**
  String get streetAddressHint;

  /// No description provided for @pickApartmentLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Apartment Location'**
  String get pickApartmentLocation;

  /// No description provided for @tapMapToPlaceMarker.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place the apartment marker.'**
  String get tapMapToPlaceMarker;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @previewSelectedPhotos.
  ///
  /// In en, this message translates to:
  /// **'Preview selected photos'**
  String get previewSelectedPhotos;

  /// No description provided for @pleaseAddOneImage.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one image'**
  String get pleaseAddOneImage;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @videoAdded.
  ///
  /// In en, this message translates to:
  /// **'Video Added'**
  String get videoAdded;

  /// No description provided for @videoDurationLimit.
  ///
  /// In en, this message translates to:
  /// **'The video duration should not exceed 10 minutes.'**
  String get videoDurationLimit;

  /// No description provided for @savingApartmentData.
  ///
  /// In en, this message translates to:
  /// **'Saving apartment data...'**
  String get savingApartmentData;

  /// No description provided for @updatingApartmentData.
  ///
  /// In en, this message translates to:
  /// **'Updating apartment data...'**
  String get updatingApartmentData;

  /// No description provided for @deleteListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get deleteListingTitle;

  /// No description provided for @deleteListingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this property? This action cannot be undone and the listing will be removed immediately.'**
  String get deleteListingConfirm;

  /// No description provided for @pleaseLoginBeforeAdding.
  ///
  /// In en, this message translates to:
  /// **'Please login again before adding an apartment.'**
  String get pleaseLoginBeforeAdding;

  /// No description provided for @pleaseLoginBeforeUpdating.
  ///
  /// In en, this message translates to:
  /// **'Please login again before updating this apartment.'**
  String get pleaseLoginBeforeUpdating;

  /// No description provided for @capacityLowerThanRenters.
  ///
  /// In en, this message translates to:
  /// **'People capacity cannot be lower than the number already renting this apartment.'**
  String get capacityLowerThanRenters;

  /// No description provided for @onlyAvailableCapacity.
  ///
  /// In en, this message translates to:
  /// **'Only {count} people can be added to this apartment right now.'**
  String onlyAvailableCapacity(Object count);

  /// No description provided for @peopleRenting.
  ///
  /// In en, this message translates to:
  /// **'People renting'**
  String get peopleRenting;

  /// No description provided for @fullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Fully Booked'**
  String get fullyBooked;

  /// No description provided for @thisApartmentFullyBooked.
  ///
  /// In en, this message translates to:
  /// **'This apartment is fully booked.'**
  String get thisApartmentFullyBooked;

  /// No description provided for @pickYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Your Location'**
  String get pickYourLocation;

  /// No description provided for @tapMapConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap the map, then confirm your location.'**
  String get tapMapConfirmLocation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loadingSelectedAddress.
  ///
  /// In en, this message translates to:
  /// **'Loading selected address...'**
  String get loadingSelectedAddress;

  /// No description provided for @selectedOnMap.
  ///
  /// In en, this message translates to:
  /// **'Selected on map: {address}'**
  String selectedOnMap(Object address);

  /// No description provided for @noLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'No location selected yet.'**
  String get noLocationSelected;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @userLocation.
  ///
  /// In en, this message translates to:
  /// **'User Location'**
  String get userLocation;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get startConversation;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @savedChat.
  ///
  /// In en, this message translates to:
  /// **'Saved chat'**
  String get savedChat;

  /// No description provided for @sentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Sent a photo'**
  String get sentPhoto;

  /// No description provided for @unableToSendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Unable to send photo'**
  String get unableToSendPhoto;

  /// No description provided for @errorLoadingChats.
  ///
  /// In en, this message translates to:
  /// **'Error loading chats: {error}'**
  String errorLoadingChats(Object error);

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(Object error);

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'No Address'**
  String get noAddress;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @videoPlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'Video playback failed.'**
  String get videoPlaybackFailed;

  /// No description provided for @videoPlaybackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Video playback is unavailable.'**
  String get videoPlaybackUnavailable;

  /// No description provided for @couldNotOpenGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps'**
  String get couldNotOpenGoogleMaps;

  /// No description provided for @selectUniversity.
  ///
  /// In en, this message translates to:
  /// **'Select your University to get the apartment near by your University'**
  String get selectUniversity;

  /// No description provided for @assiutUniversity.
  ///
  /// In en, this message translates to:
  /// **'Assiut University'**
  String get assiutUniversity;

  /// No description provided for @assiutNationalUniversity.
  ///
  /// In en, this message translates to:
  /// **'Assiut National University'**
  String get assiutNationalUniversity;

  /// No description provided for @badrUniversityAssiut.
  ///
  /// In en, this message translates to:
  /// **'Badr University Assiut'**
  String get badrUniversityAssiut;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters and include letters and numbers'**
  String get passwordValidation;

  /// No description provided for @passwordsNotMatching.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatching;

  /// No description provided for @enterValidUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid username'**
  String get enterValidUsername;

  /// No description provided for @enterNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Enter numbers only'**
  String get enterNumbersOnly;

  /// No description provided for @phoneValidation.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 11 digits'**
  String get phoneValidation;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddress;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @selectYourRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get selectYourRole;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @college.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get college;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @selectedMedia.
  ///
  /// In en, this message translates to:
  /// **'Selected Media'**
  String get selectedMedia;

  /// No description provided for @apartmentNameHintText.
  ///
  /// In en, this message translates to:
  /// **'e.g. Modern Studio in Downtown'**
  String get apartmentNameHintText;

  /// No description provided for @zeroPriceHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get zeroPriceHint;

  /// No description provided for @assiutHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Assuit'**
  String get assiutHint;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. City'**
  String get cityHint;

  /// No description provided for @noVideoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No video available'**
  String get noVideoAvailable;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @noApartmentsInDistrict.
  ///
  /// In en, this message translates to:
  /// **'No apartments found in this district'**
  String get noApartmentsInDistrict;

  /// No description provided for @noFeaturedApartmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No featured apartments found'**
  String get noFeaturedApartmentsFound;

  /// No description provided for @noApartmentsFoundNearby.
  ///
  /// In en, this message translates to:
  /// **'No apartments found'**
  String get noApartmentsFoundNearby;

  /// No description provided for @announcement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcement;

  /// No description provided for @newApartment.
  ///
  /// In en, this message translates to:
  /// **'New Apartment'**
  String get newApartment;

  /// No description provided for @bookingRequestReceived.
  ///
  /// In en, this message translates to:
  /// **'Booking Request Received'**
  String get bookingRequestReceived;

  /// No description provided for @bookingApproved.
  ///
  /// In en, this message translates to:
  /// **'Booking Approved'**
  String get bookingApproved;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @fit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get fit;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @cardNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'XXXX XXXX XXXX XXXX'**
  String get cardNumberPlaceholder;

  /// No description provided for @expiryDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryDatePlaceholder;

  /// No description provided for @cvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvvLabel;

  /// No description provided for @cvvPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'XXX'**
  String get cvvPlaceholder;

  /// No description provided for @acceptedStatus.
  ///
  /// In en, this message translates to:
  /// **'ACCEPTED'**
  String get acceptedStatus;

  /// No description provided for @cancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get cancelledStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pendingStatus;

  /// No description provided for @bookingIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Booking ID is required'**
  String get bookingIdRequired;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account?'**
  String get haveAccount;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @aboutMenu.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutMenu;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @sendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP...'**
  String get sendingOtp;

  /// No description provided for @verifyingOtp.
  ///
  /// In en, this message translates to:
  /// **'Verifying OTP...'**
  String get verifyingOtp;

  /// No description provided for @updatingPassword.
  ///
  /// In en, this message translates to:
  /// **'Updating password...'**
  String get updatingPassword;

  /// No description provided for @apartmentAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Apartment added successfully'**
  String get apartmentAddedSuccess;

  /// No description provided for @apartmentUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Apartment updated successfully'**
  String get apartmentUpdatedSuccess;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @enterPasswordToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm:'**
  String get enterPasswordToConfirm;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. Please login with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @verificationDesc.
  ///
  /// In en, this message translates to:
  /// **'* We will send you a message to reset your password'**
  String get verificationDesc;

  /// No description provided for @enterCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to:'**
  String get enterCodeSent;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds} s'**
  String resendCodeIn(Object seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @pleaseSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get pleaseSelectRole;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidEmailOrPassword;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get failedToUploadImage;

  /// No description provided for @failedToUploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload video'**
  String get failedToUploadVideo;

  /// No description provided for @egp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get egp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
