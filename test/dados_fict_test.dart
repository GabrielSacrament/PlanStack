import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_nap1_dev_web/DadosFict.dart';

void main() {
  final dados = DadosFict.instance;

  setUp(() {
    dados.restaurar();
  });

  test('carrega a base fictícia inicial', () {
    expect(dados.itens, isNotEmpty);
    expect(dados.itens.length, 10);
    expect(dados.responsaveis, contains('Ana Souza'));
  });

  test('cria um planejamento com id gerado', () {
    final criado = dados.criar(
      Planejamento(
        nome: 'Planejamento de teste',
        tipo: 'P',
        status: 'A',
        dataInicio: DateTime(2026, 11, 10),
        dataFim: DateTime(2026, 11, 20),
        responsavel: 'Ana Souza',
        area: 'Diretoria',
      ),
    );

    expect(criado.id, greaterThan(0));
    expect(dados.buscarPorId(criado.id)?.nome, 'Planejamento de teste');
    expect(dados.itens.length, 11);
  });

  test('atualiza um planejamento existente', () {
    final item = dados.itens.first;
    final atualizado = item.copyWith(
      nome: 'Nome atualizado',
      status: 'E',
      tarefasConcluidas: item.tarefas,
    );

    dados.atualizar(atualizado);

    expect(dados.buscarPorId(item.id)?.nome, 'Nome atualizado');
    expect(dados.buscarPorId(item.id)?.encerrado, isTrue);
  });

  test('exclui um planejamento', () {
    final item = dados.itens.first;

    dados.excluir(item.id);

    expect(dados.buscarPorId(item.id), isNull);
    expect(dados.itens.length, 9);
  });

  test('filtra por tipo e responsável', () {
    final porTipo = dados.filtrar(tipos: {'R'});
    expect(porTipo, isNotEmpty);
    expect(porTipo.every((item) => item.tipo == 'R'), isTrue);

    final porResponsavel = dados.filtrar(responsavel: 'Ana Souza');
    expect(porResponsavel, isNotEmpty);
    expect(
      porResponsavel.every((item) => item.responsavel == 'Ana Souza'),
      isTrue,
    );
  });

  test('filtra por busca textual', () {
    final resultado = dados.filtrar(busca: 'portal');

    expect(resultado, isNotEmpty);
    expect(
      resultado.every((item) => item.nome.toLowerCase().contains('portal')),
      isTrue,
    );
  });
}
