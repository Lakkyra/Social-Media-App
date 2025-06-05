import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/domain/entities/app_user.dart';

import '../../../auth/presentation/components/my_text_field.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../responsive/constrained_scaffold.dart';
import '../../domain/entities/post.dart';
import '../cubits/post_cubits.dart';
import '../cubits/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  AppUser? currentUser;
  final TextEditingController _captionController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    // Logic to fetch the current user
    final authCubit = context.read<AuthCubit>();

    currentUser = authCubit.currentUser;
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

  void uploadPost() {
    if ((imagePickedFile == null && webImage == null) ||
        _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and enter a caption')),
      );
      return;
    } else {
      final postCubit = context.read<PostCubit>();
      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: _captionController.text,
        imageUrl: '',
        timeStamp: DateTime.now(),
        likes: [],
        comments: [],
      );

      postCubit.createPost(post, imagePickedFile, webImage);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _captionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is PostLoaded) {
          return Navigator.pop(context);
        }
      },
      builder: (context, state) {
        if (state is PostLoading || state is PostUploading) {
          return ConstrainedScaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        return buildUploadPage();
      },
    );
  }

  Widget buildUploadPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (kIsWeb && webImage != null) Image.memory(webImage!),
          if (!kIsWeb && imagePickedFile != null)
            Image.file(File(imagePickedFile!.path!)),
          MaterialButton(
            onPressed: pickImage,
            color: Colors.blue,
            child: Text('Pick Image'),
          ),
          MyTextField(
            controller: _captionController,
            hintText: 'caption',
            obscureText: false,
          ),
          MaterialButton(
            onPressed: uploadPost,
            color: Colors.blue,
            child: Text('Upload Post'),
          ),
        ],
      ),
    );
  }
}
