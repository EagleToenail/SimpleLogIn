import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'new_post.dart'; // Your NewPostPage import
import 'post_details.dart'; // Your PostDetailsPage import
import 'const.dart';

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['newsfeeds'] is List) {
          final List<dynamic> feeds = data['newsfeeds'];

          setState(() {
            _newsfeeds =
                feeds.map((json) => NewsFeedItem.fromJson(json)).toList();
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
      body:
          _loading
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
                      attachmentUrl: feed.attachmentUrl,
                      attachmentType: feed.attachmentType,
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewPost,
        backgroundColor: Colors.lightBlue, // Stylish color
        foregroundColor: Colors.white, // Icon color
        elevation: 4, // Subtle shadow
        shape: const CircleBorder(), // Ensures round shape
        child: const Icon(
          Icons.add,
          size: 28, // Slightly larger icon
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

  // You can add more fields as needed

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
  });

  factory NewsFeedItem.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};
    final locations = json['locations'] as List<dynamic>? ?? [];

    String locationName = '';
    if (locations.isNotEmpty) {
      // Assuming locations contains objects with a name field
      locationName = locations.first['name'] ?? '';
    }

    return NewsFeedItem(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      authorName: author['preferredName'] ?? 'Unknown',
      attachmentUrl: json['attachementUrl'],
      attachmentType: json['attachementType'],
      requireConfirm: json['requireConfirm'] ?? false,
      allowComment: json['allowComment'] ?? true,
      location: locationName,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
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

// Updated PostCard widget to optionally show attachment image if available
class PostCard extends StatelessWidget {
  final String postID;
  final String name;
  final String timeAgo;
  final String content;
  final String location;
  final bool isConfirmed;
  final int totalConfirmations;
  final int views;
  final String? attachmentUrl;
  final String? attachmentType;

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
    this.attachmentUrl,
    this.attachmentType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to post details page if needed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PostDetailsPage(
                  postId: postID,
                  userName: name,
                  userInitials: name.isNotEmpty ? name[0] : '?',
                  dateTime: timeAgo,
                  location: location,
                  postContent: content,
                  confirmed: isConfirmed ? 1 : 0,
                  total: totalConfirmations,
                  attachmentUrl: attachmentUrl ?? '',
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
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
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

              // Content
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              if (attachmentUrl != null && attachmentUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '$SERVER_URL$attachmentUrl',
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

              const SizedBox(height: 16),

              // Footer
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
                        "$views",
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
