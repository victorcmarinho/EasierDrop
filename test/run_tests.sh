#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Função para mostrar ajuda
show_help() {
  echo "Uso: $0 [opções]"
  echo ""
  echo "Opções:"
  echo "  -a, --all       Executa todos os testes"
  echo "  -c, --coverage  Executa testes com cobertura"
  echo "  -f, --file      Executa um arquivo de teste específico"
  echo "  -d, --dir       Executa todos os testes em um diretório específico"
  echo "  -l, --list      Lista todos os testes disponíveis"
  echo "  -h, --help      Mostra esta ajuda"
  echo ""
  echo "Exemplos:"
  echo "  $0 -a                    # Executa todos os testes"
  echo "  $0 -c                    # Executa testes com cobertura"
  echo "  $0 -f hover_icon_button  # Executa o teste do HoverIconButton"
  echo "  $0 -d components         # Executa todos os testes no diretório components"
  echo "  $0 -l                    # Lista todos os testes disponíveis"
  echo ""
}

# Função para executar todos os testes
run_all_tests() {
  echo -e "${YELLOW}Executando todos os testes...${NC}"
  flutter test
}

# Função para executar testes com cobertura
run_coverage() {
  echo -e "${YELLOW}Executando testes com cobertura...${NC}"
  flutter test --coverage
  
  echo -e "${YELLOW}Gerando relatório HTML de cobertura...${NC}"
  genhtml coverage/lcov.info -o coverage/html
  
  echo -e "${GREEN}Relatório de cobertura gerado em coverage/html/index.html${NC}"
}

# Função para executar um arquivo de teste específico
run_specific_test() {
  local test_file="$1"
  local full_path=""
  
  # Verificar se o arquivo existe diretamente
  if [[ -f "test/$test_file.dart" ]]; then
    full_path="test/$test_file.dart"
  elif [[ -f "test/$test_file" ]]; then
    full_path="test/$test_file"
  elif [[ -f "$test_file" ]]; then
    full_path="$test_file"
  else
    # Buscar o arquivo recursivamente no diretório de testes
    found_files=$(find test -name "${test_file}.dart" -o -name "${test_file}" | grep -v "\.old$" | grep -v "\.bak$")
    if [[ -n "$found_files" ]]; then
      # Se encontrar exatamente um arquivo, use-o
      if [[ $(echo "$found_files" | wc -l) -eq 1 ]]; then
        full_path="$found_files"
      else
        echo -e "${YELLOW}Múltiplos arquivos encontrados:${NC}"
        echo "$found_files"
        echo -e "${YELLOW}Por favor, especifique o caminho completo para o teste desejado.${NC}"
        return 1
      fi
    else
      echo -e "${RED}Arquivo de teste não encontrado: $test_file${NC}"
      echo "Tente usar o comando: $0 -l | grep ${test_file}"
      return 1
    fi
  fi
  
  echo -e "${YELLOW}Executando teste: $full_path${NC}"
  flutter test "$full_path"
}

# Função para listar todos os testes disponíveis
list_tests() {
  echo -e "${YELLOW}Testes disponíveis:${NC}"
  echo -e "${GREEN}Organizados por categoria:${NC}"
  
  local categories=(
    "components" 
    "components/parts" 
    "controllers" 
    "helpers/macos" 
    "l10n" 
    "model" 
    "providers" 
    "services" 
    "screens"
    "theme"
    "outros"
  )
  
  for category in "${categories[@]}"; do
    local count=$(find "test/$category" -name "*.dart" 2>/dev/null | wc -l)
    if [[ $count -gt 0 ]]; then
      echo -e "${YELLOW}$category ($count testes):${NC}"
      find "test/$category" -name "*.dart" | sort | sed "s|test/||" | sed "s|.dart$||" | sed 's/^/  /'
    fi
  done
  
  # Testes na raiz
  local root_tests=$(find "test" -maxdepth 1 -name "*.dart" | grep -v "exclusion_marker.dart")
  local root_count=$(echo "$root_tests" | wc -l)
  if [[ $root_count -gt 0 ]]; then
    echo -e "${YELLOW}Testes na raiz ($root_count testes):${NC}"
    echo "$root_tests" | sort | sed "s|test/||" | sed "s|.dart$||" | sed 's/^/  /'
  fi
}

# Função para executar testes em um diretório específico
run_dir_tests() {
  local dir="$1"
  local full_path=""
  
  # Verificar se o diretório existe
  if [[ -d "test/$dir" ]]; then
    full_path="test/$dir"
  elif [[ -d "$dir" ]]; then
    full_path="$dir"
  else
    echo -e "${RED}Diretório de testes não encontrado: $dir${NC}"
    echo "Diretórios de teste disponíveis:"
    find test -type d | grep -v "^test$" | sed 's/test\//  /'
    return 1
  fi
  
  echo -e "${YELLOW}Executando testes no diretório: $full_path${NC}"
  flutter test "$full_path"
}

# Verificar se não foram fornecidos argumentos
if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

# Processar argumentos
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--all)
      run_all_tests
      exit $?
      ;;
    -c|--coverage)
      run_coverage
      exit $?
      ;;
    -f|--file)
      if [[ -z "$2" ]]; then
        echo -e "${RED}É necessário fornecer o nome do arquivo de teste.${NC}"
        exit 1
      fi
      run_specific_test "$2"
      exit $?
      ;;
    -d|--dir)
      if [[ -z "$2" ]]; then
        echo -e "${RED}É necessário fornecer o nome do diretório de testes.${NC}"
        exit 1
      fi
      run_dir_tests "$2"
      exit $?
      ;;
    -l|--list)
      list_tests
      exit 0
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo -e "${RED}Opção desconhecida: $1${NC}"
      show_help
      exit 1
      ;;
  esac
  shift
done
