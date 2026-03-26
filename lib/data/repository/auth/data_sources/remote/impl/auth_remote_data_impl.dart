import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../cloudinary_service.dart';
import '../../../../../../core/model/my_user.dart';
import '../../../../../../firebase_utils.dart';
import '../auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataImpl implements AuthRemoteDataSource {
  @override
  Future<MyUser> login(String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      var user = await FireBaseUtils.readUserFromFireStore(credential.user!.uid);
      if (user != null) {
        return user;
      } else {
        throw Exception("User data not found in database.");
      }
    }
    throw Exception("Authentication failed");
  }

  @override
  Future<MyUser> register(String email, String password, String name) async {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    MyUser newUser = MyUser(
      id: credential.user!.uid,
      name: name,
      email: email,
    );
    await FireBaseUtils.addUserToFirestore(newUser);
    return newUser;
  }

  @override
  Future<MyUser> signInWithGoogle() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;
    await signIn.initialize(
      clientId: dotenv.env['server_client_id'],
    );
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
    if (googleUser == null) {
      throw Exception("Google Sign-In cancelled");
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    var firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      var user = await FireBaseUtils.readUserFromFireStore(firebaseUser.uid);
      if (user == null) {
        return MyUser(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? "",
          email: firebaseUser.email ?? "",
          photoUrl: firebaseUser.photoURL,
        );
      }
      return user;
    }
    throw Exception("Google Sign-In failed");
  }

  @override
  Future<void> updateUserRole(MyUser user, String role) async {
    user.role = role;
    await FireBaseUtils.addUserToFirestore(user);
  }

  @override
  Future<MyUser> updateProfile(MyUser user, String name, File? profileImage) async {
    String? photoUrl = user.photoUrl;
    if (profileImage != null) {
      photoUrl = await CloudinaryService.uploadImage(profileImage);
    }

    user.name = name;
    user.photoUrl = photoUrl;

    await FireBaseUtils.addUserToFirestore(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
