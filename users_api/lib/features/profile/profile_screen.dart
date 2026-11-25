import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _prefs = SharedPreferencesAsync();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final path = await _prefs.getString('avatarPath');
    if (!mounted) return;
    if (path != null && File(path).existsSync()) {
      setState(() => _photoPath = path);
    }
  }

  /// Копируем снимок в Documents (кэш камеры временный) и помним путь.
  Future<void> _savePhoto(XFile picked) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/avatar.jpg';
    await File(picked.path).copy(dest);
    await FileImage(File(dest)).evict(); // иначе покажется старая картинка
    await _prefs.setString('avatarPath', dest);
    if (!mounted) return;
    setState(() => _photoPath = dest);
  }

  Future<void> _chooseFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return; // Cancel -> null
    await _savePhoto(picked);
  }

  Future<void> _takePhoto() async {
    // запрос именно в момент нажатия, не в initState
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        final picked = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 85,
        );
        if (picked == null || !mounted) return;
        await _savePhoto(picked);
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The camera is needed to take a photo. '
              'You can still choose one from the gallery.',
            ),
          ),
        );
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        await _showSettingsDialog();
    }
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera access is turned off'),
        content: const Text(
          'To take a photo, allow the camera for this app in the system '
          'settings. You can still choose a photo from the gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open == true) await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final path = _photoPath;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: path == null ? null : FileImage(File(path)),
              child: path == null
                  ? const Text('U', style: TextStyle(fontSize: 40))
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _chooseFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
          ],
        ),
      ),
    );
  }
}
