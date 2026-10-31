import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Components/AppCores.dart';
import '../../Components/botao_app.dart';
import '../../Components/dialogo_exclusao.dart';
import '../../DadosFict.dart';
import 'widgets/dialogo_planejamento.dart';

class TelaPlanejamentos extends StatefulWidget {
  final ValueChanged<int> aoAbrirAgenda;

  const TelaPlanejamentos({super.key, required this.aoAbrirAgenda});

  @override
  State<TelaPlanejamentos> createState() => _TelaPlanejamentosState();
}

class _TelaPlanejamentosState extends State<TelaPlanejamentos> {
  final TextEditingController _busca = TextEditingController();
  final Set<String> _tipos = <String>{};
  String? _responsavel;
  String _periodo = 'todos';

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  bool get _temFiltro =>
      _busca.text.trim().isNotEmpty ||
      _tipos.isNotEmpty ||
      (_responsavel != null && _responsavel!.isNotEmpty) ||
      _periodo != 'todos';

  void _limparFiltros() {
    setState(() {
      _busca.clear();
      _tipos.clear();
      _responsavel = null;
      _periodo = 'todos';
    });
  }

  Future<void> _novoPlanejamento() async {
    final item = await abrirDialogoPlanejamento(context);
    if (item == null || !mounted) return;
    context.read<DadosFict>().criar(item);
    _mensagem('Planejamento criado com sucesso.');
  }

  Future<void> _editar(Planejamento item) async {
    final atualizado = await abrirDialogoPlanejamento(context, inicial: item);
    if (atualizado == null || !mounted) return;
    context.read<DadosFict>().atualizar(atualizado);
    _mensagem('Planejamento atualizado.');
  }

  Future<void> _excluir(Planejamento item) async {
    final confirmou = await confirmarExclusao(
      context,
      titulo: 'Excluir planejamento',
      mensagem:
          'Tem certeza que deseja excluir "${item.nome}"? Essa ação não pode ser desfeita.',
    );
    if (!confirmou || !mounted) return;
    context.read<DadosFict>().excluir(item.id);
    _mensagem('Planejamento excluído.');
  }

  void _mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppCores.statusPretoTexto,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        width: 340,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dados = context.watch<DadosFict>();
    final todos = dados.itens;
    final responsavelFiltro =
        _responsavel != null && dados.responsaveis.contains(_responsavel)
        ? _responsavel
        : null;
    final filtrados = dados.filtrar(
      busca: _busca.text,
      tipos: _tipos,
      responsavel: responsavelFiltro,
      periodo: _periodo,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecalho(),
          const SizedBox(height: 18),
          _resumo(todos),
          const SizedBox(height: 18),
          _barraFiltros(dados),
          const SizedBox(height: 16),
          _tabela(filtrados, todos.length),
        ],
      ),
    );
  }

  Widget _cabecalho() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 680;
        final textos = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Planejamentos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppCores.textoPrimario,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Organize ciclos, reuniões e projetos em um só lugar.',
              style: TextStyle(
                fontSize: 12,
                color: AppCores.textoSecundario,
                height: 1.4,
              ),
            ),
          ],
        );

        final botao = BotaoApp.primario(
          texto: 'Novo planejamento',
          icone: Icons.add_rounded,
          aoPressionar: _novoPlanejamento,
        );

        if (compacto) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [textos, const SizedBox(height: 14), botao],
          );
        }

        return Row(
          children: [
            Expanded(child: textos),
            botao,
          ],
        );
      },
    );
  }

  Widget _resumo(List<Planejamento> itens) {
    final ativos = itens.where((item) => item.status == 'A').length;
    final reunioes = itens.where((item) => item.tipo == 'R').length;
    final encerrados = itens.where((item) => item.status == 'E').length;

    final cartoes = [
      _cartaoResumo(
        titulo: 'Total de planejamentos',
        valor: itens.length.toString(),
        detalhe: 'Cadastrados na base fictícia',
        icone: Icons.event_note_outlined,
        cor: AppCores.verdeMarca,
        fundoIcone: AppCores.verdeClaro,
      ),
      _cartaoResumo(
        titulo: 'Em andamento',
        valor: ativos.toString(),
        detalhe: 'Com situação ativa',
        icone: Icons.play_circle_outline_rounded,
        cor: AppCores.statusAzulTexto,
        fundoIcone: AppCores.statusAzul,
      ),
      _cartaoResumo(
        titulo: 'Reuniões',
        valor: reunioes.toString(),
        detalhe: 'Agendadas ou realizadas',
        icone: Icons.groups_outlined,
        cor: AppCores.statusRoxoTexto,
        fundoIcone: AppCores.statusRoxo,
      ),
      _cartaoResumo(
        titulo: 'Encerrados',
        valor: encerrados.toString(),
        detalhe: 'Concluídos e arquivados',
        icone: Icons.check_circle_outline_rounded,
        cor: AppCores.statusPretoTexto,
        fundoIcone: AppCores.statusPreto,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final colunas = largura >= 1050
            ? 4
            : largura >= 680
            ? 2
            : 1;
        final espaco = 14.0;
        final larguraCartao = (largura - (colunas - 1) * espaco) / colunas;

        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [
            for (final cartao in cartoes)
              SizedBox(width: larguraCartao, child: cartao),
          ],
        );
      },
    );
  }

  Widget _cartaoResumo({
    required String titulo,
    required String valor,
    required String detalhe,
    required IconData icone,
    required Color cor,
    required Color fundoIcone,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.tabelaBorda),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: fundoIcone,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppCores.textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppCores.textoPrimario,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalhe,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppCores.iconeBusca,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraFiltros(DadosFict dados) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCores.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.tabelaBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxWidth < 760;
              final busca = SizedBox(
                width: compacto ? constraints.maxWidth : 300,
                child: TextField(
                  controller: _busca,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, responsável ou área',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 19,
                      color: AppCores.iconeBusca,
                    ),
                    suffixIcon: _busca.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpar busca',
                            onPressed: () {
                              _busca.clear();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppCores.iconeBusca,
                            ),
                          ),
                  ),
                ),
              );

              final responsavelAtual =
                  _responsavel != null &&
                      dados.responsaveis.contains(_responsavel)
                  ? _responsavel!
                  : '';

              final responsavel = SizedBox(
                width: compacto ? constraints.maxWidth : 210,
                child: _dropdownFiltro(
                  valor: responsavelAtual,
                  rotulo: 'Responsável',
                  itens: [
                    const DropdownMenuItem(value: '', child: Text('Todos')),
                    for (final nome in dados.responsaveis)
                      DropdownMenuItem(value: nome, child: Text(nome)),
                  ],
                  aoMudar: (valor) {
                    setState(() {
                      _responsavel = valor == null || valor.isEmpty
                          ? null
                          : valor;
                    });
                  },
                ),
              );

              final periodo = SizedBox(
                width: compacto ? constraints.maxWidth : 200,
                child: _dropdownFiltro(
                  valor: _periodo,
                  rotulo: 'Período',
                  itens: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'mes', child: Text('Este mês')),
                    DropdownMenuItem(
                      value: 'proximos',
                      child: Text('Próximos 30 dias'),
                    ),
                  ],
                  aoMudar: (valor) {
                    if (valor != null) setState(() => _periodo = valor);
                  },
                ),
              );

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [busca, responsavel, periodo],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _chipTipo('Todos', null),
              _chipTipo('Ciclos', 'C'),
              _chipTipo('Reuniões', 'R'),
              _chipTipo('Projetos', 'P'),
              if (_temFiltro) ...[
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: _limparFiltros,
                  icon: const Icon(
                    Icons.filter_alt_off_outlined,
                    size: 16,
                    color: AppCores.textoSecundario,
                  ),
                  label: const Text(
                    'Limpar filtros',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppCores.textoSecundario,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdownFiltro({
    required String valor,
    required String rotulo,
    required List<DropdownMenuItem<String>> itens,
    required ValueChanged<String?> aoMudar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppCores.textoSecundario,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppCores.formPreenchimento,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppCores.formBorda),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: valor,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppCores.iconeBusca,
              ),
              style: const TextStyle(
                fontSize: 12,
                color: AppCores.textoPrimario,
              ),
              items: itens,
              onChanged: aoMudar,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chipTipo(String rotulo, String? tipo) {
    final ativo = tipo == null ? _tipos.isEmpty : _tipos.contains(tipo);

    return InkWell(
      onTap: () {
        setState(() {
          if (tipo == null) {
            _tipos.clear();
          } else if (_tipos.contains(tipo)) {
            _tipos.remove(tipo);
          } else {
            _tipos.add(tipo);
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: ativo ? AppCores.statusPretoTexto : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ativo ? AppCores.statusPretoTexto : AppCores.formBorda,
          ),
        ),
        child: Text(
          rotulo,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ativo ? Colors.white : AppCores.textoSecundario,
          ),
        ),
      ),
    );
  }

  Widget _tabela(List<Planejamento> itens, int totalGeral) {
    if (itens.isEmpty) {
      return _estadoVazio();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppCores.tabelaFundo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.tabelaBorda),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final largura = math.max(1120.0, constraints.maxWidth);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: largura,
                child: DataTable(
                  columnSpacing: 16,
                  horizontalMargin: 16,
                  dataRowMinHeight: 62,
                  dataRowMaxHeight: 72,
                  headingRowHeight: 44,
                  headingRowColor: WidgetStateProperty.all(
                    AppCores.tabelaCabecalho,
                  ),
                  dividerThickness: 0.7,
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: _TituloColuna('PLANEJAMENTO')),
                    DataColumn(label: _TituloColuna('TIPO')),
                    DataColumn(label: _TituloColuna('RESPONSÁVEL')),
                    DataColumn(label: _TituloColuna('PERÍODO')),
                    DataColumn(label: _TituloColuna('SITUAÇÃO')),
                    DataColumn(label: _TituloColuna('PROGRESSO')),
                    DataColumn(label: _TituloColuna('AÇÕES')),
                  ],
                  rows: [
                    for (final item in itens)
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 290,
                              child: InkWell(
                                onTap: () => widget.aoAbrirAgenda(item.id),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: AppCores.verdeClaro,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          _iconeTipo(item.tipo),
                                          size: 18,
                                          color: AppCores.verdeMarca,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              item.nome,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppCores.textoPrimario,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item.area}${item.local.isEmpty ? '' : ' • ${item.local}'}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppCores.textoSecundario,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 110,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _chipTipoTabela(item),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 160,
                              child: Text(
                                item.responsavel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppCores.tabelaTextoLinha,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.periodoLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppCores.tabelaTextoLinha,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.horarioLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppCores.textoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 110,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _chipSituacao(item),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(width: 140, child: _progresso(item)),
                          ),
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BotaoIconeApp(
                                    icone: Icons.visibility_outlined,
                                    tooltip: 'Abrir na agenda',
                                    aoPressionar: () =>
                                        widget.aoAbrirAgenda(item.id),
                                  ),
                                  BotaoIconeApp(
                                    icone: Icons.edit_outlined,
                                    tooltip: 'Editar',
                                    aoPressionar: () => _editar(item),
                                  ),
                                  BotaoIconeApp(
                                    icone: Icons.delete_outline_rounded,
                                    tooltip: 'Excluir',
                                    cor: AppCores.statusVermelhoTexto,
                                    aoPressionar: () => _excluir(item),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _chipTipoTabela(Planejamento item) {
    final (fundo, texto) = switch (item.tipo) {
      'R' => (AppCores.statusAzul, AppCores.statusAzulTexto),
      'P' => (AppCores.statusVerde, AppCores.statusVerdeTexto),
      _ => (AppCores.statusRoxo, AppCores.statusRoxoTexto),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.tipoLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: texto,
        ),
      ),
    );
  }

  Widget _chipSituacao(Planejamento item) {
    late final Color fundo;
    late final Color texto;
    late final String rotulo;

    if (item.encerrado) {
      fundo = AppCores.statusPreto;
      texto = AppCores.statusPretoTexto;
      rotulo = 'Encerrado';
    } else if (item.atrasado) {
      fundo = AppCores.statusVermelho;
      texto = AppCores.statusVermelhoTexto;
      rotulo = 'Atrasado';
    } else if (item.status == 'A') {
      fundo = AppCores.statusVerde;
      texto = AppCores.statusVerdeTexto;
      rotulo = 'Ativo';
    } else {
      fundo = AppCores.statusAmarelo;
      texto = AppCores.statusAmareloTexto;
      rotulo = 'Rascunho';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rotulo,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: texto,
        ),
      ),
    );
  }

  Widget _progresso(Planejamento item) {
    if (item.tarefas <= 0) {
      return const Text(
        'Sem tarefas',
        style: TextStyle(fontSize: 10, color: AppCores.iconeBusca),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.tarefasConcluidas} de ${item.tarefas}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppCores.textoSecundario,
          ),
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: item.progresso,
            minHeight: 6,
            backgroundColor: AppCores.whiteSmoke,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppCores.verdeMarca,
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconeTipo(String tipo) {
    switch (tipo) {
      case 'R':
        return Icons.groups_outlined;
      case 'P':
        return Icons.flag_outlined;
      default:
        return Icons.repeat_rounded;
    }
  }

  Widget _estadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: AppCores.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppCores.tabelaBorda),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppCores.verdeClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppCores.verdeMarca,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nenhum planejamento encontrado',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppCores.textoPrimario,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ajuste os filtros ou crie um novo planejamento.',
            style: TextStyle(fontSize: 12, color: AppCores.textoSecundario),
          ),
          const SizedBox(height: 16),
          BotaoApp.primario(
            texto: 'Novo planejamento',
            icone: Icons.add_rounded,
            aoPressionar: _novoPlanejamento,
          ),
        ],
      ),
    );
  }
}

class _TituloColuna extends StatelessWidget {
  final String texto;

  const _TituloColuna(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppCores.tabelaTextoColuna,
      ),
    );
  }
}
