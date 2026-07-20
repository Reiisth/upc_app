// lib/pages/pastor/services_list_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../theme/app_theme.dart';

class ServicesListPage extends StatelessWidget {
  const ServicesListPage({super.key});

  Future<List<ServiceModel>> _fetchServices() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('services')
        .orderBy('startedAt', descending: true)
        .get();
    return snapshot.docs.map((d) => ServiceModel.fromDoc(d.id, d.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('All Services', style: AppTextStyles.heading2),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder<List<ServiceModel>>(
          future: _fetchServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final services = snapshot.data ?? [];
            if (services.isEmpty) {
              return const Center(
                child: Text('No services recorded yet.', style: AppTextStyles.bodyMuted),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final service = services[index];
                final isActive = service.status == ServiceStatus.active;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppShadows.card,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name, style: AppTextStyles.bodyh1),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMMM dd, yyyy — h:mm a').format(service.startedAt),
                              style: AppTextStyles.bodyMuted,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Ended',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}