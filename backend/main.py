from fastapi import FastAPI, HTTPException, Body, status
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from bson import ObjectId
from datetime import datetime
from pydantic import BaseModel # Importação necessária para o LoginRequest

from db import db, usuarios_collection, produtos_collection, componentes_collection, pedidos_collection
from models import (
    Usuario, UsuarioCreate, UsuarioUpdate,
    Produto, ProdutoUpdate,
    Componente, ComponenteUpdate,
    Pedido, PedidoCreate, PedidoUpdateStatus
)
# IMPORTANTE: Adicione verify_password aqui
from security import get_password_hash, verify_password 

app = FastAPI(title="API Restaurante - CRUD Completo")

# --- CONFIGURAÇÃO DO CORS ---
origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://localhost:3000",
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Modelo para Login ---
class LoginRequest(BaseModel):
    email: str
    password: str

async def get_by_id(collection, id: str):
    if not ObjectId.is_valid(id):
        raise HTTPException(status_code=400, detail="ID inválido")
    doc = await collection.find_one({"_id": ObjectId(id)})
    if doc is None:
        raise HTTPException(status_code=404, detail="Item não encontrado")
    return doc

# ==========================================
# ROTA DE AUTENTICAÇÃO (LOGIN) - CORREÇÃO DO ERRO
# ==========================================

@app.post("/auth/login", tags=["Auth"])
async def login(data: LoginRequest):
    # 1. Buscar usuário pelo email
    user = await usuarios_collection.find_one({"email": data.email})
    
    # 2. Verificar se usuário existe e se a senha bate
    if not user or not verify_password(data.password, user["senha_hash"]):
        raise HTTPException(status_code=401, detail="Email ou senha incorretos")
    
    # 3. Preparar resposta (Converter ObjectId para string)
    user["_id"] = str(user["_id"])
    user.pop("senha_hash", None) # Remover hash da senha por segurança
    
    # 4. Retornar Token (Simulado) e Dados do Usuário
    return {
        "access_token": "token-falso-para-teste-frontend", 
        "token_type": "bearer",
        "user": user
    }

# ==========================================
# CRUD USUARIOS
# ==========================================

@app.post("/usuarios", response_model=Usuario, status_code=201, tags=["Usuarios"])
async def criar_usuario(usuario: UsuarioCreate):
    if await usuarios_collection.find_one({"email": usuario.email}):
        raise HTTPException(status_code=400, detail="Email já cadastrado")
    
    usuario_dict = usuario.model_dump()
    usuario_dict["senha_hash"] = get_password_hash(usuario_dict.pop("senha"))
    
    new_usuario = await usuarios_collection.insert_one(usuario_dict)
    created_usuario = await usuarios_collection.find_one({"_id": new_usuario.inserted_id})
    return created_usuario

@app.get("/usuarios", response_model=List[Usuario], tags=["Usuarios"])
async def listar_usuarios():
    usuarios = await usuarios_collection.find().to_list(1000)
    return usuarios

@app.put("/usuarios/{id}", response_model=Usuario, tags=["Usuarios"])
async def atualizar_usuario(id: str, usuario: UsuarioUpdate):
    update_data = {k: v for k, v in usuario.model_dump().items() if v is not None}
    
    if len(update_data) >= 1:
        result = await usuarios_collection.update_one(
            {"_id": ObjectId(id)}, {"$set": update_data}
        )
        if result.modified_count == 0:
            raise HTTPException(status_code=404, detail="Usuário não encontrado ou sem alterações")
            
    doc = await get_by_id(usuarios_collection, id)
    return doc

@app.delete("/usuarios/{id}", status_code=204, tags=["Usuarios"])
async def deletar_usuario(id: str):
    result = await usuarios_collection.delete_one({"_id": ObjectId(id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")

# ==========================================
# CRUD COMPONENTES
# ==========================================

@app.post("/componentes", response_model=Componente, status_code=201, tags=["Componentes"])
async def criar_componente(componente: Componente):
    new_comp = await componentes_collection.insert_one(componente.model_dump(by_alias=True, exclude=["id"]))
    created_comp = await componentes_collection.find_one({"_id": new_comp.inserted_id})
    return created_comp

@app.get("/componentes", response_model=List[Componente], tags=["Componentes"])
async def listar_componentes():
    return await componentes_collection.find().to_list(1000)

@app.put("/componentes/{id}", response_model=Componente, tags=["Componentes"])
async def atualizar_componente(id: str, componente: ComponenteUpdate):
    update_data = {k: v for k, v in componente.model_dump().items() if v is not None}
    if update_data:
        await componentes_collection.update_one({"_id": ObjectId(id)}, {"$set": update_data})
    return await get_by_id(componentes_collection, id)

@app.delete("/componentes/{id}", status_code=204, tags=["Componentes"])
async def deletar_componente(id: str):
    res = await componentes_collection.delete_one({"_id": ObjectId(id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Componente não encontrado")

# ==========================================
# CRUD PRODUTOS
# ==========================================

@app.post("/produtos", response_model=Produto, status_code=201, tags=["Produtos"])
async def criar_produto(produto: Produto):
    new_prod = await produtos_collection.insert_one(produto.model_dump(by_alias=True, exclude=["id"]))
    created_prod = await produtos_collection.find_one({"_id": new_prod.inserted_id})
    return created_prod

@app.get("/produtos", response_model=List[Produto], tags=["Produtos"])
async def listar_produtos():
    return await produtos_collection.find().to_list(1000)

@app.put("/produtos/{id}", response_model=Produto, tags=["Produtos"])
async def atualizar_produto(id: str, produto: ProdutoUpdate):
    update_data = {k: v for k, v in produto.model_dump().items() if v is not None}
    if update_data:
        await produtos_collection.update_one({"_id": ObjectId(id)}, {"$set": update_data})
    return await get_by_id(produtos_collection, id)

@app.delete("/produtos/{id}", status_code=204, tags=["Produtos"])
async def deletar_produto(id: str):
    res = await produtos_collection.delete_one({"_id": ObjectId(id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Produto não encontrado")

# ==========================================
# CRUD PEDIDOS
# ==========================================

@app.post("/pedidos", response_model=Pedido, status_code=201, tags=["Pedidos"])
async def criar_pedido(pedido_in: PedidoCreate):
    valor_produtos = sum([item.preco_unitario * item.quantidade for item in pedido_in.itens])
    taxa_entrega = 1000 if pedido_in.modalidade == "DELIVERY" else 0
    valor_total = valor_produtos + taxa_entrega

    import time
    codigo_pedido = int(time.time())

    pedido_dict = pedido_in.model_dump()
    pedido_dict.update({
        "codigo_pedido": codigo_pedido,
        "data_criacao": datetime.now(),
        "status": "RECEBIDO",
        "valor_produtos_centavos": valor_produtos,
        "taxa_entrega_centavos": taxa_entrega,
        "valor_total_centavos": valor_total
    })

    new_pedido = await pedidos_collection.insert_one(pedido_dict)
    created_pedido = await pedidos_collection.find_one({"_id": new_pedido.inserted_id})
    return created_pedido

@app.get("/pedidos", response_model=List[Pedido], tags=["Pedidos"])
async def listar_pedidos():
    return await pedidos_collection.find().to_list(1000)

@app.get("/pedidos/{id}", response_model=Pedido, tags=["Pedidos"])
async def ver_pedido(id: str):
    return await get_by_id(pedidos_collection, id)

@app.patch("/pedidos/{id}/status", response_model=Pedido, tags=["Pedidos"])
async def atualizar_status_pedido(id: str, status_update: PedidoUpdateStatus):
    await pedidos_collection.update_one(
        {"_id": ObjectId(id)}, 
        {"$set": {"status": status_update.status}}
    )
    return await get_by_id(pedidos_collection, id)
