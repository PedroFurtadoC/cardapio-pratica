export interface Produto {
    _id: string;
    nome: string;
    descricao: string;
    preco_centavos: number;
    imagem_url: string;
    categoria: "MARMITAS" | "SALGADOS" | "BEBIDAS" | "SOBREMESAS";
    ativo: boolean;
    tipo: "SIMPLES" | "COMPOSTO";
    regras_composicao?: { max_base: number; max_proteina: number; max_guarnicao: number };
    tags_dieteticas: string[]; // Ex: ["SEM_GLUTEN", "SEM_LEITE"]
}

export interface Componente {
    _id: string;
    nome: string;
    tipo: "BASE" | "PROTEINA" | "GUARNICAO";
    embalagem_separada: boolean; // TRUE = Salada (Pote separado), FALSE = Quente (Ocupa espaço)
    ativo: boolean;
    preco_adicional_centavos: number;
}

export interface Pedido {
    cliente: { nome: string; telefone: string };
    modalidade: "DELIVERY" | "RETIRADA" | "BALCAO";
    entrega?: { logradouro: string; numero: string; bairro: string };
    itens: Array<{ nome_produto: string; quantidade: number; selecoes: string[] }>;
    valor_total_centavos: number;
}
