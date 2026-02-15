<div align="center">

<img src="https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/icon/icon.png" width="128" alt="Easier Drop Icon">

# Easier Drop

**A prateleira de "arrastar e soltar" que faltava no macOS.**

[🇺🇸 English](README.md) | [🇧🇷 Português](README_pt.md) | [🇪🇸 Español](README_es.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)

</div>

## 🚀 Por que Easier Drop?

**Já sentiu a frustração de arrastar um arquivo apenas para perceber que o aplicativo de destino está escondido atrás de três outras janelas?** 

O Easier Drop é o seu companheiro nativo de produtividade para macOS que acaba com a loucura de alternar janelas. Ele fornece uma **estante temporária**—uma zona flutuante onde você pode "guardar" qualquer coisa (arquivos, imagens, texto) de qualquer aplicativo. Reúna sua pilha, navegue livremente e solte tudo de uma vez quando estiver pronto.

> **É como uma estante física para o seu fluxo de trabalho digital. Gratuito, de código aberto e nativamente rápido.**

---

## ✨ Funcionalidades Incríveis (v1.1.2)

### 📦 Colete de Qualquer Lugar, Instanteamente
Arraste do Finder, Safari, Fotos ou até mesmo do seu editor de código. Seus arquivos ficam guardados até que você esteja pronto para movê-los.
> ![Coletando Arquivos](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/useged-2.png)
> *Guarde arquivos de várias fontes em uma única pilha organizada.*

### 🛠️ Magia Multi-Janela
Precisa manter pilhas separadas para projetos diferentes? Abra várias janelas do Easier Drop em qualquer lugar da tela.
> ![Suporte Multi-Janela](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/multi_window.png)
> *Produtividade dobrada: gerencie pilhas diferentes para tarefas diferentes.*

### 🤝 Agite para Selecionar (Native Shake)
Sentindo o "sacolejo"? Basta agitar o mouse enquanto arrasta um arquivo para criar instantaneamente uma nova janela do Easier Drop exatamente no seu cursor.
> ![Gesto de Balançar](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/shake_gesture.gif)
> *A maneira mais natural de criar uma zona de drop rapidamente.*

### 📋 Integração com Área de Transferência
Já copiou algo? Basta usar `Cmd + V` sobre a zona de drop para adicioná-lo à sua estante. Integração perfeita com o Finder e a área de transferência do sistema.
> ![Integração com Área de Transferência](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/clipboard_paste.gif)
> *Cole arquivos diretamente no seu fluxo de trabalho sem precisar arrastar novamente.*

### 💎 Configurações Personalizáveis
Uma janela de preferências completa para ajustar o Easier Drop ao seu fluxo de trabalho. Ajuste a sensibilidade do gesto de balançar, controle a opacidade da janela e gerencie opções como "Sempre no Topo" ou "Iniciar com o Sistema".
> ![Interface de Configurações](https://raw.githubusercontent.com/victorcmarinho/EasierDrop/main/assets/promo/settings_ui.png)
> *Personalize cada detalhe de suas zonas de drop para máxima produtividade.*

### ⚡️ Sempre no Topo & Velocidade Nativa
Desenvolvido com Flutter e ganchos nativos do macOS, o Easier Drop é incrivelmente leve e permanece visível acima do seu trabalho para estar sempre lá quando você precisar.

---

## 🛠 Instalação

### Baixar App
[**Baixar Última Versão**](https://github.com/victorcmarinho/EasierDrop/releases)

### Homebrew
Você também pode instalar via Homebrew:

```bash
brew tap victorcmarinho/easier-drop https://github.com/victorcmarinho/EasierDrop
brew install --cask easier-drop
```

> **Nota:** Se o aplicativo não abrir com erro de "danificado" (comum em instalações via Homebrew de apps não notariados), execute este comando no terminal:
> ```bash
> xattr -d com.apple.quarantine "/Applications/Easier Drop.app"
> ```

---

## ⌨️ Atalhos Pro

- `Cmd + V`: Cola arquivos copiados diretamente na estante.
- `Cmd + Backspace`: Limpa toda a estante.
- `Cmd + C`: Copia todos os itens da estante de volta para a área de transferência.
- `Cmd + Shift + C`: Compartilha itens rapidamente via Menu de Compartilhamento do macOS.
- `Cmd + ,`: Abre as Preferências.

---

## 🤝 Contribuição

Adoramos contribuidores! 
1. **Fork** o projeto.
2. **Crie** sua feature branch.
3. **Envie** um Pull Request.

## 📄 Licença

Distribuído sob a Licença MIT. Veja `LICENSE` para mais informações.

---

## 🛠️ Informações Técnicas

### Como Funciona
O Easier Drop é construído como uma aplicação desktop para macOS que utiliza Flutter para a interface e APIs nativas do macOS para integração com o sistema.
- **Lógica de Drag & Drop**: Utiliza platform channels e o pacote `desktop_multi_window` para gerenciar múltiplas instâncias de janelas.
- **Gerenciamento de Estado**: Utiliza o padrão `Provider` para sincronizar os arquivos entre várias janelas em tempo real.
- **Integração Nativa**: Implementa um `MacOSShakeMonitor` personalizado usando ganchos em Swift para detectar o gesto de "balançar" durante o arraste.
- **Persistência**: As referências dos arquivos são gerenciadas em memória para maior velocidade, com validação de caminhos para garantir a integridade dos dados.

### Tecnologias Utilizadas
- **Framework**: [Flutter](https://flutter.dev) (macOS Desktop)
- **Linguagem**: Dart & Swift (para hooks nativos)
- **Gerenciamento de Estado**: Provider
- **Telemetria**: Aptabase
- **Interface**: `macos_ui` para um design nativo

### Como Rodar o Projeto
Para executar o projeto localmente:
1. Certifique-se de ter o [Flutter SDK](https://docs.flutter.dev/get-started/install/macos) instalado.
2. Clone o repositório.
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Crie um arquivo `.env` baseado no `.env.example`:
   ```bash
   cp .env.example .env
   ```
5. Execute a aplicação:
   ```bash
   flutter run -d macos
   ```

### Executando Testes
Mantemos a qualidade do código com uma suíte abrangente de testes unitários.
Para executar os testes:
```bash
flutter test
```
Para verificar a cobertura:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Variáveis de Ambiente (Envs)
O projeto utiliza arquivos `.env` para configuração:
- `APTABASE_APP_KEY`: Sua chave de telemetria do Aptabase.
- `GITHUB_LATEST_RELEASE_URL`: Endpoint da API para verificação de atualizações.

## ❤️ Apoie o Projeto

Se o Easier Drop facilita sua vida, considere apoiar o desenvolvedor!

<div align="center">
  <a href="https://github.com/sponsors/victorcmarinho">
    <img src="https://img.shields.io/badge/Sponsor-❤️-pink?style=for-the-badge" alt="Sponsor">
  </a>
</div>
