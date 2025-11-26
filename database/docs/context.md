# 📘 Contexto do Projeto e Regras de Negócio

**Projeto:** Cardápio Digital - Prática Extensionista VII
**Cliente Real:** Coração de Mãe Alimentos (Ribeirão Preto/SP)
**Nicho:** Alimentação Inclusiva (100% Sem Glúten e Sem Leite)

---

## 1. O Negócio (Realidade Operacional)

A empresa não é uma marmitaria comum. Ela atende um público com restrições alimentares severas (Celíacos, APLV, Intolerantes) e público fitness.

* **Core Business:** Segurança alimentar total. Nenhum ingrediente entra na cozinha se tiver glúten ou leite.
* **Cardápio:** Além das marmitas do dia a dia, possuem salgados artesanais (massa de mandioca/abóbora) e confeitaria funcional.

## 2. A Lógica da "Marmita" (O Desafio Físico)

O sistema precisa resolver o problema de **limitação física** da embalagem e **separação térmica**.

### 2.1. Tamanhos e Limites

Existem 3 tamanhos de marmita. Cada um tem um limite rígido de itens "quentes" (que ocupam volume na embalagem principal).

| Tamanho | Peso Médio | Regra de Composição (Sugestão) |
| :--- | :--- | :--- |
| **Pequena (P)** | 300g~350g | 1 Proteína + 1 Guarnição Quente |
| **Média (M)** | 450g~500g | 1 Proteína + 2 Guarnições Quentes |
| **Grande (G)** | 600g+ | 2 Proteínas + 2 Guarnições Quentes |

### 2.2. A Regra do "Pote Separado" (Crucial)

Para evitar que saladas murchem com o calor da comida, a operação divide os acompanhamentos em dois tipos:

1. **Quentes (Ocupam Espaço):** Arroz, Feijão, Purês, Legumes no Vapor. Estes disputam espaço físico e respeitam o limite da tabela acima.
2. **Frios/Saladas (Embalagem Separada):** Vinagrete, Pepino Sunomono, Salada de Tomate. Estes vão em potes descartáveis à parte.
    * **Regra de Sistema:** Itens marcados como `embalagem_separada: true` **NÃO** consomem o limite de guarnições da marmita.

---

## 3. Modalidades de Entrega e Logística

O sistema deve suportar 3 cenários com validações distintas:

### Cenário A: Delivery (Entrega)

* **Ação:** Motoqueiro leva o pedido.
* **Requisitos:** Obrigatório preencher endereço completo (Rua, Bairro, Nº).
* **Financeiro:** Cobra-se taxa de entrega (baseada no bairro ou fixa).

### Cenário B: Retirada (Takeout)

* **Ação:** Cliente passa para buscar ou agenda horário.
* **Requisitos:** Endereço é oculto/opcional. Exige "Horário de Retirada".
* **Financeiro:** Taxa de entrega é **R$ 0,00**.

### Cenário C: Balcão (Local)

* **Ação:** Pedido feito presencialmente na loja.
* **Requisitos:** Apenas identificação do cliente.
* **Financeiro:** Sem taxa.

---

## 4. Estrutura de Dados (MongoDB)

O banco `cardapio` possui 4 coleções principais já populadas (`seed.py`).

### `produtos` (Itens Vendáveis)

Define se o item é simples (Bebida) ou composto (Marmita).

* Campo `regras_composicao`: Define os limites `{ max_proteina: 1, max_guarnicao: 2 }`.
* Campo `tags_dieteticas`: Lista `["SEM_GLUTEN", "SEM_LEITE"]`.

### `componentes` (Ingredientes de Montagem)

Define as opções disponíveis para montar a marmita.

* Campo `embalagem_separada` (Boolean):
  * `false`: Item Quente (Conta no limite).
  * `true`: Item Frio/Salada (Não conta no limite).

### `pedidos` (Histórico e Vendas)

Armazena o snapshot completo da transação.

* Contém dados do cliente, endereço (se delivery), itens escolhidos e valores finais.
* Status: `RECEBIDO` -> `EM_PREPARO` -> `PRONTO` -> `ENTREGUE`.

### `usuarios` (Acesso)

* Contém o Admin (Dona da Marmitaria) e clientes cadastrados (opcional).

---

## 5. Glossário do Cardápio Real

Para manter a autenticidade no desenvolvimento:

* **Strogonoff:** Feito com leite de coco ou biomassa (Zero Lactose).
* **Coxinha:** Massa amarela feita de mandioca cozida (Zero Trigo).
* **Kibe:** Feito com abóbora ou quinoa (Zero Trigo).
* **Bolo de Cenoura:** Cobertura de chocolate vegano.
