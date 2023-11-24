import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_image_storage_bloc/auth/auth_errors.dart';
import 'package:firebase_image_storage_bloc/bloc/app_event.dart';
import 'package:firebase_image_storage_bloc/bloc/app_state.dart';
import 'package:firebase_image_storage_bloc/utils/upload_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        ) {
    on<AppEventGoToRegistration>((event, emit) {
      emit(
        const AppStateIsInRegistrationView(
          isLoading: false,
        ),
      );
    });
    on<AppEventLogIn>((event, emit) async {
      emit(
        const AppStateLoggedOut(
          isLoading: true,
        ),
      );
      //log the user in
      final email = event.email;
      final password = event.password;
      try {
        final userCredentials =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = userCredentials.user!;
        final images = await _getImages(user.uid);
        emit(
          AppStateLoggedIn(
            user: user,
            images: images,
            isLoading: false,
          ),
        );
      } on FirebaseAuthException catch (e) {
        emit(
          AppStateLoggedOut(
            isLoading: false,
            authError: AuthError.from(e),
          ),
        );
      }
    });
    on<AppEventGoToLogIn>((event, emit) {
      emit(
        const AppStateLoggedOut(
          isLoading: false,
        ),
      );
    });
    on<AppEventRegister>((event, emit) async {
      emit(
        const AppStateIsInRegistrationView(
          isLoading: true,
        ),
      );
      final email = event.email;
      final password = event.password;
      try {
        //create the user
        final credentials =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        emit(
          AppStateLoggedIn(
            user: credentials.user!,
            images: const [],
            isLoading: false,
          ),
        );
      } on FirebaseAuthException catch (e) {
        emit(
          AppStateIsInRegistrationView(
            isLoading: false,
            authError: AuthError.from(e),
          ),
        );
      }
    });
    on<AppEventInitialize>((event, emit) async {
      //get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      } else {
        //grab the user's uploaded images
        final images = await _getImages(user.uid);
        emit(
          AppStateLoggedIn(
            user: user,
            images: images,
            isLoading: false,
          ),
        );
      }
    });
    //log out event
    on<AppEventLogOut>((event, emit) async {
      emit(
        const AppStateLoggedOut(
          isLoading: true,
        ),
      );
      //log the user out
      await FirebaseAuth.instance.signOut();
      emit(
        const AppStateLoggedOut(
          isLoading: false,
        ),
      );
    });
    //handel account deletion
    on<AppEventDeleteAccount>((event, emit) async {
      final user = FirebaseAuth.instance.currentUser;
      //log user out if we don't have an actual user in app state
      if (user == null) {
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
        return;
      }
      //start loading
      emit(
        AppStateLoggedIn(
          user: user,
          images: state.images ?? [],
          isLoading: true,
        ),
      );
      //delete use folder
      try {
        //delete the files
        final folderContents =
            await FirebaseStorage.instance.ref(user.uid).listAll();
        for (final item in folderContents.items) {
          await item.delete().catchError((_) {}); //maybe handel the error?
        }

        //delete the folder itself
        await FirebaseStorage.instance
            .ref(user.uid)
            .delete()
            .catchError((_) {});
        //delete the user
        user.delete();
        //log the user out
        await FirebaseAuth.instance.signOut();
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      } on FirebaseAuthException catch (e) {
        emit(
          AppStateLoggedIn(
            user: user,
            images: state.images ?? [],
            isLoading: false,
            authError: AuthError.from(e),
          ),
        );
      } on FirebaseException {
        //we might not be abel to delete the user folder
        //log the user out (not necessarily, we can output an error instead or anything)
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      }
    });
    //handel uploading images
    on<AppEventUploadImage>((event, emit) async {
      final user = state.user;
      //log user out if we don't have an actual user in app state
      if (user == null) {
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
        return;
      }
      //start the loading process
      emit(
        AppStateLoggedIn(
          user: user,
          images: state.images ?? [],
          isLoading: true,
        ),
      );
      //upload the file
      final file = File(event.filePathToUpload);
      await uploadImage(
        file: file,
        userId: user.uid,
      );
      //after upload is complete, grab the latest file references
      final images = await _getImages(user.uid);
      //emit the new images and turn off loading
      emit(
        AppStateLoggedIn(
          user: user,
          images: images,
          isLoading: false,
        ),
      );
    });
  }

  Future<Iterable<Reference>> _getImages(String userId) {
    return FirebaseStorage.instance
        .ref(userId)
        .list()
        .then((listResult) => listResult.items);
  }
}
