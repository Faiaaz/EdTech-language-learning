import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/models/avatar_config.dart';
import 'package:ez_trainz/models/hat_tier.dart';
import 'package:ez_trainz/screens/journey_screen.dart';
import 'package:ez_trainz/services/photo_feature_matcher.dart';
import 'package:ez_trainz/widgets/layered_avatar.dart';

/// Mirror Mode: the user picks a photo, we analyze it with a small
/// on-device heuristic (`PhotoFeatureMatcher`), and snap to the closest
/// preset. We don't upload the photo anywhere — it stays local.
class AvatarMirrorModeScreen extends StatefulWidget {
  const AvatarMirrorModeScreen({super.key});

  @override
  State<AvatarMirrorModeScreen> createState() => _AvatarMirrorModeScreenState();
}

class _AvatarMirrorModeScreenState extends State<AvatarMirrorModeScreen> {
  final _picker = ImagePicker();

  Uint8List? _photoBytes;
  bool _analyzing = false;
  String? _error;
  AvatarConfig? _result;

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      final x = await _picker.pickImage(source: source, maxWidth: 1024);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _analyzing = true;
        _result = null;
      });
      final matched = await PhotoFeatureMatcher.match(bytes);
      if (!mounted) return;
      setState(() {
        _result = matched;
        _analyzing = false;
        if (matched == null) {
          _error = "We couldn't read that image. Try another?";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _analyzing = false;
        _error = 'Could not open photo: $e';
      });
    }
  }

  Future<void> _confirm() async {
    final r = _result;
    if (r == null) return;
    await JourneyController.to.setAvatar(r);
    if (!mounted) return;
    Get.offAll(() => const JourneyScreen(showOnboardCelebration: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    'Mirror Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a photo. Your avatar is matched on-device —\nwe don\'t upload it anywhere.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 13,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _PreviewPanel(
                  photoBytes: _photoBytes,
                  analyzing: _analyzing,
                  result: _result,
                  error: _error,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white),
                      label: const Text('Camera',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded,
                          color: Colors.white),
                      label: const Text('Gallery',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _result != null && !_analyzing ? _confirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE000),
                    foregroundColor: Colors.black87,
                    disabledBackgroundColor:
                        const Color(0xFFFFE000).withValues(alpha: 0.25),
                    disabledForegroundColor:
                        Colors.black.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Use this avatar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.photoBytes,
    required this.analyzing,
    required this.result,
    required this.error,
  });

  final Uint8List? photoBytes;
  final bool analyzing;
  final AvatarConfig? result;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Row: photo → avatar
          Expanded(
            child: Row(
              children: [
                Expanded(child: _photoTile()),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white54),
                const SizedBox(width: 12),
                Expanded(child: _avatarTile()),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _photoTile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: Colors.white.withValues(alpha: 0.05),
        alignment: Alignment.center,
        child: photoBytes == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_rounded,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(
                    'No photo yet',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12),
                  ),
                ],
              )
            : Image.memory(photoBytes!, fit: BoxFit.cover,
                width: double.infinity, height: double.infinity),
      ),
    );
  }

  Widget _avatarTile() {
    if (analyzing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFFE000)),
          const SizedBox(height: 10),
          Text(
            'Matching features…',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
          ),
        ],
      );
    }
    if (result == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome,
              size: 40, color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Text('Your avatar will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              )),
        ],
      );
    }
    return FittedBox(
      fit: BoxFit.contain,
      child: LayeredAvatar(
        config: result!,
        tier: HatTier.none,
        size: 160,
        showHatGear: false,
      ),
    );
  }
}
