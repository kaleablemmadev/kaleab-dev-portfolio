import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_provider.dart';
import 'main_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _nameController = TextEditingController();

  void _completeSetup() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ref.read(userNameProvider.notifier).setName(name);
      await ref.read(storageServiceProvider).setFirstLaunchCompleted();
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome to misol.",
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Your gentle daily companion. How should we call you?",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Your name',
                ),
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _completeSetup(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _completeSetup,
                child: const Text("Begin"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
