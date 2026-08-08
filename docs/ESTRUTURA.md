# Estrutura do Projeto

Abaixo está a organização das pastas e arquivos do Easier Drop, seguindo as melhores práticas do Flutter para modularidade e organização por responsabilidade.

## Diretórios Principais

```markdown
easier_drop/
├── assets/             # Recursos estáticos (ícones, imagens promocionais)
├── doc/                # Documentação técnica e guias
├── lib/                # Código fonte da aplicação
│   ├── components/     # Widgets reutilizáveis (UI)
│   ├── config/         # Configurações globais e constantes
│   ├── controllers/    # Lógica de controle de fluxo
│   ├── helpers/        # Utilitários e extensões
│   ├── l10n/           # Arquivos de tradução (i18n)
│   ├── model/          # Modelos de dados
│   ├── providers/      # Gerenciamento de estado (Provider)
│   ├── screens/        # Telas principais da aplicação
│   ├── services/       # Integrações com serviços e sistema (API, BD, SO)
│   ├── theme/          # Definições de cores e estilo
│   └── web/            # Componentes específicos para a versão Web
├── macos/              # Configurações nativas do macOS
├── test/               # Testes unitários e de widget
└── web/                # Configurações nativas para Web
```

## Responsabilidade das Camadas

- **`lib/services/`**: Camada que lida com o mundo externo. Exemplos: `AnalyticsService` (Aptabase), `WindowManagerService` (interação com o SO para janelas).
- **`lib/providers/`**: Mantém o estado global. O `FilesProvider` é o coração da aplicação, gerenciando o lote de arquivos atual.
- **`lib/screens/`**: Define as páginas completas que o usuário visualiza.
- **`lib/components/`**: Widgets menores que compõem as telas, garantindo o princípio DRY (Don't Repeat Yourself).
- **`lib/helpers/`**: Classes utilitárias puras, sem dependência direta de UI.
