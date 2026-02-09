import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Settings page with functional dark mode and language settings
/// Premium design with full dark mode support
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        body: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: CurvedGradientHeader(
                title: l10n.settings,
                subtitle: _getSubtitle(l10n),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF4B5563), const Color(0xFF374151)]
                      : [const Color(0xFF6B7280), const Color(0xFF4B5563)],
                ),
              ),
            ),

            // Profile section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final patientName = state is AuthAuthenticated
                        ? (state.patientName ?? 'Patient')
                        : 'Patient';
                    final patientId = state is AuthAuthenticated
                        ? state.patientId
                        : '';
                    return _buildProfileCard(context, patientName, patientId, isDark);
                  },
                ),
              ),
            ),

            // Settings list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader(context, _getGeneralLabel(l10n), isDark),
                  _buildSettingsCard(context, isDark, [
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: l10n.notifications,
                      isDark: isDark,
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return isDark ? Colors.white : AppColors.textOnPrimary;
                          }
                          return isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
                        }),
                        trackColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return isDark ? AppColors.primaryDarkMode : AppColors.primary;
                          }
                          return isDark ? AppColors.darkSurfaceHighest : AppColors.surfaceVariant;
                        }),
                        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.transparent;
                          }
                          return isDark ? AppColors.darkBorder : AppColors.border;
                        }),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      title: l10n.darkMode,
                      isDark: isDark,
                      trailing: Switch(
                        value: settings.isDarkMode,
                        onChanged: (value) {
                          settings.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return isDark ? Colors.white : AppColors.textOnPrimary;
                          }
                          return isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
                        }),
                        trackColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return isDark ? AppColors.primaryDarkMode : AppColors.primary;
                          }
                          return isDark ? AppColors.darkSurfaceHighest : AppColors.surfaceVariant;
                        }),
                        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.transparent;
                          }
                          return isDark ? AppColors.darkBorder : AppColors.border;
                        }),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: l10n.language,
                      subtitle: settings.currentLocaleName,
                      isDark: isDark,
                      onTap: () => _showLanguageDialog(context, settings, l10n, isDark),
                    ),
                    _SettingsTile(
                      icon: Icons.bedtime_rounded,
                      title: l10n.usualSleepTime,
                      subtitle: _formatSleepTime(settings.usualSleepTime, l10n),
                      isDark: isDark,
                      onTap: () => _showSleepTimeDialog(context, settings, l10n, isDark),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader(context, _getAccessibilityLabel(l10n), isDark),
                  _buildSettingsCard(context, isDark, [
                    _SettingsTile(
                      icon: Icons.text_fields_rounded,
                      title: _getFontSizeLabel(l10n),
                      subtitle: settings.getFontSizeDisplayName(
                        settings.fontSizeScale,
                        _getFontSizeSmallLabel(l10n),
                        _getFontSizeMediumLabel(l10n),
                        _getFontSizeLargeLabel(l10n),
                      ),
                      isDark: isDark,
                      onTap: () => _showFontSizeDialog(context, settings, l10n, isDark),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader(context, _getEmergencyLabel(l10n), isDark),
                  _buildCallDoctorCard(context, settings, l10n, isDark),

                  const SizedBox(height: 24),
                  _buildSectionHeader(context, _getSupportLabel(l10n), isDark),
                  _buildSettingsCard(context, isDark, [
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: _getHelpLabel(l10n),
                      isDark: isDark,
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: _getPrivacyLabel(l10n),
                      isDark: isDark,
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: _getTermsLabel(l10n),
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader(context, l10n.about, isDark),
                  _buildSettingsCard(context, isDark, [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: l10n.version,
                      subtitle: AppConstants.appVersion,
                      isDark: isDark,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Logout button
                  _buildLogoutButton(context, l10n, isDark),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for strings not yet in l10n
  String _getSubtitle(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Tercihlerinizi yönetin' : 'Manage your preferences';
  String _getGeneralLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Genel' : 'General';
  String _getSupportLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Destek' : 'Support';
  String _getHelpLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Yardım ve SSS' : 'Help & FAQ';
  String _getPrivacyLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Gizlilik Politikası' : 'Privacy Policy';
  String _getTermsLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Kullanım Koşulları' : 'Terms of Service';
  String _getSelectLanguageLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Dil Seçin' : 'Select Language';
  String _getAccessibilityLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Erişilebilirlik' : 'Accessibility';
  String _getFontSizeLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Yazı Boyutu' : 'Font Size';
  String _getFontSizeSmallLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Küçük' : 'Small';
  String _getFontSizeMediumLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Orta' : 'Medium';
  String _getFontSizeLargeLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Büyük' : 'Large';
  String _getEmergencyLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Acil Durum' : 'Emergency';
  String _getCallDoctorLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Doktoru Ara' : 'Call Doctor';
  String _getNoDoctorPhoneLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Doktor telefon numarası mevcut değil' : 'No doctor phone number available';
  String _getTapToCallLabel(AppLocalizations l10n) =>
      l10n.localeName == 'tr' ? 'Aramak için dokunun' : 'Tap to call';

  String _formatSleepTime(TimeOfDay time, AppLocalizations l10n) {
    // Use 24-hour format for Turkish locale
    if (l10n.localeName == 'tr') {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _showSleepTimeDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
    bool isDark,
  ) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: settings.usualSleepTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: isDark ? AppColors.primaryDarkMode : AppColors.primary,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null && context.mounted) {
      settings.setUsualSleepTime(selectedTime);
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sleepTimeUpdated),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        title: Text(
          _getSelectLanguageLabel(l10n),
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsProvider.supportedLocales.map((locale) {
            final isSelected = settings.locale.languageCode == locale.languageCode;
            return ListTile(
              title: Text(
                SettingsProvider.localeNames[locale.languageCode] ?? locale.languageCode,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: primaryColor)
                  : null,
              onTap: () {
                settings.setLocale(locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontSizeDialog(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    final fontSizeOptions = [
      (FontSizeScale.small, _getFontSizeSmallLabel(l10n), 'Aa', 18.0),
      (FontSizeScale.medium, _getFontSizeMediumLabel(l10n), 'Aa', 24.0),
      (FontSizeScale.large, _getFontSizeLargeLabel(l10n), 'Aa', 32.0),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
        title: Text(
          _getFontSizeLabel(l10n),
          style: TextStyle(color: textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fontSizeOptions.map((option) {
            final isSelected = settings.fontSizeScale == option.$1;
            return ListTile(
              leading: Text(
                option.$3,
                style: TextStyle(
                  fontSize: option.$4,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primaryColor : textPrimary,
                ),
              ),
              title: Text(
                option.$2,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? primaryColor : textPrimary,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: primaryColor)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settings.setFontSizeScale(option.$1);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCallDoctorCard(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final emergencyColor = isDark ? AppColors.errorDark : AppColors.error;

    // TODO: Get doctor phone from patient data - for now using settings
    final doctorPhone = settings.doctorPhone ?? '+90 505 540 80 09';

    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: borderColor, width: isDark ? 1 : 0),
          boxShadow: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: emergencyColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.phone_rounded,
                color: emergencyColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCallDoctorLabel(l10n),
                    style: AppTypography.titleMedium.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctorPhone,
                    style: AppTypography.bodyMedium.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String patientName, String patientId, bool isDark) {
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;
    final primaryColor = isDark ? AppColors.primaryDarkMode : AppColors.primary;
    final primaryLightColor = isDark
        ? AppColors.primaryDarkMode.withValues(alpha: 0.15)
        : AppColors.primaryLight;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: borderColor, width: isDark ? 1 : 0),
        boxShadow: isDark
            ? AppColors.darkCardShadow
            : AppColors.lightCardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: primaryLightColor,
            child: Icon(
              Icons.person_rounded,
              color: primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              patientName,
              style: AppTypography.titleLarge.copyWith(color: textPrimary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            color: textSecondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, bool isDark, List<Widget> children) {
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.cardBackground;
    final borderColor = isDark ? AppColors.darkBorderSubtle : Colors.transparent;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: borderColor, width: isDark ? 1 : 0),
        boxShadow: isDark
            ? AppColors.darkCardShadow
            : AppColors.lightCardShadow,
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Divider(height: 1, indent: 56, color: dividerColor),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n, bool isDark) {
    return AppButton(
      label: l10n.logout,
      variant: AppButtonVariant.outlined,
      icon: Icons.logout_rounded,
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.surface,
            title: Text(
              l10n.logout,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            content: Text(
              l10n.logoutConfirm,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                child: Text(
                  l10n.logout,
                  style: TextStyle(color: isDark ? AppColors.errorDark : AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconBg = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceVariant;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final chevronColor = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: AppTypography.bodyLarge.copyWith(color: textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.bodySmall.copyWith(color: textSecondary))
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: chevronColor,
                )
              : null),
      onTap: onTap,
    );
  }
}
