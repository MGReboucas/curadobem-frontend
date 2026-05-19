class CarrinhoItem {
  final Map<String, String> produto;
  final String? tamanho;
  final String? cor;
  int quantidade;

  CarrinhoItem({
    required this.produto,
    this.tamanho,
    this.cor,
    this.quantidade = 1,
  });
}
