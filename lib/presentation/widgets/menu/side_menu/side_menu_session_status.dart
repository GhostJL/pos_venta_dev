import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posventa/presentation/providers/providers.dart';

class SideMenuSessionStatus extends ConsumerWidget {
  const SideMenuSessionStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(getCurrentCashSessionUseCaseProvider).call(),
      builder: (context, snapshot) {
        final hasOpenSession = snapshot.data != null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasOpenSession
                ? Colors.green.withAlpha(20)
                : Colors.orange.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasOpenSession
                  ? Colors.green.withAlpha(50)
                  : Colors.orange.withAlpha(50),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasOpenSession ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasOpenSession ? 'Caja Abierta' : 'Caja Cerrada',
                  style: TextStyle(
                    color: hasOpenSession ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
