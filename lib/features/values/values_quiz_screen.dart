import 'package:flutter/material.dart';
import 'package:vetted_club_mobile/core/services/values_service.dart';
import 'package:vetted_club_mobile/features/values/data/values_quiz_models.dart';
import 'package:vetted_club_mobile/features/values/data/values_quiz_steps.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_layout.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_step_dealbreakers.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_step_family.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_step_geography.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_step_life_stage.dart';
import 'package:vetted_club_mobile/features/values/widgets/values_quiz_step_lifestyle.dart';

class ValuesQuizScreen extends StatefulWidget {
  const ValuesQuizScreen({
    super.key,
    required this.onComplete,
    this.embedded = false,
  });

  final ValueChanged<String> onComplete;
  final bool embedded;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onComplete,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ValuesQuizScreen(onComplete: onComplete),
      ),
    );
  }

  @override
  State<ValuesQuizScreen> createState() => _ValuesQuizScreenState();
}

class _ValuesQuizScreenState extends State<ValuesQuizScreen> {
  int _step = 0;
  bool _submitting = false;
  ValuesQuizAnswers _answers = ValuesQuizAnswers();

  void _finish(String status) {
    widget.onComplete(status);
    if (!widget.embedded && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _skip() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ValuesService.instance.skipQuiz();
      if (mounted) _finish('skipped');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not skip quiz: $e')),
        );
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ValuesService.instance.submitQuiz(_answers.toPayload());
      if (mounted) _finish('completed');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save quiz: $e')),
        );
        setState(() => _submitting = false);
      }
    }
  }

  void _advance() {
    if (_step < valuesQuizStepCount - 1) {
      setState(() => _step += 1);
      return;
    }
    _submit();
  }

  void _autoAdvance() {
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted || _step != 0) return;
      _advance();
    });
  }

  bool get _autoAdvanceStep => valuesQuizStepMeta[_step].autoAdvance;
  bool get _isLast => _step == valuesQuizStepCount - 1;

  @override
  Widget build(BuildContext context) {
    return ValuesQuizLayout(
      embedded: widget.embedded,
      stepIndex: _step,
      showCta: !_autoAdvanceStep,
      ctaLabel: _isLast ? 'Unlock Daily 5 →' : 'Continue',
      ctaEnabled: !_submitting,
      ctaLoading: _submitting,
      onCta: _advance,
      onBack: _step > 0 ? () => setState(() => _step -= 1) : null,
      onSkip: _skip,
      body: switch (_step) {
        0 => ValuesQuizStepLifeStage(
            answers: _answers,
            onChanged: (v) => setState(() => _answers = v),
            onSelected: _autoAdvance,
          ),
        1 => ValuesQuizStepLifestyle(
            answers: _answers,
            onChanged: (v) => setState(() => _answers = v),
          ),
        2 => ValuesQuizStepFamily(
            answers: _answers,
            onChanged: (v) => setState(() => _answers = v),
          ),
        3 => ValuesQuizStepDealbreakers(
            answers: _answers,
            onChanged: (v) => setState(() => _answers = v),
          ),
        _ => ValuesQuizStepGeography(
            answers: _answers,
            onChanged: (v) => setState(() => _answers = v),
          ),
      },
    );
  }
}
