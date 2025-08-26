#!/bin/bash

# Diretório base
TEST_DIR="/Users/victormarinho/Documents/easier_drop/test"
cd "$TEST_DIR"

# Cores para saída
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Desfazendo a consolidação de testes e restaurando a estrutura original...${NC}"

# Função para procurar e restaurar arquivos .bak
restaurar_backups() {
  # Procurar por arquivos .bak.old
  local bak_old_files=$(find . -name "*.bak.old" 2>/dev/null)
  if [ ! -z "$bak_old_files" ]; then
    echo -e "${BLUE}Restaurando arquivos .bak.old...${NC}"
    for file in $bak_old_files; do
      local original_file="${file%.bak.old}"
      echo "  - Restaurando $original_file"
      mv "$file" "$original_file"
    done
  fi
  
  # Procurar por arquivos .bak
  local bak_files=$(find . -name "*.bak" 2>/dev/null)
  if [ ! -z "$bak_files" ]; then
    echo -e "${BLUE}Restaurando arquivos .bak...${NC}"
    for file in $bak_files; do
      local original_file="${file%.bak}"
      echo "  - Restaurando $original_file"
      mv "$file" "$original_file"
    done
  fi
}

# Remover arquivos consolidados
remover_consolidados() {
  # Lista de arquivos consolidados que devem ser removidos
  local arquivos_consolidados=(
    "components/hover_icon_button_test.dart"
    "components/mac_close_button_test.dart"
    "components/parts/file_actions_bar_test.dart"
    "components/parts/files_surface_test.dart"
    "controllers/drag_coordinator_test.dart"
    "model/file_reference_test.dart"
    "providers/files_provider_test.dart"
    "services/drag_result_test.dart"
    "services/services_test.dart"
    "services/settings_service_test.dart"
  )
  
  echo -e "${BLUE}Removendo arquivos consolidados...${NC}"
  for arquivo in "${arquivos_consolidados[@]}"; do
    if [ -f "$arquivo" ]; then
      echo "  - Removendo $arquivo"
      rm "$arquivo"
    fi
  done
}

# Restaurar backups
restaurar_backups

# Remover arquivos consolidados
remover_consolidados

echo -e "${GREEN}Processo de reversão concluído!${NC}"
echo -e "${YELLOW}Executando testes para verificar se a restauração foi bem-sucedida...${NC}"

# Verificar se os testes funcionam
flutter test

# Verificar a cobertura
echo -e "${YELLOW}Verificando a cobertura de testes...${NC}"
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

echo -e "${GREEN}Processo completo. Verifique se a cobertura de testes foi restaurada.${NC}"
