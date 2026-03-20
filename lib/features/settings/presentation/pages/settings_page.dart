import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/hive_database.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color _backgroundBlack = Color(0xFF000000);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _danger = Color(0xFFD32F2F);

  static const String _pushNotificationsKey = 'pushNotificationsEnabled';
  static const String _biometricLoginKey = 'biometricLoginEnabled';

  bool _pushNotificationsEnabled = true;
  bool _biometricLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final settings = HiveDatabase.settingsBox;
    setState(() {
      _pushNotificationsEnabled =
          settings.get(_pushNotificationsKey, defaultValue: true) as bool;
      _biometricLoginEnabled =
          settings.get(_biometricLoginKey, defaultValue: false) as bool;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    await HiveDatabase.settingsBox.put(key, value);
  }

  Future<void> _togglePushNotifications(bool value) async {
    setState(() => _pushNotificationsEnabled = value);
    await _savePreference(_pushNotificationsKey, value);
  }

  Future<void> _toggleBiometricLogin(bool value) async {
    setState(() => _biometricLoginEnabled = value);
    await _savePreference(_biometricLoginKey, value);
  }

  void _showComingSoonMessage(String label) {
    showAppSnackBarWithContext(
      context,
      '$label will be available in a future update.',
      isError: false,
    );
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Do you want to sign out of the PGR fintech workspace?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/splash');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final horizontalPadding = size.width < 420 ? 18.0 : size.width * 0.06;
    const topSpacing = 12.0;

    return Scaffold(
      backgroundColor: _backgroundBlack,
      body: Stack(
        children: [
          const _LuxuryBackground(),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topSpacing,
                horizontalPadding,
                28,
              ),
              children: [
                _buildTopBar(context),
                const SizedBox(height: 20),
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildSectionLabel('App Settings'),
                const SizedBox(height: 12),
                _buildAppSettingsSection(),
                const SizedBox(height: 24),
                _buildSectionLabel('Account Management'),
                const SizedBox(height: 12),
                _buildAccountSection(),
                const SizedBox(height: 24),
                _buildSectionLabel('Information'),
                const SizedBox(height: 12),
                _buildInfoSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _GlassIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => context.pop(),
        ),
        const Spacer(),
        const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 52),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        var displayName = 'PGR Fintech';
        var subtitle = 'secure@pgr-fintech.app';

        if (state is ShopLoaded) {
          if (state.shop.name.trim().isNotEmpty) {
            displayName = state.shop.name.trim();
          }
          if (state.shop.phoneNumber.trim().isNotEmpty) {
            subtitle = state.shop.phoneNumber.trim();
          }
        }

        final initials = displayName
            .split(' ')
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

        return _GlassSection(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF5DE8A), _gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withOpacity(0.35),
                      blurRadius: 24,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.isEmpty ? 'PG' : initials,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Profile',
                      style: TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 12,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppSettingsSection() {
    return Column(
      children: [
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            final isDarkMode = mode == ThemeMode.dark;
            return _GlassSettingTile(
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: 'Keep the interface in luxury dark mode.',
              trailing: Switch.adaptive(
                value: isDarkMode,
                activeColor: _gold,
                activeTrackColor: _gold.withOpacity(0.35),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white12,
                onChanged: (value) {
                  context
                      .read<ThemeCubit>()
                      .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _GlassSettingTile(
          icon: Icons.notifications_active_outlined,
          title: 'Push Notifications',
          subtitle: 'Receive payment alerts and account activity updates.',
          trailing: Switch.adaptive(
            value: _pushNotificationsEnabled,
            activeColor: _gold,
            activeTrackColor: _gold.withOpacity(0.35),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white12,
            onChanged: _togglePushNotifications,
          ),
        ),
        const SizedBox(height: 12),
        _GlassSettingTile(
          icon: Icons.fingerprint_rounded,
          title: 'Biometric Login',
          subtitle: 'Use fingerprint or face unlock for secure access.',
          trailing: Switch.adaptive(
            value: _biometricLoginEnabled,
            activeColor: _gold,
            activeTrackColor: _gold.withOpacity(0.35),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white12,
            onChanged: _toggleBiometricLogin,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        _GlassSettingTile(
          icon: Icons.credit_card_rounded,
          title: 'Payment Methods',
          subtitle: 'Manage linked cards, wallets, and payout preferences.',
          onTap: () => _showComingSoonMessage('Payment Methods'),
        ),
        const SizedBox(height: 12),
        _GlassSettingTile(
          icon: Icons.receipt_long_rounded,
          title: 'Transaction History',
          subtitle: 'Review your latest transfers, bills, and reconciliations.',
          onTap: () => _showComingSoonMessage('Transaction History'),
        ),
        const SizedBox(height: 12),
        _GlassSettingTile(
          icon: Icons.shield_outlined,
          title: 'Security',
          subtitle: 'Update PIN policies, sessions, and risk protections.',
          onTap: () => _showComingSoonMessage('Security'),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _GlassSettingTile(
          icon: Icons.info_outline_rounded,
          title: 'About Us',
          subtitle: 'Learn more about the PGR fintech platform.',
          onTap: () => _showComingSoonMessage('About Us'),
        ),
        const SizedBox(height: 12),
        _GlassSettingTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'See how your data is protected and processed.',
          onTap: () => _showComingSoonMessage('Privacy Policy'),
        ),
        const SizedBox(height: 12),
        _GlassSettingTile(
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Sign out from this device.',
          iconColor: _danger,
          titleColor: const Color(0xFFFF8A80),
          accentBorderColor: _danger.withOpacity(0.35),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFFF8A80),
          ),
          onTap: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xB3D4AF37),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
      ),
    );
  }
}

class _LuxuryBackground extends StatelessWidget {
  const _LuxuryBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF000000),
            Color(0xFF080808),
            Color(0xFF111111),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _GlowOrb(
              size: 260,
              color: Color(0x33D4AF37),
            ),
          ),
          Positioned(
            left: -70,
            top: 220,
            child: _GlowOrb(
              size: 200,
              color: Color(0x22FFFFFF),
            ),
          ),
          Positioned(
            bottom: -90,
            right: 20,
            child: _GlowOrb(
              size: 220,
              color: Color(0x26D4AF37),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = const Color(0x26FFFFFF),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassSettingTile extends StatelessWidget {
  const _GlassSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = const Color(0xFFD4AF37),
    this.titleColor = Colors.white,
    this.accentBorderColor = const Color(0x26FFFFFF),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color titleColor;
  final Color accentBorderColor;

  @override
  Widget build(BuildContext context) {
    return _GlassSection(
      borderColor: accentBorderColor,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(0.14),
            border: Border.all(color: iconColor.withOpacity(0.22)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
        trailing: trailing ??
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD4AF37),
            ),
        onTap: onTap,
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(0.08),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
