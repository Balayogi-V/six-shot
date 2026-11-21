import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../audio_service.dart';

class SoundToggle extends StatelessWidget {
  const SoundToggle({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AudioService.instance.muted,
      builder: (context, muted, _) {
        return Semantics(
          button: true,
          toggled: !muted,
          label: muted ? 'Turn sound on' : 'Mute sound',
          excludeSemantics: true,
          child: GestureDetector(
            onTap: AudioService.instance.toggleMuted,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink,
                    offset: Offset(0, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                size: size * 0.52,
                color: AppColors.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}
