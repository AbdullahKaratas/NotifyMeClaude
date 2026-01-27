import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Watch all reminders in realtime (sorted by due date)
  static Stream<List<Reminder>> watchReminders() {
    return _client
        .from('reminders')
        .stream(primaryKey: ['id'])
        .order('due_at', ascending: true)
        .map((data) => data.map((json) => Reminder.fromJson(json)).toList());
  }

  /// Get all pending reminders (not done)
  static Future<List<Reminder>> getPendingReminders() async {
    final response = await _client
        .from('reminders')
        .select()
        .eq('is_done', false)
        .order('due_at', ascending: true);

    return (response as List)
        .map((json) => Reminder.fromJson(json))
        .toList();
  }

  /// Mark a reminder as done
  static Future<void> markAsDone(String id) async {
    await _client
        .from('reminders')
        .update({'is_done': true})
        .eq('id', id);
  }

  /// Mark a reminder as not done (undo)
  static Future<void> markAsNotDone(String id) async {
    await _client
        .from('reminders')
        .update({'is_done': false})
        .eq('id', id);
  }

  /// Delete a reminder permanently
  static Future<void> deleteReminder(String id) async {
    await _client.from('reminders').delete().eq('id', id);
  }

  /// Create a new reminder (for manual creation in app)
  static Future<void> createReminder({
    required String title,
    String? description,
    required DateTime dueAt,
  }) async {
    await _client.from('reminders').insert({
      'title': title,
      'description': description,
      'due_at': dueAt.toIso8601String(),
    });
  }

  /// Update reminder time (snooze)
  static Future<void> snoozeReminder(String id, DateTime newDueAt) async {
    await _client
        .from('reminders')
        .update({'due_at': newDueAt.toIso8601String()})
        .eq('id', id);
  }
}
