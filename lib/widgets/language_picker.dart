import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguagePicker extends StatelessWidget {
  final bool isWhite;

  const LanguagePicker({Key? key, this.isWhite = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        bool isVi = localeProvider.locale.languageCode == 'vi';

        return GestureDetector(
          onTap: () {
            if (isVi) {
              localeProvider.setLocale(const Locale('en'));
            } else {
              localeProvider.setLocale(const Locale('vi'));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isWhite ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isWhite ? Colors.white.withOpacity(0.5) : Colors.black12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVi ? '🇻🇳' : '🇬🇧',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  isVi ? 'VN' : 'EN',
                  style: TextStyle(
                    color: isWhite ? Colors.white : Colors.teal.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
