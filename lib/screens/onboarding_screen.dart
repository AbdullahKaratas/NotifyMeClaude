import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/config_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onConfigured;

  const OnboardingScreen({super.key, required this.onConfigured});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _error;
  int _currentStep = 0;

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _testAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Test the connection
      final testClient = SupabaseClient(
        _urlController.text.trim(),
        _keyController.text.trim(),
      );

      // Try to query the reminders table
      await testClient.from('reminders').select().limit(1);

      // Save configuration
      await ConfigService.saveSupabaseConfig(
        url: _urlController.text.trim(),
        anonKey: _keyController.text.trim(),
      );

      // Initialize Supabase with new config
      await Supabase.initialize(
        url: _urlController.text.trim(),
        anonKey: _keyController.text.trim(),
      );

      widget.onConfigured();
    } catch (e) {
      setState(() {
        _error = 'Verbindung fehlgeschlagen. Bitte prüfe deine Eingaben.\n\nFehler: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97757),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Center(
                  child: Text(
                    'NotifyMe',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Powered by Claude Code',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Setup',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Erstelle ein Supabase Projekt\n'
                        '2. Führe das SQL-Schema aus (siehe GitHub)\n'
                        '3. Kopiere URL & Anon Key hier rein',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Supabase URL
                Text(
                  'Supabase URL',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'https://xxxxx.supabase.co',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte URL eingeben';
                    }
                    if (!value.startsWith('https://') || !value.contains('.supabase.co')) {
                      return 'Ungültige Supabase URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Anon Key
                Text(
                  'Anon Key (public)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _keyController,
                  decoration: InputDecoration(
                    hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6...',
                    prefixIcon: const Icon(Icons.key),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Anon Key eingeben';
                    }
                    if (!value.startsWith('eyJ')) {
                      return 'Ungültiger Anon Key (sollte mit eyJ beginnen)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Error message
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Connect button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _testAndSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD97757),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verbinden',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Help link
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Could open GitHub readme
                    },
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: const Text('Anleitung auf GitHub'),
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
