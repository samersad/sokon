import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/cache/shared_prefs_helper.dart';
import 'package:sokon/core/model/ApartmentResponse.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/cloudinary_service.dart';
import '../../../../../data/repository/apartment/repository/apartment_repository.dart';
import 'package:video_player/video_player.dart';
import 'add_apartment_states.dart';
import '../../../../../core/cache/cubit_manger/location_view_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

@injectable
class AddApartmentViewModel extends Cubit<AddApartmentStates> {
  static const String fixedCity = 'Assuit';
  static const List<String> districtOptions = [
    'فريال',
    'سيتي',
    'سيد',
    'الجمهوريه',
    'يسري راغب',
    'آخر',
  ];
  final ApartmentRepository apartmentRepository;

  AddApartmentViewModel(this.apartmentRepository) : super(AddApartmentInitial());

  final ImagePicker _videoPicker = ImagePicker();
  final ImagePicker _imagePicker = ImagePicker();

  List<File> apartmentImages = [];
  List<String>? existingImageUrls;
  String? existingVideoUrl;
  
  int bedrooms = 1;
  int bathrooms = 1;
  int livingRooms = 1;
  int floor = 1;
  int maxPeople = 1;
  int _reservedPeople = 0;
  bool verified = false;

  final TextEditingController nameCRl = TextEditingController();
  final TextEditingController descriptionCRl = TextEditingController();
  final TextEditingController priceCRl = TextEditingController();
  final TextEditingController addressCRl = TextEditingController();
  final TextEditingController cityCRl = TextEditingController(text: fixedCity);
  final TextEditingController districtCRl = TextEditingController(text: districtOptions.first);
  final TextEditingController floorCRl = TextEditingController(text: '1');

  File? videoFile;

  void clearData() {
    nameCRl.clear();
    descriptionCRl.clear();
    priceCRl.clear();
    addressCRl.clear();
    cityCRl.text = fixedCity;
    districtCRl.text = districtOptions.first;
    floor = 1;
    floorCRl.text = '1';
    verified = false;
    apartmentImages.clear();
    existingImageUrls = null;
    existingVideoUrl = null;
    videoFile = null;
    bedrooms = 1;
    bathrooms = 1;
    livingRooms = 1;
    maxPeople = 1;
    _reservedPeople = 0;
    emit(AddApartmentInitial());
  }

  void initEdit(ApartmentResponse apartment, LocationViewModel locationViewModel) {
    nameCRl.text = apartment.name ?? "";
    descriptionCRl.text = apartment.description ?? "";
    priceCRl.text = apartment.price?.toString() ?? "";
    addressCRl.text = apartment.address ?? "";
    cityCRl.text = fixedCity;
    districtCRl.text = apartment.district ?? districtOptions.first;
    floor = apartment.floor ?? 1;
    floorCRl.text = floor.toString();
    bedrooms = apartment.bedrooms ?? 1;
    bathrooms = apartment.bathrooms ?? 1;
    livingRooms = apartment.livingRooms ?? 1;
    maxPeople = apartment.maxPeople ?? 1;
    verified = apartment.verified ?? false;
    final initialMaxPeople = apartment.maxPeople ?? maxPeople;
    final initialAvailablePeople = apartment.availablePeople ?? initialMaxPeople;
    _reservedPeople = initialMaxPeople - initialAvailablePeople;
    if (_reservedPeople < 0) {
      _reservedPeople = 0;
    }
    existingImageUrls = List.from(apartment.images ?? []);
    existingVideoUrl = apartment.videoUrl;
    
    if (apartment.lat != null && apartment.lng != null) {
      locationViewModel.apartmentLocation = LatLng(apartment.lat!, apartment.lng!);
      locationViewModel.apartmentAddress = apartment.locationAddress ?? apartment.address;
    }
    
    emit(AddApartmentUpdateUI());
  }

  void setDistrict(String value) {
    if (!districtOptions.contains(value)) {
      return;
    }
    districtCRl.text = value;
    emit(AddApartmentUpdateUI());
  }

  void setFloor(String value) {
    floor = int.tryParse(value.trim()) ?? 1;
    emit(AddApartmentUpdateUI());
  }

  void removeExistingImage(int index) {
    existingImageUrls?.removeAt(index);
    emit(AddApartmentUpdateUI());
  }

  void removeNewImage(int index) {
    apartmentImages.removeAt(index);
    emit(AddApartmentUpdateUI());
  }

  void increaseBedrooms() {
    bedrooms++;
    emit(AddApartmentUpdateUI());
  }

  void decreaseBedrooms() {
    if (bedrooms > 1) {
      bedrooms--;
      emit(AddApartmentUpdateUI());
    }
  }

  void increaseBathrooms() {
    bathrooms++;
    emit(AddApartmentUpdateUI());
  }

  void decreaseBathrooms() {
    if (bathrooms > 1) {
      bathrooms--;
      emit(AddApartmentUpdateUI());
    }
  }

  void increaseLivingRooms() {
    livingRooms++;
    emit(AddApartmentUpdateUI());
  }

  void decreaseLivingRooms() {
    if (livingRooms > 1) {
      livingRooms--;
      emit(AddApartmentUpdateUI());
    }
  }

  void increaseMaxPeople() {
    maxPeople++;
    emit(AddApartmentUpdateUI());
  }

  void decreaseMaxPeople() {
    if (maxPeople > 1) {
      maxPeople--;
      emit(AddApartmentUpdateUI());
    }
  }

  Future<void> pickImage(ImageSource source) async {
    await _requestPermission(source);
    final XFile? pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      apartmentImages.add(File(pickedFile.path));
      emit(AddApartmentUpdateUI());
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    await _requestPermission(source);

    final XFile? video = await _videoPicker.pickVideo(
      source: source,
      maxDuration:
          source == ImageSource.camera ? const Duration(minutes: 10) : null,
    );

    if (video == null) return;

    final pickedVideoFile = File(video.path);
    final controller = VideoPlayerController.file(pickedVideoFile);

    try {
      await controller.initialize();

      if (controller.value.duration > const Duration(minutes: 10)) {
        emit(AddApartmentError(
            "The video duration should not exceed 10 minutes."));
        return;
      }

      videoFile = pickedVideoFile;
      existingVideoUrl = null; // Clear existing video if new one is picked
    } catch (e) {
      videoFile = null;
      emit(AddApartmentError("Video playback failed"));
    } finally {
      await controller.dispose();
      // Emit update UI only after the temporary controller is fully disposed
      if (videoFile != null) {
        emit(AddApartmentUpdateUI());
      }
    }
  }

  Future<void> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.photos.request();
    }
  }

  Future<void> uploadApartment(UserViewModel userViewModel, LocationViewModel locationViewModel) async {
    final name = nameCRl.text;
    final description = descriptionCRl.text;
    final price = priceCRl.text;

    if (name.isEmpty || price.isEmpty || description.isEmpty) {
      emit(AddApartmentError("Please fill all fields"));
      return;
    }

    if (apartmentImages.isEmpty) {
      emit(AddApartmentError("Please add at least one image"));
      return;
    }

    emit(AddApartmentLoading());

    try {
      final token = SharedPrefsHelper.getData(key: "token")?.toString();
      if (token == null || token.isEmpty) {
        emit(AddApartmentError("Please login again before adding an apartment."));
        return;
      }

      List<String> imageUrls = [];
      String? videoUrl;

      for (var image in apartmentImages) {
        emit(AddApartmentProgress(
            "Uploading image ${imageUrls.length + 1}/${apartmentImages.length}..."));
        String? url = await CloudinaryService.uploadImage(image);
        if (url != null) {
          imageUrls.add(url);
        } else {
          emit(AddApartmentError("Failed to upload image"));
          return;
        }
      }

      if (videoFile != null) {
        emit(AddApartmentProgress("Uploading video..."));
        videoUrl = await CloudinaryService.uploadVideo(videoFile!);
        if (videoUrl == null) {
          emit(AddApartmentError("Failed to upload video"));
          return;
        }
      }

      final manualAddress = addressCRl.text.trim();
      final mapAddress = locationViewModel.apartmentAddress?.trim();

      Apartment apartment = Apartment(
        name: name,
        description: description,
        price: double.tryParse(price),
        images: imageUrls,
        videoUrl: videoUrl,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        livingRooms: livingRooms,
        floor: int.tryParse(floorCRl.text.trim()) ?? floor,
        maxPeople: maxPeople,
        availablePeople: maxPeople,
        address: manualAddress.isNotEmpty ? manualAddress : mapAddress,
        city: fixedCity,
        district: districtCRl.text.trim(),
        locationAddress: mapAddress,
        lat: locationViewModel.apartmentLocation?.latitude,
        lng: locationViewModel.apartmentLocation?.longitude,
        ownerId: userViewModel.user?.id,
        ownerName: userViewModel.user?.name,
        ownerPhotoUrl: userViewModel.user?.photoUrl,
        verified: false,
        createdAt: DateTime.now(),
      );

      emit(AddApartmentProgress("Saving apartment data..."));
      await apartmentRepository.addApartment(
        apartment,
        userViewModel.user!.id!,
      );

      emit(AddApartmentSuccess());
    } catch (e) {
      emit(AddApartmentError("Error: ${e.toString()}"));
    }
  }

  Future<void> updateApartment(UserViewModel userViewModel, LocationViewModel locationViewModel, String apartmentId) async {
    final name = nameCRl.text;
    final description = descriptionCRl.text;
    final price = priceCRl.text;

    if (name.isEmpty || price.isEmpty || description.isEmpty) {
      emit(AddApartmentError("Please fill all fields"));
      return;
    }

    if ((existingImageUrls == null || existingImageUrls!.isEmpty) && apartmentImages.isEmpty) {
      emit(AddApartmentError("Please add at least one image"));
      return;
    }

    emit(AddApartmentLoading());

    try {
      final token = SharedPrefsHelper.getData(key: "token")?.toString();
      if (token == null || token.isEmpty) {
        emit(AddApartmentError("Please login again before updating this apartment."));
        return;
      }

      List<String> imageUrls = List.from(existingImageUrls ?? []);
      String? videoUrl = existingVideoUrl;

      for (var image in apartmentImages) {
        emit(AddApartmentProgress(
            "Uploading new image ${imageUrls.length - (existingImageUrls?.length ?? 0) + 1}/${apartmentImages.length}..."));
        String? url = await CloudinaryService.uploadImage(image);
        if (url != null) {
          imageUrls.add(url);
        } else {
          emit(AddApartmentError("Failed to upload image"));
          return;
        }
      }

      if (videoFile != null) {
        emit(AddApartmentProgress("Uploading new video..."));
        videoUrl = await CloudinaryService.uploadVideo(videoFile!);
        if (videoUrl == null) {
          emit(AddApartmentError("Failed to upload video"));
          return;
        }
      }

      Apartment apartment = Apartment(
        id: apartmentId,
        name: name,
        description: description,
        price: double.tryParse(price),
        images: imageUrls,
        videoUrl: videoUrl,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        livingRooms: livingRooms,
        floor: int.tryParse(floorCRl.text.trim()) ?? floor,
        maxPeople: maxPeople,
        availablePeople: maxPeople - _reservedPeople,
        address: addressCRl.text.trim().isNotEmpty
            ? addressCRl.text.trim()
            : locationViewModel.apartmentAddress,
        city: fixedCity,
        district: districtCRl.text.trim(),
        locationAddress: locationViewModel.apartmentAddress,
        lat: locationViewModel.apartmentLocation?.latitude,
        lng: locationViewModel.apartmentLocation?.longitude,
        ownerId: userViewModel.user?.id,
        ownerName: userViewModel.user?.name,
        ownerPhotoUrl: userViewModel.user?.photoUrl,
        verified: verified,
        createdAt: DateTime.now(), // Or preserve original created date
      );

      emit(AddApartmentProgress("Updating apartment data..."));
      if (apartment.availablePeople! < 0) {
        emit(AddApartmentError(
          "People capacity cannot be lower than the number already renting this apartment.",
        ));
        return;
      }
      await apartmentRepository.updateApartment(
        apartment,
        userViewModel.user!.id!,
      );

      emit(AddApartmentSuccess());
    } catch (e) {
      emit(AddApartmentError("Error: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    nameCRl.dispose();
    descriptionCRl.dispose();
    priceCRl.dispose();
    addressCRl.dispose();
    cityCRl.dispose();
    districtCRl.dispose();
    floorCRl.dispose();
    return super.close();
  }
}
