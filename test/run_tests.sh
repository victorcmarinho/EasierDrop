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
  echo "  -h, --help      Mostra esta ajuda"
  echo ""
  echo "Exemplos:"
  echo "  $0 -a                   # Executa todos os testes"
  echo "  $0 -c                   # Executa testes com cobertura"
  echo "  $0 -f marquee_text_test # Executa o teste do MarqueeText"
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
    echo -e "${RED}Arquivo de teste não encontrado: $test_file${NC}"
    echo "Arquivos de teste disponíveis:"
    ls test/*.dart | sed 's/test\//  /' | sed 's/\.dart$//'
    return 1
  fi
  
  echo -e "${YELLOW}Executando teste: $full_path${NC}"
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
