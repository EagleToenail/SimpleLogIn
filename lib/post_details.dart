import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:simple_login/const.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/toast.dart';

class PostDetailsPage extends StatefulWidget {
  final String postId;
  final String userName;
  final String userInitials;
  final String dateTime;
  final String location;
  final String postContent;
  final String? attachmentUrl;
  final int confirmed;
  final int total;

  const PostDetailsPage({
    super.key,
    required this.postId,
    required this.userName,
    required this.userInitials,
    required this.dateTime,
    required this.location,
    required this.postContent,
    required this.confirmed,
    required this.total,
    this.attachmentUrl,
  });

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _commentController = TextEditingController();

  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _getComments(widget.postId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSendComment(postID, userID) async {
    if (_commentController.text.isNotEmpty) {
      String commentText = _commentController.text.trim();

      final requestBody = {
        "author": userID,
        "parentID": postID,
        "content": commentText,
        "type": "comment",
      };

      print(requestBody);

      final url = Uri.parse(POST_COMMENT_FEED_URL);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        _getComments(postID);
        _commentController.clear();
      } else {
        print('Failed to send comment');
      }
    } else {
      Toast.show(context, 'Please fill all fields!', type: ToastType.info);
    }
  }

  void _getComments(postID) async {
    final requestBody = {"parentID": postID};

    print("🧨🧨🧨🧨🧨🧨🧨🧨");
    print(requestBody);

    final url = Uri.parse(GET_COMMENT_LIST_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success']) {
        final feedsRaw = data['feeds'] as List<dynamic>?;

        List<Map<String, dynamic>> feeds = [];

        if (feedsRaw != null) {
          setState(() {
            _comments =
                feedsRaw
                    .map((item) => Map<String, dynamic>.from(item as Map))
                    .toList();
          });
        }

        print("🧨🧨🧨🧨🧨🧨🧨🧨");

        print(_comments);
      }
    } else {
      print("💥 Get Comments Error: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser =
        Provider.of<AppStore>(context, listen: false).loggedInUser;
    final userID = loggedInUser?.userID;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueGrey[400],
                    child: Text(
                      widget.userInitials,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.dateTime,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          widget.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.postContent,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),
            ),
            if (widget.attachmentUrl != null &&
                widget.attachmentUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '$SERVER_URL${widget.attachmentUrl}',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Show a placeholder or empty box on error
                      return Container(
                        height: 180,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            const Divider(height: 32, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    "Comments",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              child:
                  _comments.isEmpty
                      ? Center(
                        child: Text(
                          "No comments yet",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      )
                      : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final authorName =
                              comment['author']?['preferredName'] ?? 'U';
                          final commentContent =
                              comment['content'] ?? 'No content available';

                          return ListTile(
                            key: ValueKey(comment['id'] ?? index),
                            leading: CircleAvatar(
                              child: Text(
                                authorName.isNotEmpty
                                    ? authorName[0].toUpperCase()
                                    : 'U',
                              ),
                            ),
                            title: Text(commentContent),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _handleSendComment(widget.postId, userID),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueAccent,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: () {
                  _handleSendComment(widget.postId, userID);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
