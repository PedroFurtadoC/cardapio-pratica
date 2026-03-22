// Definições de modelos de dados para Produtos

import 'enums.dart';

class Produto {
  final String? id;
  final String nome;
  final String descricao;
  final int precoCentavos;
  final String imagemUrl;
  final CategoriaProduto categoria;
  final bool ativo;
  final TipoProduto tipo;
  final Map<String, int>? regrasComposicao;
  final List<String> tagsDieteticas;

  Produto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.precoCentavos,
    required this.imagemUrl,
    required this.categoria,
    required this.ativo,
    required this.tipo,
    this.regrasComposicao,
    this.tagsDieteticas = const [],
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['_id'] as String?,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      precoCentavos: json['preco_centavos'] as int,
      imagemUrl: json['imagem_url'] as String,
      categoria: CategoriaProduto.fromValue(json['categoria'] as String),
      ativo: json['ativo'] as bool,
      tipo: TipoProduto.fromValue(json['tipo'] as String),
      regrasComposicao: json['regras_composicao'] != null 
          ? Map<String, int>.from(json['regras_composicao']) 
          : null,
      tagsDieteticas: List<String>.from(json['tags_dieteticas'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'nome': nome,
      'descricao': descricao,
      'preco_centavos': precoCentavos,
      'imagem_url': imagemUrl,
      'categoria': categoria.value,
      'ativo': ativo,
      'tipo': tipo.value,
      if (regrasComposicao != null) 'regras_composicao': regrasComposicao,
      'tags_dieteticas': tagsDieteticas,
    };
  }
}