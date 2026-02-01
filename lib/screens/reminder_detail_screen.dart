import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../services/supabase_service.dart';

class ReminderDetailScreen extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDone;
  final VoidCallback onDelete;

  const ReminderDetailScreen({
    super.key,
    required this.reminder,
    required this.onDone,
    required this.onDelete,
  });

  String _formatDueDate(DateTime dueAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueAt.year, dueAt.month, dueAt.day);

    final timeFormat = DateFormat.Hm();
    final dateFormat = DateFormat.yMMMd('de_DE');
    final dayFormat = DateFormat.EEEE('de_DE');

    String dayPart;
    if (dueDay == today) {
      dayPart = 'Heute';
    } else if (dueDay == tomorrow) {
      dayPart = 'Morgen';
    } else if (dueAt.difference(now).inDays < 7 && dueAt.isAfter(now)) {
      dayPart = dayFormat.format(dueAt);
    } else {
      dayPart = dateFormat.format(dueAt);
    }

    return '$dayPart um ${timeFormat.format(dueAt)} Uhr';
  }

  void _copyToClipboard(BuildContext context) {
    final text = StringBuffer();
    text.writeln('# ${reminder.title}');
    text.writeln();
    text.writeln('**Fällig:** ${_formatDueDate(reminder.dueAt)}');
    if (reminder.description != null && reminder.description!.isNotEmpty) {
      text.writeln();
      text.writeln('---');
      text.writeln();
      text.writeln(reminder.description);
    }

    Clipboard.setData(ClipboardData(text: text.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('In Zwischenablage kopiert'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription = reminder.description != null && reminder.description!.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Kopieren',
            onPressed: () => _copyToClipboard(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'done') {
                onDone();
                Navigator.pop(context);
              } else if (value == 'delete') {
                showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Löschen?'),
                    content: Text('„${reminder.title}" wirklich löschen?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Abbrechen'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                          onDelete();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Löschen'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'done',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Als erledigt markieren'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Löschen'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              reminder.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Due date chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: reminder.isOverdue
                    ? Colors.red.shade50
                    : reminder.isDueToday
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    reminder.isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.schedule,
                    size: 18,
                    color: reminder.isOverdue
                        ? Colors.red.shade700
                        : reminder.isDueToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDueDate(reminder.dueAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: reminder.isOverdue
                          ? Colors.red.shade700
                          : reminder.isDueToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Chart image if available
            if (reminder.imageUrl != null && reminder.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  reminder.imageUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chart konnte nicht geladen werden',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (hasDescription) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Description with Markdown support
              MarkdownBody(
                data: reminder.description!,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                  h1: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  h2: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  h3: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  code: TextStyle(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 4,
                      ),
                    ),
                  ),
                  blockquotePadding: const EdgeInsets.only(left: 16),
                  listBullet: theme.textTheme.bodyLarge,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Created at info
            Text(
              'Erstellt am ${DateFormat.yMMMd('de_DE').format(reminder.createdAt)} um ${DateFormat.Hm().format(reminder.createdAt)} Uhr',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          onDone();
          Navigator.pop(context);
        },
        icon: const Icon(Icons.check),
        label: const Text('Erledigt'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}
