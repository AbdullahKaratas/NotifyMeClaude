import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../widgets/reminder_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<String> _scheduledNotifications = {};

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    await NotificationService.requestPermissions();
  }

  void _scheduleNotificationsForNewReminders(List<Reminder> reminders) {
    for (final reminder in reminders) {
      if (!_scheduledNotifications.contains(reminder.id) &&
          !reminder.isDone &&
          reminder.dueAt.isAfter(DateTime.now())) {
        NotificationService.scheduleReminder(reminder);
        _scheduledNotifications.add(reminder.id);
      }
    }
  }

  Future<void> _markAsDone(Reminder reminder) async {
    await SupabaseService.markAsDone(reminder.id);
    await NotificationService.cancelReminder(reminder.id);
    _scheduledNotifications.remove(reminder.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erledigt!'),
          action: SnackBarAction(
            label: 'Rückgängig',
            onPressed: () async {
              await SupabaseService.markAsNotDone(reminder.id);
              await NotificationService.scheduleReminder(reminder);
              _scheduledNotifications.add(reminder.id);
            },
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    await SupabaseService.deleteReminder(reminder.id);
    await NotificationService.cancelReminder(reminder.id);
    _scheduledNotifications.remove(reminder.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Reminders'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Reminder>>(
        stream: SupabaseService.watchReminders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          final allReminders = snapshot.data!;

          // Schedule notifications for new reminders
          _scheduleNotificationsForNewReminders(allReminders);

          // Filter to show only pending reminders
          final pendingReminders =
              allReminders.where((r) => !r.isDone).toList();

          if (pendingReminders.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator.adaptive(
            onRefresh: () async {
              // The stream will automatically update
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: pendingReminders.length,
              itemBuilder: (context, index) {
                final reminder = pendingReminders[index];
                return ReminderTile(
                  reminder: reminder,
                  onDone: () => _markAsDone(reminder),
                  onDelete: () => _deleteReminder(reminder),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Alles erledigt!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nutze Claude Code um neue\nReminders zu erstellen',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Verbindungsfehler',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Bitte prüfe deine Internetverbindung',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
