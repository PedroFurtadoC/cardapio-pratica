import os
import sys
import bcrypt
import certifi
from pymongo import MongoClient
from dotenv import load_dotenv

current_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.abspath(os.path.join(current_dir, "..", "..", "backend", ".env"))
load_dotenv(env_path)

MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    print("ERRO: MONGODB_URI não encontrada no .env")
    sys.exit(1)

try:
    print("Conectando ao MongoDB...")
    client = MongoClient(MONGO_URI, tlsCAFile=certifi.where())
    db = client['cardapio']
    client.admin.command('ping')
    print("Conexão OK.")
except Exception as e:
    print(f"Erro de conexão: {e}")
    sys.exit(1)

# Nova senha
new_password = "123"

# Gera hash bcrypt ($2b$12)
hashed = bcrypt.hashpw(new_password.encode(), bcrypt.gensalt(12)).decode()

# Atualiza o admin
result = db.usuarios.update_one(
    {"email": "admin@coracaodemae.com"},
    {"$set": {"senha_hash": hashed}}
)

if result.matched_count == 0:
    print("Nenhum admin encontrado!")
else:
    print("Senha do admin atualizada com sucesso!")

