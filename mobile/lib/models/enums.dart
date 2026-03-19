// lib/models/enums.dart

enum Role {
  admin('ADMIN'),
  cliente('CLIENTE');

  final String value;
  const Role(this.value);
  factory Role.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum CategoriaProduto {
  marmitas('MARMITAS'),
  salgados('SALGADOS'),
  bebidas('BEBIDAS'),
  sobremesas('SOBREMESAS'),
  pratosProntos('PRATOS PRONTOS');

  final String value;
  const CategoriaProduto(this.value);
  factory CategoriaProduto.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum TipoProduto {
  simples('SIMPLES'),
  composto('COMPOSTO');

  final String value;
  const TipoProduto(this.value);
  factory TipoProduto.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum ModalidadeEntrega {
  delivery('DELIVERY'),
  retirada('RETIRADA'),
  balcao('BALCAO');

  final String value;
  const ModalidadeEntrega(this.value);
  factory ModalidadeEntrega.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum FormaPagamento {
  pix('PIX'),
  credito('CREDITO'),
  debito('DEBITO');

  final String value;
  const FormaPagamento(this.value);
  factory FormaPagamento.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum StatusPedido {
  recebido('RECEBIDO'),
  emPreparo('EM_PREPARO'),
  pronto('PRONTO'),
  entregue('ENTREGUE');

  final String value;
  const StatusPedido(this.value);
  factory StatusPedido.fromValue(String v) => values.firstWhere((e) => e.value == v);
}