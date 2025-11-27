#!/bin/bash

BASE_URL="http://127.0.0.1:8000"

echo "--- 1. Listar todos os USUARIOS ---"
curl -X 'GET' \
  "${BASE_URL}/usuarios" \
  -H 'accept: application/json'
echo -e "\n"

echo "--- 2. Listar todos os COMPONENTES ---"
curl -X 'GET' \
  "${BASE_URL}/componentes" \
  -H 'accept: application/json'
echo -e "\n"

echo "--- 3. Listar todos os PRODUTOS ---"
curl -X 'GET' \
  "${BASE_URL}/produtos" \
  -H 'accept: application/json'
echo -e "\n"

echo "--- 4. Listar todos os PEDIDOS ---"
curl -X 'GET' \
  "${BASE_URL}/pedidos" \
  -H 'accept: application/json'
echo -e "\n"

# Nota: Para testar o GET de um pedido específico, você precisa pegar um _id 
# retornado no comando anterior (Listar Pedidos) e substituir abaixo.
# Exemplo:
# PEDIDO_ID="6565c..." 
# echo "--- 5. Buscar PEDIDO Específico ---"
# curl -X 'GET' "${BASE_URL}/pedidos/${PEDIDO_ID}" -H 'accept: application/json'
