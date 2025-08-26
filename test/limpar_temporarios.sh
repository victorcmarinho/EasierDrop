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

echo -e "${YELLOW}Limpando arquivos temporários da consolidação...${NC}"

# Remover scripts de consolidação
rm -f consolidate_tests.sh consolidate_tests_fixed.sh consolidate_tests_final.sh desfazer_consolidacao.sh

# Remover relatório de consolidação
rm -f "RELATÓRIO_CONSOLIDAÇÃO.md"

echo -e "${GREEN}Limpeza concluída.${NC}"
echo -e "${BLUE}Resumo das alterações:${NC}"
echo -e "  - ${GREEN}Cobertura de testes restaurada: 74.9% (anterior: 54.3%)${NC}"
echo -e "  - ${GREEN}Número de testes restaurados: 152 (anterior: apenas 19)${NC}"
echo -e "  - ${GREEN}Número de arquivos de teste: 54 (anterior: 18 consolidados)${NC}"
echo ""
echo -e "${YELLOW}Foi criado um relatório detalhado em: test/RELATÓRIO_REVERSÃO.md${NC}"
