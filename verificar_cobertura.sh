#!/bin/bash

# Diretório base
cd "/Users/victormarinho/Documents/easier_drop"

# Cores para saída
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Arquivos problemáticos identificados na saída anterior
arquivos_problematicos=(
  "lib/components/drag_drop.dart" 
  "lib/components/window_handle.dart"
  "lib/main.dart"
  "lib/screens/file_transfer_screen.dart"
  "lib/components/parts/marquee_text.dart"
  "lib/services/settings_service.dart"
  "lib/l10n/app_localizations.dart"
  "lib/components/parts/file_actions_bar.dart"
  "lib/components/mac_close_button.dart"
)

echo -e "${YELLOW}Arquivos com baixa cobertura de testes:${NC}"

# Verificar cada arquivo
for arquivo in "${arquivos_problematicos[@]}"; do
  # Extrair o número de linhas cobertas e totais do relatório de cobertura
  cobertura=$(grep -A 1 "$arquivo" coverage/lcov.info | grep -o "LH:[0-9]*" | cut -d":" -f2)
  total=$(grep -A 1 "$arquivo" coverage/lcov.info | grep -o "LF:[0-9]*" | cut -d":" -f2)
  
  # Calcular porcentagem se ambos os valores forem encontrados
  if [[ -n "$cobertura" && -n "$total" && "$total" -gt 0 ]]; then
    porcentagem=$(( (cobertura * 100) / total ))
    
    # Colorir com base na porcentagem
    if [[ $porcentagem -lt 50 ]]; then
      cor=$RED
    elif [[ $porcentagem -lt 80 ]]; then
      cor=$YELLOW
    else
      cor=$GREEN
    fi
    
    # Exibir resultado
    echo -e "  - ${cor}$arquivo${NC}: $porcentagem% coberto ($cobertura/$total linhas)"
    
    # Analisar arquivos com menos de 80% de cobertura
    if [[ $porcentagem -lt 80 ]]; then
      # Verificar se existe teste para esse arquivo
      base_nome=$(basename "$arquivo" .dart)
      test_files=$(find test -name "*${base_nome}*_test.dart" | wc -l)
      
      if [[ $test_files -eq 0 ]]; then
        echo -e "    ${RED}⚠️ Não há testes específicos para este arquivo${NC}"
      else
        echo -e "    ${YELLOW}ℹ️ Encontrados $test_files arquivos de teste, mas cobertura ainda é baixa${NC}"
      fi
    fi
  else
    echo -e "  - ${RED}$arquivo${NC}: Não foi possível determinar a cobertura"
  fi
done
