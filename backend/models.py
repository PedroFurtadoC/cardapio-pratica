from pydantic import BaseModel, Field, EmailStr, BeforeValidator
from typing import Optional, List, Dict, Any, Annotated
from datetime import datetime
from enum import Enum

PyObjectId = Annotated[str, BeforeValidator(str)]

class MongoBaseModel(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)

    class Config:
        populate_by_name = True
        arbitrary_types_allowed = True

class Role(str, Enum):
    ADMIN = "ADMIN"
    CLIENTE = "CLIENTE"

class CategoriaProduto(str, Enum):
    MARMITAS = "MARMITAS"
    SALGADOS = "SALGADOS"
    BEBIDAS = "BEBIDAS"
    SOBREMESAS = "SOBREMESAS"
    PRATOS_PRONTOS = "PRATOS PRONTOS"

class TipoProduto(str, Enum):
    SIMPLES = "SIMPLES"
    COMPOSTO = "COMPOSTO"

class TipoComponente(str, Enum):
    BASE = "BASE"
    PROTEINA = "PROTEINA"
    GUARNICAO = "GUARNICAO"

class ModalidadeEntrega(str, Enum):
    DELIVERY = "DELIVERY"
    RETIRADA = "RETIRADA"
    BALCAO = "BALCAO"

class FormaPagamento(str, Enum):
    PIX = "PIX"
    CREDITO = "CREDITO"
    DEBITO = "DEBITO"

class StatusPedido(str, Enum):
    RECEBIDO = "RECEBIDO"
    EM_PREPARO = "EM_PREPARO"
    PRONTO = "PRONTO"
    ENTREGUE = "ENTREGUE"

class Usuario(MongoBaseModel):
    nome: str
    email: EmailStr
    senha_hash: str
    role: Role
    telefone: str

class UsuarioCreate(BaseModel):
    nome: str
    email: EmailStr
    senha: str
    role: Role
    telefone: str

class UsuarioUpdate(BaseModel):
    nome: Optional[str] = None
    email: Optional[EmailStr] = None
    role: Optional[Role] = None
    telefone: Optional[str] = None

class Componente(MongoBaseModel):
    nome: str
    tipo: TipoComponente
    embalagem_separada: bool
    preco_adicional_centavos: int
    ativo: bool
    tags_dieteticas: List[str] = []

class ComponenteUpdate(BaseModel):
    nome: Optional[str] = None
    tipo: Optional[TipoComponente] = None
    embalagem_separada: Optional[bool] = None
    preco_adicional_centavos: Optional[int] = None
    ativo: Optional[bool] = None
    tags_dieteticas: Optional[List[str]] = None

# --- PRODUTOS ---
class Produto(MongoBaseModel):
    nome: str
    descricao: str
    preco_centavos: int
    imagem_url: str
    categoria: CategoriaProduto
    ativo: bool
    tipo: TipoProduto
    regras_composicao: Optional[Dict[str, int]] = Field(default=None, description="Ex: {'max_proteina': 1}")
    tags_dieteticas: List[str] = []

class ProdutoUpdate(BaseModel):
    nome: Optional[str] = None
    descricao: Optional[str] = None
    preco_centavos: Optional[int] = None
    imagem_url: Optional[str] = None
    categoria: Optional[CategoriaProduto] = None
    ativo: Optional[bool] = None
    tipo: Optional[TipoProduto] = None
    regras_composicao: Optional[Dict[str, int]] = None
    tags_dieteticas: Optional[List[str]] = None


class ClienteEmbedded(BaseModel):
    nome: str
    telefone: str
    cpf_nota: Optional[str] = None

class EnderecoEntrega(BaseModel):
    logradouro: str
    numero: str
    bairro: str

class ItemPedidoEmbutido(BaseModel):
    nome_produto: str
    quantidade: int
    preco_unitario: int
    selecoes: List[str] = []

class Pedido(MongoBaseModel):
    codigo_pedido: int
    data_criacao: datetime = Field(default_factory=datetime.now)
    cliente: ClienteEmbedded
    modalidade: ModalidadeEntrega
    entrega: Optional[EnderecoEntrega] = None
    forma_pagamento: FormaPagamento
    status: StatusPedido = StatusPedido.RECEBIDO
    valor_produtos_centavos: int
    taxa_entrega_centavos: int = 0
    valor_total_centavos: int
    itens: List[ItemPedidoEmbutido]

class PedidoCreate(BaseModel):
    cliente: ClienteEmbedded
    modalidade: ModalidadeEntrega
    entrega: Optional[EnderecoEntrega] = None
    forma_pagamento: FormaPagamento
    itens: List[ItemPedidoEmbutido]

class PedidoUpdateStatus(BaseModel):
    status: StatusPedido
