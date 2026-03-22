// Definições de modelos de dados para Pedidos

import 'enums.dart';

class ClienteEmbedded {
  final String nome;
  final String telefone;
  final String? cpfNota;

  ClienteEmbedded({required this.nome, required this.telefone, this.cpfNota});

  factory ClienteEmbedded.fromJson(Map<String, dynamic> json) => ClienteEmbedded(
        nome: json['nome'] as String,
        telefone: json['telefone'] as String,
        cpfNota: json['cpf_nota'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'telefone': telefone,
        if (cpfNota != null) 'cpf_nota': cpfNota,
      };
}

class EnderecoEntrega {
  final String logradouro;
  final String numero;
  final String bairro;

  EnderecoEntrega({required this.logradouro, required this.numero, required this.bairro});

  factory EnderecoEntrega.fromJson(Map<String, dynamic> json) => EnderecoEntrega(
        logradouro: json['logradouro'] as String,
        numero: json['numero'] as String,
        bairro: json['bairro'] as String,
      );

  Map<String, dynamic> toJson() => {
        'logradouro': logradouro,
        'numero': numero,
        'bairro': bairro,
      };
}

class ItemPedidoEmbutido {
  final String nomeProduto;
  final int quantidade;
  final int precoUnitario;
  final List<String> selecoes;

  ItemPedidoEmbutido({
    required this.nomeProduto,
    required this.quantidade,
    required this.precoUnitario,
    this.selecoes = const [],
  });

  factory ItemPedidoEmbutido.fromJson(Map<String, dynamic> json) => ItemPedidoEmbutido(
        nomeProduto: json['nome_produto'] as String,
        quantidade: json['quantidade'] as int,
        precoUnitario: json['preco_unitario'] as int,
        selecoes: List<String>.from(json['selecoes'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'nome_produto': nomeProduto,
        'quantidade': quantidade,
        'preco_unitario': precoUnitario,
        'selecoes': selecoes,
      };
}

class Pedido {
  final String? id;
  final int codigoPedido;
  final DateTime dataCriacao;
  final ClienteEmbedded cliente;
  final ModalidadeEntrega modalidade;
  final EnderecoEntrega? entrega;
  final FormaPagamento formaPagamento;
  final StatusPedido status;
  final int valorProdutosCentavos;
  final int taxaEntregaCentavos;
  final int valorTotalCentavos;
  final List<ItemPedidoEmbutido> itens;

  Pedido({
    this.id,
    required this.codigoPedido,
    required this.dataCriacao,
    required this.cliente,
    required this.modalidade,
    this.entrega,
    required this.formaPagamento,
    required this.status,
    required this.valorProdutosCentavos,
    this.taxaEntregaCentavos = 0,
    required this.valorTotalCentavos,
    required this.itens,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['_id'] as String?,
      codigoPedido: json['codigo_pedido'] as int,
      dataCriacao: DateTime.parse(json['data_criacao'] as String),
      cliente: ClienteEmbedded.fromJson(json['cliente']),
      modalidade: ModalidadeEntrega.fromValue(json['modalidade'] as String),
      entrega: json['entrega'] != null ? EnderecoEntrega.fromJson(json['entrega']) : null,
      formaPagamento: FormaPagamento.fromValue(json['forma_pagamento'] as String),
      status: StatusPedido.fromValue(json['status'] as String),
      valorProdutosCentavos: json['valor_produtos_centavos'] as int,
      taxaEntregaCentavos: json['taxa_entrega_centavos'] as int? ?? 0,
      valorTotalCentavos: json['valor_total_centavos'] as int,
      itens: (json['itens'] as List).map((i) => ItemPedidoEmbutido.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'codigo_pedido': codigoPedido,
      'data_criacao': dataCriacao.toIso8601String(),
      'cliente': cliente.toJson(),
      'modalidade': modalidade.value,
      if (entrega != null) 'entrega': entrega!.toJson(),
      'forma_pagamento': formaPagamento.value,
      'status': status.value,
      'valor_produtos_centavos': valorProdutosCentavos,
      'taxa_entrega_centavos': taxaEntregaCentavos,
      'valor_total_centavos': valorTotalCentavos,
      'itens': itens.map((i) => i.toJson()).toList(),
    };
  }
}