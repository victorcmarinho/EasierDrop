import 'package:flutter/widgets.dart';

/// Constantes globais da aplicação
class AppConstants {
  const AppConstants._();

  // Configurações de UI
  static const double windowHandleHeight = 28.0;
  static const double actionButtonSize = 40.0;
  static const double borderRadius = 8.0;
  static const double borderWidth = 4.0;

  // Durações de animação
  static const Duration fastAnimation = Duration(milliseconds: 160);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Configurações de arquivo
  static const int defaultMaxFiles = 100;
  static const Duration fileValidationTimeout = Duration(seconds: 5);

  // Configurações de notificação
  static const Duration limitNotificationDuration = Duration(seconds: 2);
  static const Duration debounceDelay = Duration(milliseconds: 250);
}

/// Chaves semânticas para testes e acessibilidade
class SemanticKeys {
  const SemanticKeys._();

  static const Key shareButton = ValueKey('shareSem');
  static const Key removeButton = ValueKey('removeSem');
  static const Key dropArea = ValueKey('dropAreaSem');
}

/// Valores de transparência comuns
class AppOpacity {
  const AppOpacity._();

  static const double subtle = 0.03;
  static const double border = 0.7;
  static const double disabled = 0.5;
  static const double overlay = 0.8;
}
