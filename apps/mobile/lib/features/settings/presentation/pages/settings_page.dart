import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: CurvedGradientHeader(
                title: AppStrings.settings,
                subtitle: 'Manage your preferences',
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6B7280),
                    Color(0xFF4B5563),
                  ],
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
                    return _buildProfileCard(patientName, patientId);
                  },
                ),
              ),
            ),

            // Settings list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader('General'),
                  _buildSettingsCard([
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      title: AppStrings.notifications,
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppColors.primary,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      title: AppStrings.darkMode,
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {},
                        activeColor: AppColors.primary,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: AppStrings.language,
                      subtitle: 'English',
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader('Support'),
                  _buildSettingsCard([
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & FAQ',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader(AppStrings.about),
                  _buildSettingsCard([
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: AppStrings.version,
                      subtitle: AppConstants.appVersion,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Logout button
                  _buildLogoutButton(context),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(String patientName, String patientId) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${patientId.length > 8 ? patientId.substring(0, 8) : patientId}...',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return AppButton(
      label: AppStrings.logout,
      variant: AppButtonVariant.outlined,
      icon: Icons.logout_rounded,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(AppStrings.logout),
            content: const Text(AppStrings.logoutConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                child: Text(
                  AppStrings.logout,
                  style: TextStyle(color: AppColors.error),
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
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(title, style: AppTypography.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.bodySmall)
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                )
              : null),
      onTap: onTap,
    );
  }
}
