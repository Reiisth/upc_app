// lib/pages/usher/add_member_page.dart
import 'package:flutter/material.dart';
import '../../models/member_profile.dart';
import '../../services/account_creation_service.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _memberService = MemberService();
  final _accountService = AccountCreationService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? _birthdate;
  Gender? _gender;
  String? _civilStatus;
  bool _isSubmitting = false;

  static const _civilStatusOptions = ['Single', 'Married', 'Widowed', 'Separated'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthdate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a birthdate.')));
      return;
    }
    if (_gender == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a gender.')));
      return;
    }
    if (_civilStatus == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a civil status.')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = await _accountService.createAccount(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _memberService.createMember(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        birthdate: _birthdate!,
        gender: _gender!,
        civilStatus: _civilStatus!,
        address: _addressController.text.trim(),
        memberSince: DateTime.now(),
        linkedUid: uid,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Member added successfully.')));
      Navigator.of(context).pop(true); // tells the members list to refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Member', style: AppTextStyles.bodyh1),
        actions: [
          Image.asset('assets/images/upc-logo.png', height: 40),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.bgGradient),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 28),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Photo upload unavailable (storage not configured)',
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Tap to upload photo (optional)',
                        style: AppTextStyles.bodyMuted),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name',
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name',
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _middleNameController,
                    decoration: const InputDecoration(labelText: 'Middle Name (optional)',
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),),
                  ),
                  const SizedBox(height: 16),

                  InkWell(
                    onTap: _pickBirthdate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: "Birthdate",
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),),
                      child: Text(
                        _birthdate == null
                            ? 'Birthdate'
                            : '${_birthdate!.month}/${_birthdate!.day}/${_birthdate!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<Gender>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender',
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),),
                    items: const [
                      DropdownMenuItem(value: Gender.male, child: Text('Male')),
                      DropdownMenuItem(value: Gender.female, child: Text('Female')),
                    ],
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _civilStatus,
                    decoration: const InputDecoration(labelText: 'Civil Status',
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),),
                    items: _civilStatusOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) => setState(() => _civilStatus = value),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address',
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),),
                    maxLines: 2,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 24),

                  const Text('Login Account', style: AppTextStyles.bodyh2),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email',
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password',
                      fillColor: AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textMuted, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      ),),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text('Add Member',
                            style: AppTextStyles.button.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}