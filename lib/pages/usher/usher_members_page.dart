// lib/pages/usher/usher_members_page.dart
import 'package:flutter/material.dart';
import '../../models/member_profile.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import 'add_member_page.dart';
import 'usher_member_detail_page.dart';

class UsherMembersPage extends StatefulWidget {
  const UsherMembersPage({super.key});

  @override
  State<UsherMembersPage> createState() => _UsherMembersPageState();
}

class _UsherMembersPageState extends State<UsherMembersPage> {
  final _memberService = MemberService();
  final _searchController = TextEditingController();

  late Future<List<MemberProfile>> _membersFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _membersFuture = _memberService.fetchAll();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _membersFuture = _memberService.fetchAll();
    });
    await _membersFuture;
  }

  List<MemberProfile> _filter(List<MemberProfile> members) {
    if (_query.isEmpty) return members;
    return members.where((m) {
      return m.firstName.toLowerCase().contains(_query) ||
          m.lastName.toLowerCase().contains(_query) ||
          m.id.toLowerCase().contains(_query);
    }).toList();
  }

  void _handleAddMember() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddMemberPage()),
    );
    if (added == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Manage Members', style: AppTextStyles.bodyh1),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by first name, last name, or ID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<MemberProfile>>(
                  future: _membersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final allMembers = snapshot.data ?? [];
                    final members = _filter(allMembers);

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: members.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: Text(
                                    allMembers.isEmpty
                                        ? 'No members registered yet.'
                                        : 'No members match your search.',
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                              itemCount: members.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final member = members[index];
                                return _MemberTile(member: member, onDeleted: _refresh);
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddMember,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Member', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberProfile member;
  final VoidCallback onDeleted;
  const _MemberTile({required this.member, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final wasDeleted = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => UsherMemberDetailPage(profile: member)),
        );
        if (wasDeleted == true) onDeleted();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundImage:
                  member.photoUrl.isNotEmpty ? NetworkImage(member.photoUrl) : null,
              child: member.photoUrl.isEmpty
                  ? Text(member.fullName.isNotEmpty ? member.fullName[0] : '?')
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.fullName, style: AppTextStyles.bodyh2),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${member.id}${member.ministry != null ? ' · ${member.ministry}' : ''}',
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}