import '../config/app_constants.dart';

class SearchQuery {
  SearchQuery._();

  static String sanitize(
    String raw, {
    int maxLength = AppConstants.searchMaxLength,
  }) {
    final trimmed = raw.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return trimmed.substring(0, maxLength);
  }
}
