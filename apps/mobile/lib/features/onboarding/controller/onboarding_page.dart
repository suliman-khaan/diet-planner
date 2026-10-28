import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/state_widgets.dart';
import '../ui/onboarding_screen.dart';
import '../view_model/onboarding_view_model.dart';
import 'onboarding_controller.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key, this.editing = false});

  final bool editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = onboardingControllerProvider(editing);
    final async = ref.watch(provider);
    final c = ref.read(provider.notifier);

    ref.listen(provider, (_, next) {
      final error = next.valueOrNull?.errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
      }
    });

    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        body: ErrorStateWidget(
          message: 'Your details could not be loaded.',
          onRetry: () => ref.invalidate(provider),
        ),
      ),
      data: (OnboardingViewModel vm) => PopScope(
        canPop: editing && vm.currentStep == OnboardingStep.goal,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) c.back();
        },
        child: OnboardingScreen(
          vm: vm,
          onGoalChanged: c.setGoal,
          onSexChanged: c.setSex,
          onHeightChanged: c.setHeight,
          onWeightChanged: c.setWeight,
          onActivityChanged: c.setActivity,
          onBirthYearChanged: c.setBirthYear,
          onConditionToggled: c.toggleCondition,
          onDietTypeChanged: c.setDiet,
          onAllergyToggled: c.toggleAllergy,
          onRichnessChanged: c.setRichness,
          onNext: c.next,
          onBack: () {
            if (!c.back() && editing) context.pop();
          },
          onOpenCalculation: () => context.push(AppRoutes.transparency),
          onFinish: () async {
            await c.finish();
            if (context.mounted) context.go(AppRoutes.today);
          },
        ),
      ),
    );
  }
}
