import 'package:flutter/material.dart';
import 'package:swipe_action_cell_x/swipe_action_cell_x.dart';

void main() {
  runApp(const SwipeActionExampleApp());
}

class SwipeActionExampleApp extends StatelessWidget {
  const SwipeActionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe Action Cell X Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const InboxScreen(),
    );
  }
}

class EmailItem {
  final String id;
  final String sender;
  final String subject;
  final String snippet;
  final String time;
  bool isRead;
  bool isPinned;

  EmailItem({
    required this.id,
    required this.sender,
    required this.subject,
    required this.snippet,
    required this.time,
    this.isRead = false,
    this.isPinned = false,
  });
}

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<EmailItem> _emails = [
    EmailItem(
      id: '1',
      sender: 'Flutter Team',
      subject: 'Flutter 3.27 & Impeller Performance Upgrades',
      snippet: 'Excited to announce new rendering milestones, Impeller 3D features...',
      time: '10:42 AM',
      isRead: false,
    ),
    EmailItem(
      id: '2',
      sender: 'GitHub Notifications',
      subject: '[PR] Merge pull request #42 from feature/swipe-cell',
      snippet: 'Automated CI tests passed with 100% code coverage. Ready to deploy.',
      time: 'Yesterday',
      isRead: true,
      isPinned: true,
    ),
    EmailItem(
      id: '3',
      sender: 'Apple Developer',
      subject: 'Your App Store Submission is Approved',
      snippet: 'Version 2.4.0 is now live across all App Store territories.',
      time: 'Sep 18',
      isRead: true,
    ),
    EmailItem(
      id: '4',
      sender: 'Stripe Billing',
      subject: 'Monthly Payout of \$12,450.00 Processed',
      snippet: 'Your funds have been initiated to your primary bank account.',
      time: 'Sep 15',
      isRead: true,
    ),
  ];

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _showNotice('Refreshed mailbox');
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _emails.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 0.5,
          indent: 72,
          color: Color(0xFFE5E5EA),
        ),
        itemBuilder: (context, index) {
          final item = _emails[index];

          return SwipeActionCell(
            key: ValueKey(item.id),
            // Left to Right Actions
            leftActions: [
              SwipeAction(
                title: item.isRead ? 'Unread' : 'Read',
                icon: Icon(item.isRead
                    ? Icons.mark_email_unread_outlined
                    : Icons.mark_email_read_outlined),
                backgroundColor: const Color(0xFF007AFF),
                onTap: () {
                  setState(() {
                    item.isRead = !item.isRead;
                  });
                  _showNotice(
                      'Marked as ${item.isRead ? "Read" : "Unread"}');
                },
              ),
              SwipeAction(
                title: item.isPinned ? 'Unpin' : 'Pin',
                icon: Icon(item.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                backgroundColor: const Color(0xFFFF9500),
                onTap: () {
                  setState(() {
                    item.isPinned = !item.isPinned;
                  });
                  _showNotice(item.isPinned ? 'Pinned message' : 'Unpinned');
                },
              ),
            ],
            // Right to Left Actions
            rightActions: [
              SwipeAction(
                title: 'More',
                icon: const Icon(Icons.more_horiz),
                backgroundColor: const Color(0xFF8E8E93),
                onTap: () => _showNotice('More actions for "${item.sender}"'),
              ),
              SwipeAction(
                title: 'Flag',
                icon: const Icon(Icons.flag_outlined),
                backgroundColor: const Color(0xFFFF9500),
                onTap: () => _showNotice('Flagged message'),
              ),
              SwipeAction(
                title: 'Trash',
                icon: const Icon(Icons.delete_outline),
                backgroundColor: const Color(0xFFFF3B30),
                performsFirstActionWithFullSwipe: true,
                onTap: () {
                  setState(() {
                    _emails.removeAt(index);
                  });
                  _showNotice('Deleted message from ${item.sender}');
                },
              ),
            ],
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF007AFF).withValues(alpha: 0.12),
                    child: Text(
                      item.sender[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (!item.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF007AFF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                item.sender,
                                style: TextStyle(
                                  fontWeight: item.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              item.time,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subject,
                          style: TextStyle(
                            fontWeight: item.isRead
                                ? FontWeight.normal
                                : FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.snippet,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
