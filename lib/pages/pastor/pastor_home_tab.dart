// lib/pages/pastor/pastor_home_tab.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../services/service_service.dart';
import '../../theme/app_theme.dart';
import 'services_list_page.dart';
import 'present_members_page.dart';

class PastorHomeTab extends StatefulWidget {
  const PastorHomeTab({super.key});

  @override
  State<PastorHomeTab> createState() => _PastorHomeTabState();
}

class _PastorHomeTabState extends State<PastorHomeTab> {
  final _serviceService = ServiceService();
  late Future<ServiceModel?> _activeServiceFuture;
  bool _isProcessing = false;

  // Only one pastor account exists for this church — hardcoded.
  static const String _pastorFirstName = 'John';

  @override
  void initState() {
    super.initState();
    _activeServiceFuture = _serviceService.getActiveService();
  }

  Future<String?> _promptForServiceName() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Service', style: AppTextStyles.bodyh1),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Service name (optional)',
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 400, minWidth: 300),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Start', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStartService() async {
    final name = await _promptForServiceName();
    if (name == null) return; // cancelled

    setState(() => _isProcessing = true);
    try {
      await _serviceService.startService(name: name.isEmpty ? null : name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _activeServiceFuture = _serviceService.getActiveService();
        });
      }
    }
  }

  Future<void> _handleStopService(ServiceModel active) async {
    setState(() => _isProcessing = true);
    try {
      await _serviceService.endService(active.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop service: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _activeServiceFuture = _serviceService.getActiveService();
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WELCOME BACK!', style: AppTextStyles.greetingsub),
              const SizedBox(height: 4),
              const Text('Blessed day, Pastor $_pastorFirstName!',
                  style: AppTextStyles.herogreeting),
              const SizedBox(height: 20),

              FutureBuilder<ServiceModel?>(
                future: _activeServiceFuture,
                builder: (context, snapshot) {
                  final isLoading = snapshot.connectionState == ConnectionState.waiting;
                  final active = snapshot.data;
                  final isActive = active != null;

                  return Column(
                    children: [
                      // Date + status card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.primary, size: 28),
                            const SizedBox(height: 8),
                            Text(DateFormat('EEEE, dd MMMM yyyy').format(today),
                                style: AppTextStyles.bodyh1),
                            const SizedBox(height: 8),
                            if (isLoading)
                              const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isActive ? Colors.green : Colors.grey)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle,
                                        size: 8, color: isActive ? Colors.green : Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      isActive ? 'Service On-going' : 'No Active Service',
                                      style: TextStyle(
                                        color: isActive ? Colors.green : Colors.grey[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Start / Stop button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : () => isActive
                                  ? _handleStopService(active)
                                  : _handleStartService(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: isActive ? Colors.deepOrange : AppColors.primary,
                            side: BorderSide(
                                color: isActive ? Colors.deepOrange : AppColors.primary),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(isActive ? Icons.stop_circle : Icons.play_circle),
                          label: Text(
                            isActive ? 'Stop Service' : 'Start Service',
                            style: AppTextStyles.button.copyWith(
                                color: isActive ? Colors.deepOrange : AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _MenuButton(
                        icon: Icons.event_note,
                        label: 'Services',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ServicesListPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _MenuButton(
                        icon: Icons.groups,
                        label: 'View Present Members',
                        onTap: active == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PresentMembersPage(service: active),
                                  ),
                                );
                              },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(52),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Logout', style: AppTextStyles.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _MenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey.shade200 : AppColors.white,
          foregroundColor: isDisabled ? Colors.grey : AppColors.primary,
          side: BorderSide(color: isDisabled ? Colors.grey.shade300 : AppColors.primary),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: Icon(icon),
        label: Text(label,
            style: AppTextStyles.button.copyWith(
                color: isDisabled ? Colors.grey : AppColors.primary)),
      ),
    );
  }
}