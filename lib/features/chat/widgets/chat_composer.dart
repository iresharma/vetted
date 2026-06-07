import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:vetted_club_mobile/core/theme/theme.dart';
import 'package:vetted_club_mobile/core/widgets/widgets.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.sending = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: VcTextInput(
                  controller: controller,
                  placeholder: 'Message...',
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (!sending) onSend();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Material(
                color: AppColors.violet,
                borderRadius: AppRadius.r12,
                child: InkWell(
                  onTap: sending ? null : onSend,
                  borderRadius: AppRadius.r12,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: sending
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onViolet,
                              ),
                            ),
                          )
                        : const Icon(
                            PhosphorIconsRegular.paperPlaneTilt,
                            color: AppColors.onViolet,
                            size: 20,
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
