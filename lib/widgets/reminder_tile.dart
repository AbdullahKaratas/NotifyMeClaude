import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';

class ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDone;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onDone,
    required this.onDelete,
    this.onTap,
  });

  String _formatDueDate(DateTime dueAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueAt.year, dueAt.month, dueAt.day);

    final timeFormat = DateFormat.Hm(); // 14:00

    if (dueDay == today) {
      return 'Heute, ${timeFormat.format(dueAt)}';
    } else if (dueDay == tomorrow) {
      return 'Morgen, ${timeFormat.format(dueAt)}';
    } else if (dueAt.difference(now).inDays < 7) {
      // Within a week: show weekday
      final dayFormat = DateFormat.EEEE('de_DE'); // Montag, Dienstag, etc.
      return '${dayFormat.format(dueAt)}, ${timeFormat.format(dueAt)}';
    } else {
      // Further out: show full date
      final dateFormat = DateFormat.yMMMd('de_DE'); // 27. Jan 2024
      return '${dateFormat.format(dueAt)}, ${timeFormat.format(dueAt)}';
    }
  }

  Color _getDueDateColor(BuildContext context) {
    if (reminder.isOverdue) {
      return Colors.red.shade400;
    } else if (reminder.isDueToday) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(reminder.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        color: Colors.green.shade400,
        child: const Icon(Icons.check, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right: mark as done
          onDone();
          return true;
        } else {
          // Swipe left: delete with confirmation
          return await showDialog<bool>(
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
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Löschen'),
                ),
              ],
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Indicator dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reminder.isOverdue
                      ? Colors.red.shade400
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (reminder.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        reminder.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatDueDate(reminder.dueAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getDueDateColor(context),
                        fontWeight: reminder.isOverdue || reminder.isDueToday
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
