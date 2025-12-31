import 'package:easier_drop/components/welcome/animated_welcome_content.dart';
import 'package:easier_drop/helpers/app_constants.dart';
import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppConstants.welcomeAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _navigateToMain();
  }

  void _navigateToMain() {
    Future.delayed(AppConstants.welcomeNavigationDelay, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, _, __) =>
                    const MacosWindow(child: FileTransferScreen()),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: AppConstants.slowAnimation,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      child: Center(
        child: AnimatedWelcomeContent(
          fadeAnimation: _fadeAnimation,
          scaleAnimation: _scaleAnimation,
        ),
      ),
    );
  }
}
