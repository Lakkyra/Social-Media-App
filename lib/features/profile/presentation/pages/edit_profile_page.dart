import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/components/my_text_field.dart';
import '../../../responsive/constrained_scaffold.dart';
import '../../domain/entities/profile_user.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_states.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser profileUser;
  const EditProfilePage({super.key, required this.profileUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  PlatformFile? imagePickedFile;
  Uint8List? webImage;

  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final uid = widget.profileUser.uid;
    //final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    //final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    final newBio = _bioController.text.isNotEmpty ? _bioController.text : null;

    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateUserProfile(
        uid,
        (_bioController.text.isNotEmpty)
            ? _bioController.text
            : widget.profileUser.bio,

        imagePickedFile,
        webImage,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is ProfileLoadedState) {
          Navigator.pop(context);
        } else if (state is ProfileErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      builder: (context, state) {
        if (state is ProfileLoadingState) {
          return ConstrainedScaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text('Uploading...')],
              ),
            ),
          );
        }
        return buildEditPage();
      },
    );
  }

  Widget buildEditPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          IconButton(onPressed: updateProfile, icon: Icon(Icons.upload)),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child: (!kIsWeb && imagePickedFile != null)
                  ? Image.file(File(imagePickedFile!.path!), fit: BoxFit.cover)
                  : (kIsWeb && webImage != null)
                  ? Image.memory(webImage!)
                  : CachedNetworkImage(
                      imageUrl: widget.profileUser.profileImageUrl,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      imageBuilder: (context, imageProvider) =>
                          Image(image: imageProvider, fit: BoxFit.cover),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 25),

          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: Text('Pick image'),
            ),
          ),

          Text('Bio'),
          MyTextField(
            controller: _bioController,
            hintText: (widget.profileUser.bio.isNotEmpty)
                ? widget.profileUser.bio
                : '',
            obscureText: false,
          ),
        ],
      ),
    );
  }
}
