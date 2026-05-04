import 'package:flutter/material.dart';

class StartupErrorPage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const StartupErrorPage({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),

              const SizedBox(height: 20),

              const Text(
                "Something went wrong",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Text(message, textAlign: TextAlign.center),

              const SizedBox(height: 30),

              ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
            ],
          ),
        ),
      ),
    );
  }
}
