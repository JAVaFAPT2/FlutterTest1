import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shoppe/features/demo/riverpod_counter_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_shoppe/features/auth/bloc/auth_bloc.dart';
import 'package:e_shoppe/data/repositories/auth_repository.dart';
import 'package:e_shoppe/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_shoppe/theme/theme_provider.dart';
import 'package:e_shoppe/features/demo/riverpod_cart_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String? _avatarUrl;
  Uint8List? _avatarBytes;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;

  String? get _currentUserId => context.read<AuthBloc>().state.user?.id;

  Future<void> _pickAndUpload() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    // For free plan without Storage: save as Base64 directly
    try {
      final bytes = await picked.readAsBytes();
      final b64 = base64Encode(bytes);
      final uid = _currentUserId;
      if (uid != null && uid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(uid)
            .set({'avatarBase64': b64}, SetOptions(merge: true));
      }
      if (mounted) {
        setState(() {
          _avatarBytes = bytes;
          _avatarUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _addressCtrl = TextEditingController(text: user?.address ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');

    _loadAvatar();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    final uid = _currentUserId;
    if (uid == null || uid.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(uid)
          .get();
      final data = doc.data();
      final url = data?['avatar'] as String?;
      final b64 = data?['avatarBase64'] as String?;
      if (url != null) {
        setState(() {
          _avatarUrl = url;
          _avatarBytes = null;
        });
      } else if (b64 != null) {
        try {
          final bytes = base64Decode(b64);
          setState(() {
            _avatarBytes = bytes;
            _avatarUrl = null;
          });
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    final repo = context.read<AuthRepository>();
    final updated = await repo.updateProfile(
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim());
    if (updated != null && mounted) {
      context.read<AuthBloc>().add(LoggedIn(updated));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _avatarBytes != null
                    ? MemoryImage(_avatarBytes!)
                    : _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : null,
                child: _avatarUrl == null && _avatarBytes == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickAndUpload,
                icon: const Icon(Icons.image),
                label: const Text('Change Avatar'),
              ),
              const SizedBox(height: 12),
              if (kDebugMode) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const RiverpodCounterPage()));
                  },
                  child: const Text('Open Riverpod Counter Demo'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const RiverpodCartPage()));
                  },
                  child: const Text('Open Riverpod Cart Demo'),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Profile')),
                    const SizedBox(height: 20),
                    FutureBuilder<bool>(
                      future: NotificationService.instance.isPromoSubscribed(),
                      builder: (context, snapshot) {
                        final subscribed = snapshot.data ?? false;
                        return SwitchListTile(
                          title: const Text('Receive Promotions'),
                          value: subscribed,
                          onChanged: (val) async {
                            await NotificationService.instance
                                .setPromoSubscription(val);
                            setState(() {});
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Consumer(builder: (context, ref, _) {
                      final isDark =
                          ref.watch(themeModeProvider) == ThemeMode.dark;
                      return SwitchListTile(
                        title: const Text('Dark Mode'),
                        value: isDark,
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggle(),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
