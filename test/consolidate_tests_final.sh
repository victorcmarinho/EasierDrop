#!/bin/bash

# Diretório base
TEST_DIR="/Users/victormarinho/Documents/easier_drop/test"
cd "$TEST_DIR"

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para limpar arquivos temporários
clean_temp_files() {
  find . -name "*.bak" | xargs rm -f
  find . -name "*.bak.old" | xargs rm -f
}

# Limpar qualquer arquivo temporário
clean_temp_files

# Restaurar os arquivos originais
find . -name "*.dart.bak.old" | while read file; do
  original_file="${file%.bak.old}"
  mv "$file" "$original_file"
done

# Função para consolidar testes
consolidate_tests() {
  local pattern="$1"
  local destination="$2"
  local description="$3"
  
  echo -e "${YELLOW}Consolidando testes: ${BLUE}$description${NC}"
  
  # Criar diretório pai se não existir
  mkdir -p "$(dirname "$destination")"
  
  # Criar cabeçalho do arquivo
  cat > "$destination" <<EOL
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:easier_drop/main.dart';

/// Testes consolidados para $description
///
/// Este arquivo combina testes anteriormente separados em vários arquivos.
/// Consolidado em 26/08/2024.
void main() {
EOL
  
  # Encontrar todos os arquivos que correspondem ao padrão, excluindo o arquivo de destino e backups
  local files=$(find . -type f -name "$pattern" | grep -v "\.bak" | grep -v "\.old")
  
  # Para cada arquivo
  for file in $files; do
    if [[ "$file" == "./$destination" ]]; then
      continue  # Pular o arquivo de destino
    fi
    
    echo "  - Processando $file"
    
    # Extrair imports adicionais
    local imports=$(grep "^import" "$file" | grep -v "flutter_test" | grep -v "flutter/widgets" | grep -v "flutter/material" | grep -v "easier_drop/main")
    
    # Adicionar imports ao arquivo de destino se ainda não existirem
    if [ ! -z "$imports" ]; then
      for import in $imports; do
        if ! grep -q "$import" "$destination"; then
          sed -i '' "/^import/a\\
$import" "$destination"
        fi
      done
    fi
    
    # Extrair o conteúdo entre 'void main() {' e o último '}'
    local content=$(sed -n '/void main() {/,/^}/p' "$file" | sed '1d;$d')
    
    # Extrair o nome do arquivo sem extensão e diretório
    local filename=$(basename "$file" .dart)
    
    # Adicionar como um bloco de código com comentário
    echo -e "\n  // ===== Testes de $filename =====" >> "$destination"
    echo "$content" >> "$destination"
    
    # Renomear o arquivo original para .bak
    mv "$file" "${file}.bak"
  done
  
  # Adicionar fechamento da função main
  echo "}" >> "$destination"
  
  echo -e "${GREEN}Testes consolidados em: $destination${NC}"
}

# 1. HoverIconButton
consolidate_tests "hover_icon_button*test.dart" "components/hover_icon_button_test.dart" "HoverIconButton"

# 2. MacCloseButton
consolidate_tests "mac_close_button*test.dart" "components/mac_close_button_test.dart" "MacCloseButton"

# 3. FileActionsBar
consolidate_tests "file_actions_bar*test.dart" "components/parts/file_actions_bar_test.dart" "FileActionsBar"

# 4. FilesSurface
consolidate_tests "files_surface*test.dart" "components/parts/files_surface_test.dart" "FilesSurface"

# 5. DragCoordinator
consolidate_tests "drag_coordinator*test.dart" "controllers/drag_coordinator_test.dart" "DragCoordinator"

# 6. FileReference
consolidate_tests "file_reference*test.dart" "model/file_reference_test.dart" "FileReference"

# 7. FilesProvider
consolidate_tests "files_provider*test.dart" "providers/files_provider_test.dart" "FilesProvider"

# 8. DragResult
consolidate_tests "drag_result*test.dart" "services/drag_result_test.dart" "DragResult"

# 9. Services (menos DragResult)
consolidate_tests "services_*test.dart" "services/services_test.dart" "Services"

# 10. Settings
consolidate_tests "settings_*test.dart" "services/settings_service_test.dart" "SettingsService"

# Verificar se há testes duplicados
echo -e "${YELLOW}Verificando por testes duplicados nos arquivos consolidados...${NC}"
find . -name "*_test.dart" | grep -v "\.bak" | while read file; do
  # Verificar se há duplicação de nomes de testes
  duplicates=$(grep -E "^\s+test\(" "$file" | sort | uniq -d)
  if [ ! -z "$duplicates" ]; then
    echo -e "${YELLOW}Encontrados testes com nomes duplicados em $file:${NC}"
    echo "$duplicates"
  fi
done

echo -e "${GREEN}Consolidação completa!${NC}"
echo -e "${YELLOW}Os arquivos originais foram renomeados para .bak para referência.${NC}"
echo "Por favor, execute 'flutter test' para verificar se todos os testes ainda estão funcionando."
