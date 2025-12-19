import 'package:flutter/material.dart';
import 'package:posventa/core/constants/ui_constants.dart';

class GenericFormScaffold extends StatelessWidget {
  final String title;
  final bool isLoading;
  final VoidCallback onSubmit;
  final String submitButtonText;
  final Widget child;
  final GlobalKey<FormState> formKey;

  const GenericFormScaffold({
    super.key,
    required this.title,
    required this.isLoading,
    required this.onSubmit,
    required this.submitButtonText,
    required this.child,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingLarge,
                vertical: UIConstants.paddingMedium,
              ),
              child: child,
            ),
          ),
          if (isLoading)
            Container(
              color: colorScheme.surface.withAlpha(128),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withAlpha(50),
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          UIConstants.paddingLarge,
          UIConstants.paddingMedium,
          UIConstants.paddingLarge,
          UIConstants.paddingLarge + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FilledButton(
          onPressed: isLoading ? null : onSubmit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                UIConstants.borderRadiusMedium,
              ),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  submitButtonText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
