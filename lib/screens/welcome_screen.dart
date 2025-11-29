import 'package:easier_drop/screens/file_transfer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar o controller de animação
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animação de fade-in (opacidade)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Animação de scale (escala)
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Iniciar a animação
    _controller.forward();

    // Navegar para a tela principal após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const MacosWindow(child: FileTransferScreen()),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
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
    return MacosScaffold(
      backgroundColor: MacosTheme.of(context).canvasColor,
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone ou logo (opcional)
                    Icon(
                      CupertinoIcons.cloud_download,
                      size: 80,
                      color: MacosTheme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),
                    // Texto de boas-vindas
                    Text(
                      'Olá, bem-vindo ao',
                      style: MacosTheme.of(context).typography.title2.copyWith(
                        color: MacosTheme.of(context).typography.title2.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Easier Drop',
                      style: MacosTheme.of(
                        context,
                      ).typography.largeTitle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: MacosTheme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
