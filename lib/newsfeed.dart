import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'new_post.dart'; // Your NewPostPage import
import 'post_details.dart'; // Your PostDetailsPage import
import 'const.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/store.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({Key? key}) : super(key: key);

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  List<NewsFeedItem> _newsfeeds = [];
  bool _loading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchNewsFeed();
  }

  Future<void> _fetchNewsFeed() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final url = Uri.parse(GET_FEED_URL);
      final response = await http.get(url);

      final loggedInUser =
          Provider.of<AppStore>(context, listen: false).loggedInUser;
      final userID = loggedInUser?.userID;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['newsfeeds'] is List) {
          final List<dynamic> feeds = data['newsfeeds'];
          print("===================================================");
          print(feeds[1]);
          print("===================================================");

          setState(() {
            // _newsfeeds =
            //     feeds.map((json) => NewsFeedItem.fromJson(json)).toList();
            _newsfeeds = feeds
              .where((json) {
                final item = NewsFeedItem.fromJson(json); // Create temporary item to check properties
                return (item.type == "system" && item.user == userID) ||
                      (item.type != "system");
              })
              .map((json) => NewsFeedItem.fromJson(json))
              .toList();
          });
        } else {
          setState(() {
            _error = 'Invalid response format';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load newsfeed: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching newsfeed: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _navigateToNewPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPostPage()),
    );

    // If user posted new content, refresh feed
    if (result == true) {
      _fetchNewsFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : RefreshIndicator(
                  onRefresh: _fetchNewsFeed,
                  child: ListView.builder(
                    itemCount: _newsfeeds.length,
                    itemBuilder: (context, index) {
                      final feed = _newsfeeds[index];
                      return PostCard(
                        postID: feed.id,
                        name: feed.authorName,
                        timeAgo: feed.getFormattedTimeAgo(),
                        content: feed.content,
                        location: feed.location,
                        isConfirmed: feed.requireConfirm,
                        totalConfirmations: feed.totalConfirmations,
                        views: feed.views,
                        commentCount: feed.commentCount, // Pass comment count
                        attachmentUrl: feed.attachmentUrl,
                        attachmentType: feed.attachmentType,
                        allowComment: feed.allowComment,
                        type: feed.type,
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewPost,
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
    );
  }
}

// Model class for NewsFeed item
class NewsFeedItem {
  final String id;
  final String type;
  final String content;
  final String authorName;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool requireConfirm;
  final bool allowComment;
  final String location;
  final DateTime createdAt;
  final int commentCount; // Added field for comment count
  final String? user; // Added field for comment count

  NewsFeedItem({
    required this.id,
    required this.type,
    required this.content,
    required this.authorName,
    this.attachmentUrl,
    this.attachmentType,
    required this.requireConfirm,
    required this.allowComment,
    required this.location,
    required this.createdAt,
    required this.commentCount, // Added to constructor
    this.user, // Added to constructor
  });

  factory NewsFeedItem.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};
    final locations = json['locations'] as List<dynamic>? ?? [];

    String locationName = '';
    if (locations.isNotEmpty) {
      locationName = locations.first['name'] ?? '';
    }

    // Extract comment count based on the structure of 'comments'
    int commentCount = 0;
    if (json['comments'] is List) {
      commentCount = (json['comments'] as List).length; // If comments is a list, get its length
    } else if (json['comments'] is int) {
      commentCount = json['comments']; // If comments is a direct count
    }

    return NewsFeedItem(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      authorName: author['preferredName'] ?? 'Unknown',
      attachmentUrl: json['attachementUrl'], // Note: Typo in API field name
      attachmentType: json['attachementType'], // Note: Typo in API field name
      requireConfirm: json['requireConfirm'] ?? false,
      allowComment: json['allowComment'] ?? true,
      location: locationName,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      commentCount: commentCount, // Set the comment count
      user: json['users'] != null && json['users'].isNotEmpty
          ? json['users'][0]['_id'] ?? ''
          : '',
    );
  }

  int get totalConfirmations => 1; // Placeholder, adjust if you have data
  int get views => 0; // Placeholder, adjust if you have data

  String getFormattedTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }
}

// Updated PostCard widget to show comment count
class PostCard extends StatelessWidget {
  final String postID;
  final String name;
  final String timeAgo;
  final String content;
  final String location;
  final bool isConfirmed;
  final int totalConfirmations;
  final int views;
  final int commentCount; // Added field for comment count
  final String? attachmentUrl;
  final String? attachmentType;
  final bool allowComment;
  final String? type;

  const PostCard({
    super.key,
    required this.postID,
    required this.name,
    required this.timeAgo,
    required this.content,
    this.location = '',
    this.isConfirmed = false,
    this.totalConfirmations = 1,
    this.views = 0,
    required this.commentCount, // Added to constructor
    this.attachmentUrl,
    this.attachmentType,
    required this.allowComment,
    required this.type,
  });

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';

    final parts = name.trim().split(RegExp(r'\s+')); // handles multiple spaces
    final first = parts.isNotEmpty ? parts[0][0] : '';
    final last = parts.length > 1 ? parts[1][0] : '';

    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsPage(
              postId: postID,
              userName: name,
              userInitials: name.isNotEmpty ? name[0] : '?',
              dateTime: timeAgo,
              location: location,
              postContent: content,
              confirmed: isConfirmed ? 1 : 0,
              total: totalConfirmations,
              attachmentUrl: attachmentUrl ?? '',
              allowComment: allowComment ?? true,
              type:type,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              if (type != "system")
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        _getInitials(name),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

              // Conditional Image/UI based on type1
              if (type == "system")
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 228, 57, 57),
                      child: Text(
                        "SN",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            color: const Color.fromARGB(255, 228, 57, 57),
                            child: const Text(
                              "System Notification",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white, // Set font color to white
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content
              if (type != "system")  
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                // Content
              if (type == "system")  
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),

              if (type != "system")
                if (attachmentUrl != null && attachmentUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '$IMAGE_SERVER_URL$attachmentUrl',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
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
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

              const SizedBox(height: 16),
              // Footer with comment count
              if (type != "system")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$commentCount", // Display the actual comment count
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
