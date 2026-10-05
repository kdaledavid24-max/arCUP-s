import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Customer profile screen with account info, role badge, admin shortcut, and session controls.
class ProfileScreen extends StatelessWidget {
  final VoidCallback? onNavigateToOrders;

  const ProfileScreen({super.key, this.onNavigateToOrders});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isAuthenticated = auth.isAuthenticated;
    final isAdmin = auth.isAdmin;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Avatar & Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.goldAccent, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.darkBackground,
                      child: Icon(
                        isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                        size: 42,
                        color: AppTheme.goldAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Guest User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Browsing as Guest',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  if (user?.phone != null && user!.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Membership / Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? AppTheme.goldAccent.withValues(alpha: 0.15)
                          : AppTheme.cardBorder,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAdmin ? AppTheme.goldAccent : AppTheme.cardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAdmin ? Icons.admin_panel_settings_rounded : Icons.stars_rounded,
                          color: isAdmin ? AppTheme.goldAccent : AppTheme.caramelAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAdmin ? 'System Administrator' : 'Food Ordering Member',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAdmin ? AppTheme.goldAccent : AppTheme.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Admin Dashboard Access Button (if user is Admin)
            if (isAdmin) ...[
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/admin'),
                icon: const Icon(Icons.dashboard_customize_rounded),
                label: const Text('OPEN ADMIN DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Quick Menu Actions
            Material(
              color: AppTheme.cardSurface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_rounded, color: AppTheme.goldAccent),
                    title: const Text('Order History', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
                    subtitle: const Text('View and track your past orders', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                    onTap: () {
                      if (onNavigateToOrders != null) {
                        onNavigateToOrders!();
                      } else {
                        Navigator.pushNamed(context, '/orders');
                      }
                    },
                  ),
                  const Divider(height: 1, color: AppTheme.cardBorder),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppTheme.goldAccent),
                    title: const Text('Store Location', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
                    subtitle: const Text('Concepcion, Tarlac, Philippines', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppTheme.cardBorder),
                  ListTile(
                    leading: const Icon(Icons.access_time_rounded, color: AppTheme.goldAccent),
                    title: const Text('Store Hours', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
                    subtitle: const Text('Mon - Sun: 8:00 AM - 11:00 PM', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About Food Ordering
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppTheme.goldAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'About Food Ordering',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Food Ordering is a complete ordering system featuring coffee, frappes, garden salads, and gourmet pastas. Built with offline-first local persistence and live tracking.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Login / Logout Button
            if (isAuthenticated)
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign In / Register', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
