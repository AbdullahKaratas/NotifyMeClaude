import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../services/config_service.dart';
import '../widgets/reminder_tile.dart';
import 'reminder_detail_screen.dart';

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
      if (!_scheduledNotifications.contains(reminder.id) && !reminder.isDone) {
        // If reminder is due within 30 seconds, show notification immediately
        final now = DateTime.now();
        final diff = reminder.dueAt.difference(now);

        if (diff.inSeconds <= 30) {
          // Show immediate notification for "now" reminders
          NotificationService.showNow(
            'Reminder',
            reminder.title,
          );
        } else if (reminder.dueAt.isAfter(now)) {
          // Schedule for future
          NotificationService.scheduleReminder(reminder);
        }

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

  void _openDetail(Reminder reminder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReminderDetailScreen(
          reminder: reminder,
          onDone: () => _markAsDone(reminder),
          onDelete: () => _deleteReminder(reminder),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Einstellungen',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Supabase URL'),
                subtitle: Text(
                  ConfigService.supabaseUrl ?? 'Nicht konfiguriert',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Konfiguration zurücksetzen'),
                subtitle: const Text('Verbindung trennen und neu einrichten'),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Zurücksetzen?'),
                      content: const Text(
                        'Die Supabase-Verbindung wird getrennt. Du musst die App neu konfigurieren.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Zurücksetzen'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    await ConfigService.clearConfig();
                    // Restart app - user needs to reconfigure
                    if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'NotifyMe v1.0.0 • Powered by Claude',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
          ),
        ],
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
                  onTap: () => _openDetail(reminder),
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
