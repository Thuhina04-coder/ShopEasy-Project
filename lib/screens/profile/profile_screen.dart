import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/theme.dart';
import 'edit_profile_screen.dart';
import 'address_screen.dart';
import '../orders/order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline,
                      size: 80, color: AppTheme.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'Please sign in to view your profile',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: user.avatarColorValue,
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        if (user.phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phone,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          label: 'Orders',
                          value: '${orderProvider.orders.length}',
                          icon: Icons.receipt_long,
                        ),
                        _StatItem(
                          label: 'Addresses',
                          value: '${user.addresses.length}',
                          icon: Icons.location_on,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const EditProfileScreen()),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'My Addresses',
                          subtitle: 'Manage your delivery addresses',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const AddressScreen()),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'Order History',
                          subtitle: 'View your past orders',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const OrderHistoryScreen()),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get help with your account',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Help & Support'),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Contact us:'),
                                    SizedBox(height: 8),
                                    Text('Email: support@shopeasy.lk'),
                                    Text('Phone: +94 11 234 5678'),
                                    Text('Hours: Mon-Fri, 9AM - 6PM'),
                                    SizedBox(height: 12),
                                    Text('FAQ:'),
                                    SizedBox(height: 4),
                                    Text(
                                        '• Orders typically ship within 1-2 days'),
                                    Text(
                                        '• Free shipping on orders above Rs. 5000'),
                                    Text('• 7-day return policy on all items'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.info_outline,
                          title: 'About ShopEasy',
                          subtitle: 'Version 1.0.0',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'ShopEasy',
                              applicationVersion: '1.0.0',
                              applicationIcon: const Icon(
                                Icons.shopping_bag_rounded,
                                size: 48,
                                color: AppTheme.primaryColor,
                              ),
                              children: [
                                const Text(
                                  'ShopEasy is a mobile shopping application for Sri Lanka that allows you to browse products, compare prices, add items to your cart, and order products securely.',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    color: Colors.white,
                    child: _MenuItem(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      subtitle: 'Sign out of your account',
                      iconColor: AppTheme.errorColor,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text(
                                'Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  auth.logout();
                                },
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(
                                      color: AppTheme.errorColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.primaryColor),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: AppTheme.textHint),
      onTap: onTap,
    );
  }
}
