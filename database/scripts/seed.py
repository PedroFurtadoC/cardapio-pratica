import os
import sys
import certifi
from pymongo import MongoClient
from dotenv import load_dotenv
from datetime import datetime

# --- 1. CONFIGURAÇÃO DE AMBIENTE E SEGURANÇA ---
# Garante que o script encontre o .env na pasta database/ (um nível acima)
current_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(current_dir, '..', '.env')
load_dotenv(env_path)

MONGO_URI = os.getenv("MONGODB_URI")

if not MONGO_URI:
    print("ERRO CRÍTICO: Variável 'MONGODB_URI' não encontrada no .env")
    sys.exit(1)

try:
    print("Conectando ao MongoDB Atlas (Secure SSL)...")
    # Certifi garante conexão segura em qualquer Windows/Mac/Linux
    client = MongoClient(MONGO_URI, tlsCAFile=certifi.where())
    db = client['cardapio']
    client.admin.command('ping')
    print("Conexão OK! Iniciando Seed...")
except Exception as e:
    print(f"Erro de Conexão: {e}")
    sys.exit(1)

# --- 2. LIMPEZA TOTAL (Reset para evitar duplicidade) ---
print("Limpando banco de dados antigo...")
db.produtos.delete_many({})
db.componentes.delete_many({})
db.usuarios.delete_many({})
db.pedidos.delete_many({}) 

# --- 3. SEED: PRODUTOS (O que o cliente compra) ---
print("Inserindo Produtos (Cardápio Completo)...")
produtos = [
    # --- MARMITAS (Item Composto) ---
    {
        "nome": "Marmita Pequena (300g)",
        "descricao": "Refeição leve. Escolha 1 Proteína e 1 Guarnição Quente. Saladas em pote separado.",
        "preco_centavos": 2000,
        "imagem_url": "https://placehold.co/600x400/png?text=Marmita+P",
        "categoria": "MARMITAS",
        "ativo": True,
        "tipo": "COMPOSTO",
        "regras_composicao": { "max_base": 2, "max_proteina": 1, "max_guarnicao": 1 },
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]
    },
    {
        "nome": "Marmita Média (500g)",
        "descricao": "Tamanho padrão. Escolha 1 Proteína e 2 Guarnições Quentes. Saladas em pote separado.",
        "preco_centavos": 2600,
        "imagem_url": "https://placehold.co/600x400/png?text=Marmita+M",
        "categoria": "MARMITAS",
        "ativo": True,
        "tipo": "COMPOSTO",
        "regras_composicao": { "max_base": 2, "max_proteina": 1, "max_guarnicao": 2 },
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]
    },
    {
        "nome": "Marmita Grande (700g)",
        "descricao": "Refeição reforçada. Escolha 2 Proteínas e 2 Guarnições Quentes. Saladas em pote separado.",
        "preco_centavos": 3200,
        "imagem_url": "https://placehold.co/600x400/png?text=Marmita+G",
        "categoria": "MARMITAS",
        "ativo": True,
        "tipo": "COMPOSTO",
        "regras_composicao": { "max_base": 2, "max_proteina": 2, "max_guarnicao": 2 },
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]
    },

    # --- SALGADOS E PRATOS ESPECIAIS ---
    {
        "nome": "Coxinha de Frango (Massa de Mandioca)",
        "descricao": "Sem trigo/leite. Massa artesanal de mandioca, empanada na farinha de milho.",
        "preco_centavos": 950,
        "imagem_url": "https://placehold.co/600x400/png?text=Coxinha+Fit",
        "categoria": "SALGADOS",
        "ativo": True,
        "tipo": "SIMPLES",
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]
    },
    {
        "nome": "Kibe de Forno (Massa de Abóbora)",
        "descricao": "Kibe funcional feito com abóbora e quinoa, recheado com carne.",
        "preco_centavos": 950,
        "imagem_url": "https://placehold.co/600x400/png?text=Kibe+Fit",
        "categoria": "SALGADOS",
        "ativo": True,
        "tipo": "SIMPLES",
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]
    },
    {
        "nome": "Escondidinho de Batata Doce c/ Frango",
        "descricao": "Prato congelado pronto. 400g.",
        "preco_centavos": 2400,
        "imagem_url": "https://placehold.co/600x400/png?text=Escondidinho",
        "categoria": "PRATOS PRONTOS",
        "ativo": True,
        "tipo": "SIMPLES",
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]
    },

    # --- BEBIDAS (Completa conforme pedido) ---
    # Coca-Cola
    { "nome": "Coca-Cola Original (Lata 350ml)", "descricao": "Refrigerante.", "preco_centavos": 600, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": [] },
    { "nome": "Coca-Cola Sem Açúcar (Lata 350ml)", "descricao": "Zero Açúcar.", "preco_centavos": 600, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": ["SEM_ACUCAR"] },
    { "nome": "Coca-Cola Original (600ml)", "descricao": "Garrafa média.", "preco_centavos": 850, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": [] },
    { "nome": "Coca-Cola Original (2 Litros)", "descricao": "Garrafa família.", "preco_centavos": 1400, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": [] },
    
    # H2O
    { "nome": "H2O Limão (500ml)", "descricao": "Levemente gaseificada.", "preco_centavos": 700, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": ["SEM_ACUCAR"] },
    { "nome": "H2O Limoneto (500ml)", "descricao": "Sabor intenso de limão.", "preco_centavos": 700, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": ["SEM_ACUCAR"] },
    
    # Sucos e Água
    { "nome": "Suco de Laranja Natural (500ml)", "descricao": "Espremido na hora.", "preco_centavos": 1000, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": ["VEGANO", "SEM_GLUTEN", "SEM_LEITE"] },
    { "nome": "Suco de Uva Integral (300ml)", "descricao": "Sem conservantes.", "preco_centavos": 900, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": ["VEGANO", "SEM_GLUTEN", "SEM_LEITE"] },
    { "nome": "Água Mineral s/ Gás (500ml)", "descricao": "", "preco_centavos": 400, "imagem_url": "...", "categoria": "BEBIDAS", "ativo": True, "tipo": "SIMPLES", "tags_dieteticas": [] },

    # --- SOBREMESAS / DOCES ---
    {
        "nome": "Brownie Fit de Batata Doce",
        "descricao": "Cacau 70%, batata doce e nozes. Sem farinha.",
        "preco_centavos": 1200,
        "imagem_url": "https://placehold.co/600x400/png?text=Brownie",
        "categoria": "SOBREMESAS",
        "ativo": True,
        "tipo": "SIMPLES",
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]
    },
    {
        "nome": "Bolo de Cenoura com Chocolate Vegano",
        "descricao": "Fatia generosa. Cobertura feita com cacau e leite de coco.",
        "preco_centavos": 1400,
        "imagem_url": "https://placehold.co/600x400/png?text=Bolo+Cenoura",
        "categoria": "SOBREMESAS",
        "ativo": True,
        "tipo": "SIMPLES",
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]
    },
    {
        "nome": "Mousse de Maracujá (Biomassa)",
        "descricao": "Feito com biomassa de banana verde. Super cremoso.",
        "preco_centavos": 1100,
        "imagem_url": "https://placehold.co/600x400/png?text=Mousse",
        "categoria": "SOBREMESAS",
        "ativo": True,
        "tipo": "SIMPLES",
        "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]
    }
]
result_prod = db.produtos.insert_many(produtos)

# --- 4. SEED: COMPONENTES (Ingredientes) ---
print("Inserindo Componentes (Bases, Carnes, Guarnições, Saladas)...")
componentes = [
    # --- BASES ---
    {"nome": "Arroz Branco", "tipo": "BASE", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Arroz Integral", "tipo": "BASE", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "FIBRAS"]},
    {"nome": "Feijão Carioca", "tipo": "BASE", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Feijão Preto", "tipo": "BASE", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},

    # --- PROTEÍNAS (Variedade Completa) ---
    {"nome": "Frango Grelhado Acebolado", "tipo": "PROTEINA", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Strogonoff de Frango (Leite de Coco)", "tipo": "PROTEINA", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Strogonoff de Carne (Leite de Coco)", "tipo": "PROTEINA", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 200, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]}, # Extra +R$2
    {"nome": "Picadinho de Patinho com Cenoura", "tipo": "PROTEINA", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Carne de Panela Desfiada (Lagarto)", "tipo": "PROTEINA", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Lombo Suíno Assado com Limão", "tipo": "PROTEINA", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Filé de Tilápia Grelhado", "tipo": "PROTEINA", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 400, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "PESCETARIANO"]}, # Extra +R$4

    # --- GUARNIÇÕES QUENTES (Ocupam Espaço na Marmita) ---
    {"nome": "Mix de Legumes no Vapor (Brócolis/Cenoura)", "tipo": "GUARNICAO", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]},
    {"nome": "Purê de Mandioquinha (s/ leite)", "tipo": "GUARNICAO", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Purê de Abóbora Cabotiá", "tipo": "GUARNICAO", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "LOW_CARB"]},
    {"nome": "Farofa de Milho Crocante", "tipo": "GUARNICAO", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},
    {"nome": "Batata Doce Rústica Assada", "tipo": "GUARNICAO", "embalagem_separada": False, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE"]},

    # --- SALADAS / POTES SEPARADOS (Não Ocupam Espaço - Vai no potinho) ---
    {"nome": "Vinagrete de Chuchu", "tipo": "GUARNICAO", "embalagem_separada": True, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]},
    {"nome": "Salada de Pepino Japonês (Sunomono)", "tipo": "GUARNICAO", "embalagem_separada": True, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]},
    {"nome": "Salada de Tomate Cereja e Manjericão", "tipo": "GUARNICAO", "embalagem_separada": True, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]},
    {"nome": "Jiló Refogado com Cebola", "tipo": "GUARNICAO", "embalagem_separada": True, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]},
    {"nome": "Mix de Folhas (Alface/Rúcula)", "tipo": "GUARNICAO", "embalagem_separada": True, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]},
    {"nome": "Beterraba Ralada Crua", "tipo": "GUARNICAO", "embalagem_separada": True, "ativo": True, "preco_adicional_centavos": 0, "tags_dieteticas": ["SEM_GLUTEN", "SEM_LEITE", "VEGANO"]}
]
db.componentes.insert_many(componentes)

# --- 5. ADMIN ---
print("Criando Admin...")
admin_user = {
    "nome": "Admin Coração de Mãe",
    "email": "admin@coracaodemae.com",
    "senha_hash": "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW", # Senha fake para teste
    "role": "ADMIN",
    "telefone": "16999999999"
}
db.usuarios.insert_one(admin_user)

# --- 6. PEDIDOS EXEMPLO (Para validar a lógica de Entrega) ---
print("Criando Pedidos de Exemplo (Delivery vs Retirada)...")
pedidos_exemplo = [
    # 1. Delivery: Tem endereço, tem taxa
    {
        "codigo_pedido": 1001,
        "data_criacao": datetime.now(),
        "cliente": { "nome": "João Silva", "telefone": "16999991111" },
        "modalidade": "DELIVERY",
        "entrega": { "logradouro": "Rua das Flores", "numero": "123", "bairro": "Jardim Paulista" },
        "status": "RECEBIDO",
        "forma_pagamento": "PIX",
        "valor_produtos_centavos": 2600,
        "taxa_entrega_centavos": 500,
        "valor_total_centavos": 3100,
        "itens": [ { "nome_produto": "Marmita Média", "quantidade": 1, "preco_unitario": 2600, "selecoes": ["Arroz Integral", "Strogonoff de Frango", "Purê de Mandioquinha"] } ]
    },
    # 2. Retirada: Sem endereço, Taxa 0
    {
        "codigo_pedido": 1002,
        "data_criacao": datetime.now(),
        "cliente": { "nome": "Maria Souza", "telefone": "16988882222" },
        "modalidade": "RETIRADA",
        "entrega": None,
        "horario_retirada": "12:30",
        "status": "EM_PREPARO",
        "forma_pagamento": "CREDITO",
        "valor_produtos_centavos": 4000,
        "taxa_entrega_centavos": 0,
        "valor_total_centavos": 4000,
        "itens": [ 
            { "nome_produto": "Marmita Pequena", "quantidade": 1, "preco_unitario": 2000, "selecoes": ["Arroz Branco", "Picadinho"] },
            { "nome_produto": "Marmita Pequena", "quantidade": 1, "preco_unitario": 2000, "selecoes": ["Arroz Integral", "Lombo Suíno"] }
        ]
    }
]
db.pedidos.insert_many(pedidos_exemplo)

print("\n=======================================================")
print("✅ SEED MASTER EXECUTADO COM SUCESSO!")
print("   - Cardápio Completo (Coca 2L, 600ml, H2O, Sucos).")
print("   - Variedade de Carnes, Salgados e Doces.")
print("   - Lógica de Salada (Pote Separado) configurada.")
print("   - Pedidos de exemplo criados para validação.")
print("=======================================================")