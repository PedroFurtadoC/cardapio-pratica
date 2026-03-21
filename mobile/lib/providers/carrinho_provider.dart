import 'package:flutter/material.dart';
import '../models/pedido.dart';

class CarrinhoProvider extends ChangeNotifier {
  final List<ItemPedidoEmbutido> _itens = [];

  List<ItemPedidoEmbutido> get itens => List.unmodifiable(_itens);

  bool get isEmpty => _itens.isEmpty;

  int get quantidadeTotal =>
      _itens.fold(0, (total, item) => total + item.quantidade);

  int get valorTotalCentavos =>
      _itens.fold(0, (total, item) => total + (item.precoUnitario * item.quantidade));

  String get valorTotalFormatado =>
      'R\$ ${(valorTotalCentavos / 100).toStringAsFixed(2).replaceAll('.', ',')}';

  void adicionar(ItemPedidoEmbutido novoItem) {
    final index = _itens.indexWhere(
      (item) => item.nomeProduto == novoItem.nomeProduto,
    );

    if (index != -1) {
      final atual = _itens[index];
      _itens[index] = ItemPedidoEmbutido(
        nomeProduto: atual.nomeProduto,
        precoUnitario: atual.precoUnitario,
        quantidade: atual.quantidade + novoItem.quantidade,
        selecoes: atual.selecoes,
      );
    } else {
      _itens.add(novoItem);
    }

    notifyListeners();
  }

  void remover(int index) {
    _itens.removeAt(index);
    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }
}