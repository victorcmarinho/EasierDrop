#!/bin/bash

echo "=== Executando testes individuais para identificar os que estão quebrando ==="
echo ""

# Diretório onde os testes estão
TEST_DIR="/Users/victormarinho/Documents/easier_drop/test"

# Arrays para armazenar os resultados
passing_tests=()
failing_tests=()

# Cores para saída
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Processar cada arquivo de teste
for test_file in "$TEST_DIR"/*.dart; do
  # Ignorar arquivos que não são testes
  if [[ "$test_file" == *"exclusion_marker.dart" ]]; then
    continue
  fi
  
  test_name=$(basename "$test_file")
  echo -n "Executando $test_name... "
  
  # Executar o teste e capturar o resultado
  if flutter test "$test_file" > /dev/null 2>&1; then
    echo -e "${GREEN}PASSOU${NC}"
    passing_tests+=("$test_name")
  else
    echo -e "${RED}FALHOU${NC}"
    failing_tests+=("$test_name")
  fi
done

echo ""
echo "=== Relatório de Testes ==="
echo -e "${GREEN}Testes que passaram (${#passing_tests[@]})${NC}:"
for test in "${passing_tests[@]}"; do
  echo "- $test"
done

echo ""
echo -e "${RED}Testes que falharam (${#failing_tests[@]})${NC}:"
for test in "${failing_tests[@]}"; do
  echo "- $test"
done

echo ""
echo "Testes que falharam:"
for test in "${failing_tests[@]}"; do
  echo "$test"
done
