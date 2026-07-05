import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';

class ErrorTranslator {
  static String translate(BuildContext context, String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return AppLocalizations.of(context)!.somethingWentWrong;
    }

    final l10n = AppLocalizations.of(context)!;
    final message = errorMessage.toLowerCase();

    // Map common server errors to localized strings
    if (message.contains("invalid email or password")) {
      return l10n.invalidEmailOrPassword;
    }
    
    if (message.contains("please fill all fields")) {
      return l10n.pleaseFillAllFields;
    }
    
    if (message.contains("at least one image")) {
      return l10n.pleaseAddOneImage;
    }

    if (message.contains("please login again before adding")) {
      return l10n.pleaseLoginBeforeAdding;
    }

    if (message.contains("please login again before updating")) {
      return l10n.pleaseLoginBeforeUpdating;
    }

    if (message.contains("failed to upload image")) {
      return l10n.failedToUploadImage;
    }

    if (message.contains("failed to upload video")) {
      return l10n.failedToUploadVideo;
    }

    // Clean up "Exception: " prefix if present but no direct match found
    if (errorMessage.startsWith("Exception: ")) {
      return errorMessage.substring("Exception: ".length);
    }

    return errorMessage;
  }
}
