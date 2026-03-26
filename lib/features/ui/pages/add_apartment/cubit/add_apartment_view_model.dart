import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sokon/core/cache/cubit_manger/user_view_model.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/cloudinary_service.dart';
import '../../../../../data/repository/apartment/repository/apartment_repository.dart';
import 'package:video_player/video_player.dart';
import 'add_apartment_states.dart';
import '../../../../../core/cache/cubit_manger/location_view_model.dart';

@injectable
class AddApartmentViewModel extends Cubit<AddApartmentStates> {
  final UserViewModel userViewModel;
  final LocationViewModel locationViewModel;
  final ApartmentRepository apartmentRepository;

  AddApartmentViewModel(
      this.userViewModel, this.locationViewModel, this.apartmentRepository)
      : super(AddApartmentInitial());

  final ImagePicker _videoPicker = ImagePicker();
  final ImagePicker _imagePicker = ImagePicker();

  VideoPlayerController? controllerVideo;
  List<File> apartmentImages = [];
  int bedrooms = 1;
  int bathrooms = 1;
  int livingRooms = 1;

  final TextEditingController nameCRl = TextEditingController();
  final TextEditingController descriptionCRl = TextEditingController();
  final TextEditingController priceCRl = TextEditingController();

  File? videoFile;

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

    videoFile = File(video.path);
    final controller = VideoPlayerController.file(videoFile!);

    try {
      await controller.initialize();

      if (controller.value.duration > const Duration(minutes: 10)) {
        controller.dispose();
        videoFile = null;
        emit(AddApartmentError(
            "The video duration should not exceed 10 minutes."));
        return;
      }

      controllerVideo?.dispose();
      controllerVideo = controller;
      emit(AddApartmentUpdateUI());
    } catch (e) {
      controller.dispose();
      videoFile = null;
      emit(AddApartmentError("Video playback failed"));
    }
  }

  void toggleVideoPlay() {
    if (controllerVideo != null) {
      controllerVideo!.value.isPlaying
          ? controllerVideo!.pause()
          : controllerVideo!.play();
      emit(AddApartmentUpdateUI());
    }
  }

  Future<void> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.photos.request();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  Future<void> uploadApartment() async {
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

    if (locationViewModel.apartmentLocation == null) {
      emit(AddApartmentError("Please select location"));
      return;
    }

    emit(AddApartmentLoading());

    try {
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

      Apartment apartment = Apartment(
        name: name,
        description: description,
        price: double.tryParse(price),
        images: imageUrls,
        videoUrl: videoUrl,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        livingRooms: livingRooms,
        address: locationViewModel.apartmentAddress,
        lat: locationViewModel.apartmentLocation?.latitude,
        lng: locationViewModel.apartmentLocation?.longitude,
        ownerId: userViewModel.user?.id,
        ownerName: userViewModel.user?.name,
        ownerPhotoUrl: userViewModel.user?.photoUrl,
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

  @override
  Future<void> close() {
    controllerVideo?.dispose();
    nameCRl.dispose();
    descriptionCRl.dispose();
    priceCRl.dispose();
    return super.close();
  }
}
