# Plano de Ação para Atingir 100% de Cobertura de Testes

## 1. Situação Atual

- Cobertura atual: 84,6% (509 de 602 linhas)
- Principais arquivos com baixa cobertura:
  - `file_transfer_screen.dart`: 14,3% (3 de 21 linhas)
  - `main.dart`: 7,0% (3 de 43 linhas)
  - `marquee_text.dart`: 61,8% (34 de 55 linhas)

## 2. Desafios Identificados

### 2.1 Problemas com `file_transfer_screen.dart`:

- Testamos o arquivo usando uma versão mockada do `FileTransferScreen` que substitui os componentes problemáticos (`Tray` e `DragDrop`)
- Conseguimos testar todos os atalhos de teclado e as funções de limpar e compartilhar
- Ainda assim, a cobertura permanece em 14,3%
- O principal problema parece ser o componente `Tray` que causa erros durante os testes com o widget real

### 2.2 Problemas com `main.dart`:

- Baixa cobertura (7,0%)
- Difícil de testar por conter código de inicialização do aplicativo

### 2.3 Problemas com `marquee_text.dart`:

- Cobertura média (61,8%)
- Contém animações que são difíceis de testar

## 3. Estratégia para `file_transfer_screen.dart`

### 3.1 Opções para aumentar cobertura:

1. **Modificar o arquivo original**:

   - Adicionar uma opção para usar componentes mock em testes
   - Exemplo: `const FileTransferScreen({bool testMode = false})`
   - No modo de teste, usar componentes simplificados que não dependem de recursos nativos

2. **Adicionar anotação coverage:ignore-line**:

   - Identificar as linhas que são difíceis de testar e marcá-las com `// coverage:ignore-line`
   - Isso é recomendado apenas para código que realmente não pode ser testado

3. **Refatorar a estrutura do componente**:
   - Extrair a lógica dos atalhos para uma classe separada
   - Fazer com que `FileTransferScreen` use essa classe de forma mais testável

### 3.2 Ações Recomendadas:

1. Examinar o código-fonte e identificar as linhas específicas que não estão sendo cobertas
2. Criar um Mock mais abrangente que implementa mais comportamentos do componente real
3. Refatorar o componente para torná-lo mais testável, se possível

## 4. Estratégia para `main.dart`

### 4.1 Opções para aumentar cobertura:

1. **Extrair configurações para funções testáveis**:

   - Mover configurações para funções que podem ser testadas independentemente

2. **Usar anotação coverage:ignore-file**:
   - Como o `main.dart` é principalmente código de inicialização, pode ser apropriado excluí-lo da cobertura de teste

### 4.2 Ações Recomendadas:

1. Extrair configurações importantes para funções testáveis
2. Considerar adicionar `// coverage:ignore-file` no topo do arquivo

## 5. Estratégia para `marquee_text.dart`

### 5.1 Opções para aumentar cobertura:

1. **Ampliar os testes de widget**:

   - Criar testes que exercitam mais estados do componente
   - Testar cenários como texto curto, texto longo, diferentes velocidades de marquee

2. **Refatorar a animação**:
   - Extrair a lógica de animação para uma classe separada mais testável

### 5.2 Ações Recomendadas:

1. Criar mais testes de widget para diferentes configurações
2. Focar em aumentar a cobertura deste componente após resolver os dois anteriores

## 6. Priorização de Tarefas

### 6.1 Etapa 1:

- Adicionar `// coverage:ignore-file` ao arquivo `main.dart`
- Implementar um novo componente de teste mais completo para `file_transfer_screen.dart`

### 6.2 Etapa 2:

- Melhorar os testes para `marquee_text.dart`

### 6.3 Etapa 3:

- Reavaliar a cobertura e identificar outros componentes para melhorar

## 7. Estimativa de Impacto

- Ignorando `main.dart` (43 linhas): Nova cobertura base seria ~91%
- Melhorando `file_transfer_screen.dart` para 80%: Adiciona ~14 linhas cobertas
- Melhorando `marquee_text.dart` para 90%: Adiciona ~16 linhas cobertas

Potencial nova cobertura: ~95% (sem contar main.dart)

## 8. Conclusão

A estratégia mais eficaz parece ser:

1. Excluir `main.dart` da análise de cobertura
2. Criar uma versão mais testável de `FileTransferScreen` que mantém a mesma lógica
3. Expandir os testes para `marquee_text.dart`

Seguindo este plano, podemos aumentar significativamente a cobertura e melhorar a qualidade dos testes.
