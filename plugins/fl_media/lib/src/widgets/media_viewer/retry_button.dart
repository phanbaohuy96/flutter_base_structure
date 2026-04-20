import 'package:flutter/material.dart';

import '../../../fl_media.dart';

class MediaRetryButton extends StatelessWidget {
  const MediaRetryButton({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRetry,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.replay,
              color: Color(0xff2D264B),
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.flMediaL10n.tapToReload,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
