# Índice de Testes

Este documento fornece um guia para a organização dos testes no projeto EasierDrop.

## Estrutura de Diretórios

Os testes estão organizados seguindo a mesma estrutura do diretório `lib/`, facilitando a localização dos testes para componentes específicos.

```
test/
├── components/          # Testes de componentes de UI
│   ├── parts/           # Testes de partes de componentes
├── controllers/         # Testes de controladores
├── helpers/             # Testes de funções auxiliares
│   ├── macos/           # Testes específicos de helpers para macOS
├── l10n/                # Testes de internacionalização
├── model/               # Testes de modelos de dados
├── providers/           # Testes de provedores
├── services/            # Testes de serviços
├── theme/               # Testes de temas
```

## Executando Testes

Use o script `run_tests.sh` para executar testes:

```bash
# Executar todos os testes
./test/run_tests.sh -a

# Executar testes com cobertura
./test/run_tests.sh -c

# Executar um teste específico
./test/run_tests.sh -f nome_do_teste

# Executar todos os testes em uma categoria
./test/run_tests.sh -d components

# Listar todos os testes disponíveis
./test/run_tests.sh -l
```

## Categorias de Testes

### Components

Testes para os componentes de UI:

- HoverIconButton
- MacCloseButton
- ShareButton
- RemoveButton
- FilesStack

#### Components/Parts

Testes para partes específicas de componentes:

- FileActionsBar
- FilesSurface
- MarqueeText

### Controllers

Testes para os controladores:

- DragCoordinator

### Helpers

Testes para funções auxiliares:

#### Helpers/macOS

- FileIconHelper

### L10n

Testes de internacionalização:

- I18n
- ArbParity

### Model

Testes de modelos de dados:

- FileReference

### Providers

Testes de provedores:

- FilesProvider

### Services

Testes de serviços:

- DragResult
- SettingsService
- Logger

## Testes Removidos

Alguns testes foram removidos devido a falhas persistentes. Consulte o arquivo `testes_removidos.md` para mais detalhes.
