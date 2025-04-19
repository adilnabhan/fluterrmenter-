import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class GymProfileCompletionStatusCard extends StatefulWidget {
  const GymProfileCompletionStatusCard({required this.progress, super.key});

  final int progress;

  @override
  State<GymProfileCompletionStatusCard> createState() =>
      _GymProfileCompletionStatusCardState();
}

class _GymProfileCompletionStatusCardState
    extends State<GymProfileCompletionStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Animation duration
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.progress.toDouble(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        image: DecorationImage(
          image: svg.Svg(
            'assets/images/svg/vectors/gym_profile_progress_card_background.svg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Your Profile',
            style: AppStyles.text16Px.poppins700.light,
            textAlign: TextAlign.center,
          ),
          Text(
            "You're almost there  complete a few more steps.",
            style: AppStyles.text12Px.poppins400.light,
            textAlign: TextAlign.center,
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SfSliderTheme(
                data: const SfSliderThemeData(
                  thumbColor: Colors.transparent,
                  activeTrackColor: AppColors.primary,
                  thumbRadius: 12,
                  activeTrackHeight: 5,
                  inactiveTrackHeight: 5,
                ),
                child: SfSlider(
                  min: 0,
                  max: 5,
                  interval: 1,
                  value: _animation.value,
                  thumbIcon: Image.asset(
                    'assets/images/png/icons/slider_thump.png',
                  ),
                  onChanged: (dynamic newValue) {},
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
