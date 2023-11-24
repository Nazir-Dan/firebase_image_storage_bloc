import 'package:firebase_image_storage_bloc/bloc/app_bloc.dart';
import 'package:firebase_image_storage_bloc/bloc/app_event.dart';
import 'package:firebase_image_storage_bloc/bloc/app_state.dart';
import 'package:firebase_image_storage_bloc/dialogs/show_auth_error.dart';
import 'package:firebase_image_storage_bloc/loading/loading_screen.dart';
import 'package:firebase_image_storage_bloc/views/home_page.dart';
import 'package:firebase_image_storage_bloc/views/login_view.dart';
import 'package:firebase_image_storage_bloc/views/photo_galary_view.dart';
import 'package:firebase_image_storage_bloc/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      create: (_) => AppBloc()..add(const AppEventInitialize()),
      child: MaterialApp(
        debugShowMaterialGrid: false,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: BlocConsumer<AppBloc, AppState>(
          listener: (context, appState) {
            if (appState.isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: 'Loading...',
              );
            } else {
              LoadingScreen.instance().hide();
            }
            final authError = appState.authError;
            if (authError != null) {
              showAuthErrorDialog(
                context: context,
                authError: authError,
              );
            }
          },
          builder: (context, state) {
            if (state is AppStateLoggedOut) {
              return const LoginView();
            } else if (state is AppStateLoggedIn) {
              return const PhotoGalleryView();
            } else if (state is AppStateIsInRegistrationView) {
              return const RegisterView();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
