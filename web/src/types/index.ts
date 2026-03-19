// Enums baseados no Backend
export type Role = 'ADMIN' | 'CLIENTE';

export type CategoriaProduto = 
	| 'MARMITAS' 
	| 'SALGADOS' 
	| 'BEBIDAS' 
	| 'SOBREMESAS' 
	| 'PRATOS PRONTOS';

export type TipoProduto = 'SIMPLES' | 'COMPOSTO';
export type TipoComponente = 'BASE' | 'PROTEINA' | 'GUARNICAO';
export type ModalidadeEntrega = 'DELIVERY' | 'RETIRADA' | 'BALCAO';
export type FormaPagamento = 'PIX' | 'CREDITO' | 'DEBITO';
export type StatusPedido = 'RECEBIDO' | 'EM_PREPARO' | 'PRONTO' | 'ENTREGUE';

// --- USUARIOS ---
export interface Usuario {
	_id: string;
	nome: string;
	email: string;
	role: Role;
	telefone: string;
	senha_hash?: string; // Opcional pois nem sempre precisamos exibir
}

export interface UsuarioCreate {
	nome: string;
	email: string;
	senha: string; // Senha pura para envio
	role: Role;
	telefone: string;
}

export interface UsuarioUpdate {
	nome?: string;
	email?: string;
	role?: Role;
	telefone?: string;
}

// --- COMPONENTES ---
export interface Componente {
	_id: string;
	nome: string;
	tipo: TipoComponente;
	embalagem_separada: boolean;
	preco_adicional_centavos: number;
	ativo: boolean;
	tags_dieteticas: string[];
}

export interface ComponenteCreate extends Omit<Componente, '_id'> {}

export interface ComponenteUpdate extends Partial<ComponenteCreate> {}

// --- PRODUTOS ---
export interface Produto {
	_id: string;
	nome: string;
	descricao: string;
	preco_centavos: number;
	imagem_url: string;
	categoria: CategoriaProduto;
	ativo: boolean;
	tipo: TipoProduto;
	regras_composicao?: Record<string, number>; // Ex: { max_proteina: 1 }
	tags_dieteticas: string[];
}

export interface ProdutoCreate extends Omit<Produto, '_id'> {}

export interface ProdutoUpdate extends Partial<ProdutoCreate> {}

// --- PEDIDOS (Sub-interfaces) ---
export interface ClienteEmbedded {
	nome: string;
	telefone: string;
	cpf_nota?: string;
}

export interface EnderecoEntrega {
	logradouro: string;
	numero: string;
	bairro: string;
}

export interface ItemPedidoEmbutido {
	nome_produto: string;
	quantidade: number;
	preco_unitario: number;
	selecoes: string[]; // Nomes dos componentes
}

// --- PEDIDO PRINCIPAL ---
export interface Pedido {
	_id: string;
	codigo_pedido: number;
	data_criacao: string; // ISO Date String
	cliente: ClienteEmbedded;
	modalidade: ModalidadeEntrega;
	entrega?: EnderecoEntrega;
	forma_pagamento: FormaPagamento;
	status: StatusPedido;
	valor_produtos_centavos: number;
	taxa_entrega_centavos: number;
	valor_total_centavos: number;
	itens: ItemPedidoEmbutido[];
}

export interface PedidoCreate {
	cliente: ClienteEmbedded;
	modalidade: ModalidadeEntrega;
	entrega?: EnderecoEntrega;
	forma_pagamento: FormaPagamento;
	itens: ItemPedidoEmbutido[];
}
