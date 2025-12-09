// lib/screens/social/social_screen.dart
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/plog_models.dart';
import '../../widgets/common_cards.dart';
import '../../theme/app_theme.dart';

class SocialScreen extends StatefulWidget {
  final List<SocialPost> posts;
  final List<PlogSession> sessions;
  final void Function(SocialPost post) onPostCreated;

  const SocialScreen({
    super.key,
    required this.posts,
    required this.sessions,
    required this.onPostCreated,
  });

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  /// 좋아요를 누른 포스트 ID 집합
  final Set<String> _likedPostIds = {};

  /// 포스트별 좋아요 카운트
  final Map<String, int> _likeCounts = {};

  /// 포스트별 댓글 리스트
  final Map<String, List<String>> _comments = {};

  /// 포스트별 업로드된 이미지 (로컬 메모리)
  final Map<String, Uint8List> _postImages = {};

  @override
  void initState() {
    super.initState();
    _initFromPosts();
  }

  @override
  void didUpdateWidget(covariant SocialScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posts != widget.posts) {
      _initFromPosts();
    }
  }

  void _initFromPosts() {
    for (final p in widget.posts) {
      // 기존 값이 있으면 유지, 없으면 초기화
      _likeCounts.putIfAbsent(p.id, () => p.likes);

      _comments.putIfAbsent(p.id, () {
        // 더미 포스트에 대한 기본 댓글
        if (p.id == '1') {
          return [
            'Amazing plogging!',
            'Love this Han River route 🌊',
          ];
        }
        if (p.id == '2') {
          return [
            'Great job!',
            'Seongsu looks so clean now ✨',
          ];
        }
        return [];
      });
    }
  }

  void _toggleLike(SocialPost post) {
    final isLiked = _likedPostIds.contains(post.id);
    final current = _likeCounts[post.id] ?? post.likes;

    setState(() {
      if (isLiked) {
        _likedPostIds.remove(post.id);
        _likeCounts[post.id] = current - 1;
      } else {
        _likedPostIds.add(post.id);
        _likeCounts[post.id] = current + 1;
      }
    });
  }

  void _openCommentsSheet(SocialPost post) {
    final comments = _comments[post.id] ?? [];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${comments.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No comments yet.\nBe the first to say hi!',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final c = comments[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFFFFE0C2),
                          child: Icon(
                            CupertinoIcons.person_fill,
                            size: 16,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCreatePostSheet() async {
    if (widget.sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No plogging records yet. Please run first.'),
        ),
      );
      return;
    }

    String? selectedSessionId = widget.sessions.first.id;
    PlatformFile? selectedFile;
    final captionController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> pickFile() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
                allowMultiple: false,
                withData: true,
              );
              if (result != null && result.files.isNotEmpty) {
                setModalState(() {
                  selectedFile = result.files.first;
                });
              }
            }

            final selectedSession = widget.sessions.firstWhere(
                  (s) => s.id == selectedSessionId,
              orElse: () => widget.sessions.first,
            );

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const Text(
                      'Create a new post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Link a plogging record',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedSessionId,
                      items: widget.sessions.map((s) {
                        final date =
                            '${s.date.year}.${s.date.month.toString().padLeft(2, '0')}.${s.date.day.toString().padLeft(2, '0')}';
                        final label =
                            '$date · ${s.routeName} · ${s.distanceKm.toStringAsFixed(1)} km';
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          selectedSessionId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Caption',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: captionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'How was your plogging today?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload a photo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: pickFile,
                          icon: const Icon(CupertinoIcons.photo_on_rectangle),
                          label: const Text('Choose image'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedFile?.name ?? 'No file selected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (selectedFile?.bytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          selectedFile!.bytes!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final caption = captionController.text.trim();
                          final s = selectedSession;

                          final newPost = SocialPost(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            userName: 'you',
                            routeName: s.routeName,
                            imageUrl: '', // 실제 이미지는 _postImages에 저장
                            likes: 0,
                            comments: 0,
                            trashCount: s.trashCount,
                            distanceKm: s.distanceKm,
                          );

                          // 부모에게 알림 (메인 상태 업데이트)
                          widget.onPostCreated(newPost);

                          setState(() {
                            _likeCounts[newPost.id] = 0;
                            _comments[newPost.id] = [
                              'Nice run!',
                              'Thanks for cleaning up 🧡',
                              if (caption.isNotEmpty) caption,
                            ];
                            if (selectedFile?.bytes != null) {
                              _postImages[newPost.id] = selectedFile!.bytes!;
                            }
                          });

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post created.'),
                            ),
                          );
                        },
                        icon: const Icon(CupertinoIcons.paperplane_fill),
                        label: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostImage(SocialPost p) {
    if (_postImages.containsKey(p.id)) {
      // 업로드한 로컬 이미지
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          _postImages[p.id]!,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    if (p.imageUrl.isNotEmpty) {
      // 나중에 더미 이미지 URL을 넣어두면 여기서 보여줄 수 있음
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          p.imageUrl,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    // 기본 플레이스홀더
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Text(
          'Photo placeholder\n(image will be shown here)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.posts;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.camera_fill, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Share today\'s plogging photo and stats.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: _openCreatePostSheet,
                    child: const Text('Create post'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: posts.isEmpty
                  ? const Center(
                child: Text(
                  'No posts yet.\nShare your first plogging story!',
                  textAlign: TextAlign.center,
                ),
              )
                  : ListView.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = posts[index];
                  final likes =
                      _likeCounts[p.id] ?? p.likes;
                  final commentsCount =
                      _comments[p.id]?.length ?? p.comments;
                  final isLiked =
                  _likedPostIds.contains(p.id);

                  return GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더: 유저 + 코스 이름
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                              Colors.orange.withOpacity(0.2),
                              child: Text(
                                p.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  p.routeName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildPostImage(p),
                        const SizedBox(height: 8),
                        Text(
                          'Total ${p.distanceKm.toStringAsFixed(1)} km · ${p.trashCount} items collected',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _toggleLike(p),
                              icon: Icon(
                                isLiked
                                    ? CupertinoIcons.heart_solid
                                    : CupertinoIcons.heart,
                                color: isLiked
                                    ? AppTheme.accent
                                    : Colors.black,
                              ),
                            ),
                            Text('$likes'),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () =>
                                  _openCommentsSheet(p),
                              icon: const Icon(
                                CupertinoIcons.chat_bubble,
                              ),
                            ),
                            Text('$commentsCount'),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
