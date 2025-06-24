import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:simple_login/store.dart';
import 'package:simple_login/const.dart';
import 'package:simple_login/toast.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  bool confirmationRequired = false;
  bool commentsEnabled = true;
  final TextEditingController _controller = TextEditingController();

  final Color softSkyBlue = const Color(0xFFE6F0FA); // soft background
  final Color skyBlueAccent = const Color(0xFF64B5F6); // accent blue
  final Color borderGray = const Color(0xFFE0E0E0);

  File? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon:
                  _isPosting
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check),
              iconSize: 22,
              onPressed: _isPosting ? null : _postNewsFeed,
              style: IconButton.styleFrom(
                foregroundColor: skyBlueAccent,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Post input area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "What's on your mind?",
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),

          // Media preview if selected
          if (_mediaFile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(_mediaFile!, height: 150, fit: BoxFit.cover),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _mediaFile = null;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Add media button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: OutlinedButton.icon(
              onPressed: _pickMedia,
              label: Text(
                'Add Media',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: skyBlueAccent.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),

      // Bottom settings
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderGray)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // buildSettingTile(
            //   icon:
            //       confirmationRequired
            //           ? Icons.check_circle_outline
            //           : Icons.radio_button_unchecked,
            //   title: 'Confirmation required',
            //   value: confirmationRequired,
            //   onChanged: (val) {
            //     setState(() {
            //       confirmationRequired = val;
            //     });
            //   },
            // ),
            buildSettingTile(
              icon: Icons.chat_bubble_outline,
              title: 'Comments enabled',
              value: commentsEnabled,
              onChanged: (val) {
                setState(() {
                  commentsEnabled = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: value ? skyBlueAccent : Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: 0.75, // Smaller switch
            child: Switch(
              value: value,
              activeColor: skyBlueAccent,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      // To pick video, you can use pickVideo() or add a dialog to choose
    );

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _postNewsFeed() async {
    final content = _controller.text.trim();

    if (content.isEmpty && _mediaFile == null) {
      Toast.show(context, "Please input all fields", type: ToastType.info);
      return;
    }

    setState(() {
      _isPosting = true;
    });

    final loggedInUser =
        Provider.of<AppStore>(context, listen: false).loggedInUser;
    final userID = loggedInUser?.userID ?? '';

    try {
      var uri = Uri.parse(POST_FEED_URL);
      var request = http.MultipartRequest('POST', uri);
      request.fields['userID'] = userID;
      request.fields['content'] = content;
      request.fields['confirmationRequired'] =
          confirmationRequired ? 'true' : 'false';
      request.fields['commentsEnabled'] = commentsEnabled ? 'true' : 'false';

      if (_mediaFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('media', _mediaFile!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        Toast.show(
          context,
          'Post submitted successfully',
          type: ToastType.success,
        );

        _controller.clear();
        setState(() {
          _mediaFile = null;
        });
      } else {
        Toast.show(
          context,
          'Failed to post: ${response.statusCode}',
          type: ToastType.error,
        );
      }
    } catch (e) {
      Toast.show(context, 'Error: $e', type: ToastType.error);
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }
}
