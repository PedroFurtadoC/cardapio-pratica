// Enumerações para modalidades e formas de pagamento

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
  
  String get label {
    switch (this) {
      case marmitas: return 'Marmitas';
      case salgados: return 'Salgados';
      case bebidas: return 'Bebidas';
      case sobremesas: return 'Sobremesas';
      case pratosProntos: return 'Pratos Prontos';
    }
  }

  factory CategoriaProduto.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum TipoProduto {
  simples('SIMPLES'),
  composto('COMPOSTO');

  final String value;
  const TipoProduto(this.value);

  String get label {
    switch (this) {
      case simples: return 'Prato Simples';
      case composto: return 'Prato Composto';
    }
  }

  factory TipoProduto.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum ModalidadeEntrega {
  delivery('DELIVERY'),
  retirada('RETIRADA'),
  balcao('BALCAO');

  final String value;
  const ModalidadeEntrega(this.value);

  String get label {
    switch (this) {
      case delivery: return '🛵 Delivery';
      case retirada: return '🏃 Retirada no local';
      case balcao: return '🪑 Consumir no balcão';
    }
  }

  factory ModalidadeEntrega.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum FormaPagamento {
  pix('PIX'),
  credito('CREDITO'),
  debito('DEBITO');

  final String value;
  const FormaPagamento(this.value);

  String get label {
    switch (this) {
      case pix: return '📱 PIX';
      case credito: return '💳 Cartão de Crédito';
      case debito: return '💳 Cartão de Débito';
    }
  }

  factory FormaPagamento.fromValue(String v) => values.firstWhere((e) => e.value == v);
}

enum StatusPedido {
  recebido('RECEBIDO'),
  emPreparo('EM_PREPARO'),
  pronto('PRONTO'),
  entregue('ENTREGUE');

  final String value;
  const StatusPedido(this.value);

  String get label {
    switch (this) {
      case recebido: return 'Recebido';
      case emPreparo: return 'Em Preparo';
      case pronto: return 'Pronto para Entrega';
      case entregue: return 'Entregue';
    }
  }

  factory StatusPedido.fromValue(String v) => values.firstWhere((e) => e.value == v);
}