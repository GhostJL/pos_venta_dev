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
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Stack(
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(UIConstants.paddingLarge),
              child: child,
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          UIConstants.paddingLarge,
          UIConstants.paddingSmall,
          UIConstants.paddingLarge,
          UIConstants.paddingLarge + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.paddingMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                UIConstants.borderRadiusMedium,
              ),
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(100),
          ),
          child: isLoading
              ? const SizedBox(
                  height: UIConstants.iconSizeSmall,
                  width: UIConstants.iconSizeSmall,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  submitButtonText,
                  style: const TextStyle(
                    fontSize: UIConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
