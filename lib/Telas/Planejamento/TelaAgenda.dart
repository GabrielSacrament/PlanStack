import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Components/AppCores.dart';
import '../../Components/botao_app.dart';
import '../../DadosFict.dart';
import 'widgets/dialogo_planejamento.dart';

class TelaAgenda extends StatefulWidget {
  final int? planejamentoId;
  final ValueChanged<int> aoAbrirPlanejamento;
  final VoidCallback aoLimparSelecao;

  const TelaAgenda({
    super.key,
    required this.planejamentoId,
    required this.aoAbrirPlanejamento,
    required this.aoLimparSelecao,
  });

  @override
  State<TelaAgenda> createState() => _TelaAgendaState();
}

class _TelaAgendaState extends State<TelaAgenda> {
  String _aba = 'resumo';
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _formato = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    final item = widget.planejamentoId == null
        ? null
        : DadosFict.instance.buscarPorId(widget.planejamentoId!);
    _focusedDay = item?.dataInicio ?? DateTime.now();
    _selectedDay = item?.dataInicio ?? DateTime.now();
  }

  Future<void> _editar(Planejamento item) async {
    final atualizado = await abrirDialogoPlanejamento(context, inicial: item);
    if (atualizado == null || !mounted) return;
    context.read<DadosFict>().atualizar(atualizado);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Planejamento atualizado.'),
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
    final selecionado = widget.planejamentoId == null
        ? null
        : dados.buscarPorId(widget.planejamentoId!);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecalho(selecionado),
          const SizedBox(height: 16),
          _linhaAbas(),
          const SizedBox(height: 16),
          if (_aba == 'resumo')
            selecionado == null ? _resumoGeral(dados) : _resumoItem(selecionado)
          else
            _calendario(dados),
        ],
      ),
    );
  }

  Widget _cabecalho(Planejamento? selecionado) {
    if (selecionado == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _decoracaoCard(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 620;

            final info = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _caixaIcone(
                  Icons.calendar_month_outlined,
                  AppCores.verdeMarca,
                  AppCores.verdeClaro,
                  48,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agenda',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: AppCores.textoPrimario,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Visão geral de todos os planejamentos. Selecione um item na lista ou no calendário.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppCores.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final selo = Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppCores.statusPreto,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Todos os planejamentos',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppCores.statusPretoTexto,
                ),
              ),
            );

            if (compacto) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [info, const SizedBox(height: 12), selo],
              );
            }

            return Row(
              children: [
                Expanded(child: info),
                const SizedBox(width: 12),
                selo,
              ],
            );
          },
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth < 780;

          final info = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _caixaIcone(
                _iconeTipo(selecionado.tipo),
                AppCores.verdeMarca,
                AppCores.verdeClaro,
                48,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selecionado.nome,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppCores.textoPrimario,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _chipTipo(selecionado),
                        _chipSituacao(selecionado),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        _linhaInfo(
                          Icons.person_outline_rounded,
                          selecionado.responsavel,
                        ),
                        _linhaInfo(
                          Icons.event_outlined,
                          selecionado.periodoLabel,
                        ),
                        _linhaInfo(
                          Icons.schedule_rounded,
                          selecionado.horarioLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final acoes = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BotaoApp.secundario(
                texto: 'Limpar seleção',
                icone: Icons.close_rounded,
                aoPressionar: widget.aoLimparSelecao,
              ),
              BotaoApp.primario(
                texto: 'Editar',
                icone: Icons.edit_outlined,
                aoPressionar: () => _editar(selecionado),
              ),
            ],
          );

          if (compacto) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [info, const SizedBox(height: 14), acoes],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: info),
              const SizedBox(width: 16),
              acoes,
            ],
          );
        },
      ),
    );
  }

  Widget _linhaAbas() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppCores.backgroundCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppCores.tabelaBorda),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          _pillAba(
            chave: 'resumo',
            rotulo: 'Resumo',
            icone: Icons.insights_outlined,
          ),
          _pillAba(
            chave: 'calendario',
            rotulo: 'Calendário',
            icone: Icons.calendar_month_outlined,
          ),
        ],
      ),
    );
  }

  Widget _pillAba({
    required String chave,
    required String rotulo,
    required IconData icone,
  }) {
    final ativa = _aba == chave;
    return InkWell(
      onTap: () => setState(() => _aba = chave),
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: ativa ? AppCores.statusPretoTexto : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 16,
              color: ativa ? Colors.white : AppCores.iconePadrao,
            ),
            const SizedBox(width: 7),
            Text(
              rotulo,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ativa ? Colors.white : AppCores.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumoItem(Planejamento item) {
    final pautas = item.pautas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaKpis([
          _kpi(
            titulo: 'Pautas',
            valor: pautas.length.toString(),
            detalhe: 'Itens para discussão',
            icone: Icons.format_list_bulleted_rounded,
            cor: AppCores.statusAzulTexto,
            fundo: AppCores.statusAzul,
          ),
          _kpi(
            titulo: 'Tarefas',
            valor: item.tarefas.toString(),
            detalhe: 'Previstas no planejamento',
            icone: Icons.checklist_rounded,
            cor: AppCores.statusRoxoTexto,
            fundo: AppCores.statusRoxo,
          ),
          _kpi(
            titulo: 'Concluídas',
            valor: item.tarefasConcluidas.toString(),
            detalhe: 'Entregas finalizadas',
            icone: Icons.task_alt_rounded,
            cor: AppCores.statusVerdeTexto,
            fundo: AppCores.statusVerde,
          ),
          _kpi(
            titulo: 'Progresso',
            valor: '${(item.progresso * 100).round()}%',
            detalhe: item.atrasado ? 'Atenção ao prazo' : 'Dentro do prazo',
            icone: Icons.trending_up_rounded,
            cor: item.atrasado
                ? AppCores.statusVermelhoTexto
                : AppCores.statusPretoTexto,
            fundo: item.atrasado
                ? AppCores.statusVermelho
                : AppCores.statusPreto,
          ),
        ]),
        const SizedBox(height: 16),
        _cardProgresso(item),
        const SizedBox(height: 16),
        _cardInformacoes(item),
        const SizedBox(height: 16),
        _cardPautas(pautas),
        if (item.notas.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _cardNotas(item.notas),
        ],
      ],
    );
  }

  Widget _resumoGeral(DadosFict dados) {
    final itens = dados.itens;
    final ativos = itens.where((item) => item.status == 'A').length;
    final reunioes = itens.where((item) => item.tipo == 'R').length;
    final encerrados = itens.where((item) => item.status == 'E').length;

    final proximos = itens
        .where((item) => !item.encerrado)
        .where((item) {
          final hoje = DateTime.now();
          final referencia = DateTime(hoje.year, hoje.month, hoje.day);
          return !item.dataFim.isBefore(referencia);
        })
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaKpis([
          _kpi(
            titulo: 'Total',
            valor: itens.length.toString(),
            detalhe: 'Planejamentos cadastrados',
            icone: Icons.event_note_outlined,
            cor: AppCores.verdeMarca,
            fundo: AppCores.verdeClaro,
          ),
          _kpi(
            titulo: 'Ativos',
            valor: ativos.toString(),
            detalhe: 'Em andamento',
            icone: Icons.play_circle_outline_rounded,
            cor: AppCores.statusAzulTexto,
            fundo: AppCores.statusAzul,
          ),
          _kpi(
            titulo: 'Reuniões',
            valor: reunioes.toString(),
            detalhe: 'Agendadas ou realizadas',
            icone: Icons.groups_outlined,
            cor: AppCores.statusRoxoTexto,
            fundo: AppCores.statusRoxo,
          ),
          _kpi(
            titulo: 'Encerrados',
            valor: encerrados.toString(),
            detalhe: 'Concluídos',
            icone: Icons.check_circle_outline_rounded,
            cor: AppCores.statusPretoTexto,
            fundo: AppCores.statusPreto,
          ),
        ]),
        const SizedBox(height: 16),
        _cardDistribuicao(itens),
        const SizedBox(height: 16),
        _cardProximos(proximos),
      ],
    );
  }

  Widget _linhaKpis(List<Widget> cartoes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final colunas = largura >= 1000
            ? 4
            : largura >= 640
            ? 2
            : 1;
        const espaco = 14.0;
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

  Widget _kpi({
    required String titulo,
    required String valor,
    required String detalhe,
    required IconData icone,
    required Color cor,
    required Color fundo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoracaoCard(),
      child: Row(
        children: [
          _caixaIcone(icone, cor, fundo, 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
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

  Widget _cardProgresso(Planejamento item) {
    final percentual = (item.progresso * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Progresso do planejamento',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppCores.textoPrimario,
                  ),
                ),
              ),
              Text(
                '$percentual%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: item.atrasado
                      ? AppCores.statusVermelhoTexto
                      : AppCores.verdeMarca,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: item.progresso,
              minHeight: 10,
              backgroundColor: AppCores.whiteSmoke,
              valueColor: AlwaysStoppedAnimation<Color>(
                item.atrasado
                    ? AppCores.statusVermelhoTexto
                    : AppCores.verdeMarca,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${item.tarefasConcluidas} de ${item.tarefas} tarefas concluídas',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppCores.textoSecundario,
                ),
              ),
              const Spacer(),
              if (item.atrasado)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppCores.statusVermelhoTexto,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Prazo vencido',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppCores.statusVermelhoTexto,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardInformacoes(Planejamento item) {
    final itens = [
      _infoItem('Responsável', item.responsavel, Icons.person_outline_rounded),
      _infoItem('Área', item.area, Icons.work_outline_rounded),
      _infoItem(
        'Local',
        item.local.isEmpty ? 'Não informado' : item.local,
        Icons.place_outlined,
      ),
      _infoItem('Início', item.periodoLabel, Icons.event_outlined),
      _infoItem('Horário', item.horarioLabel, Icons.schedule_rounded),
      _infoItem('Situação', item.statusLabel, Icons.flag_outlined),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppCores.textoPrimario,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final colunas = constraints.maxWidth >= 760
                  ? 3
                  : constraints.maxWidth >= 480
                  ? 2
                  : 1;
              const espaco = 12.0;
              final largura =
                  (constraints.maxWidth - (colunas - 1) * espaco) / colunas;
              return Wrap(
                spacing: espaco,
                runSpacing: espaco,
                children: [
                  for (final info in itens)
                    SizedBox(width: largura, child: info),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String rotulo, String valor, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppCores.whiteSmoke,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 16, color: AppCores.verdeMarca),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppCores.textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppCores.textoPrimario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardPautas(List<String> pautas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pautas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppCores.textoPrimario,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppCores.statusAzul,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pautas.length} itens',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppCores.statusAzulTexto,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pautas.isEmpty)
            const Text(
              'Nenhuma pauta cadastrada.',
              style: TextStyle(fontSize: 12, color: AppCores.textoSecundario),
            )
          else
            for (var i = 0; i < pautas.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == pautas.length - 1 ? 0 : 9,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppCores.verdeClaro,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppCores.verdeMarca,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          pautas[i],
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppCores.tabelaTextoLinha,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _cardNotas(String notas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppCores.textoPrimario,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notas,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppCores.tabelaTextoLinha,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardDistribuicao(List<Planejamento> itens) {
    final total = itens.length;
    final grupos = [
      (
        'Reuniões',
        itens.where((item) => item.tipo == 'R').length,
        AppCores.statusAzulTexto,
        AppCores.statusAzul,
      ),
      (
        'Ciclos',
        itens.where((item) => item.tipo == 'C').length,
        AppCores.statusRoxoTexto,
        AppCores.statusRoxo,
      ),
      (
        'Projetos',
        itens.where((item) => item.tipo == 'P').length,
        AppCores.statusVerdeTexto,
        AppCores.statusVerde,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribuição por tipo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppCores.textoPrimario,
            ),
          ),
          const SizedBox(height: 16),
          for (final grupo in grupos) ...[
            Row(
              children: [
                SizedBox(
                  width: 74,
                  child: Text(
                    grupo.$1,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppCores.tabelaTextoLinha,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : grupo.$2 / total,
                      minHeight: 8,
                      backgroundColor: AppCores.whiteSmoke,
                      valueColor: AlwaysStoppedAnimation<Color>(grupo.$3),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${grupo.$2}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppCores.textoPrimario,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _cardProximos(List<Planejamento> proximos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximos compromissos',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppCores.textoPrimario,
            ),
          ),
          const SizedBox(height: 12),
          if (proximos.isEmpty)
            const Text(
              'Nenhum compromisso futuro cadastrado.',
              style: TextStyle(fontSize: 12, color: AppCores.textoSecundario),
            )
          else
            for (var i = 0; i < proximos.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == proximos.length - 1 ? 0 : 8,
                ),
                child: InkWell(
                  onTap: () => widget.aoAbrirPlanejamento(proximos[i].id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppCores.whiteSmoke,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppCores.tabelaBorda),
                          ),
                          child: Icon(
                            _iconeTipo(proximos[i].tipo),
                            size: 17,
                            color: AppCores.verdeMarca,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                proximos[i].nome,
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
                                '${proximos[i].periodoLabel} • ${proximos[i].responsavel}',
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
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppCores.iconeBusca,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _calendario(DadosFict dados) {
    final eventosDia = _eventosDoDia(dados, _selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _decoracaoCard(),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compacto = constraints.maxWidth < 520;
                  final titulo = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calendário de planejamentos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppCores.textoPrimario,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Clique em um planejamento para ver o resumo.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppCores.textoSecundario,
                        ),
                      ),
                    ],
                  );
                  final toggle = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _pillFormato('Mês', CalendarFormat.month),
                      const SizedBox(width: 4),
                      _pillFormato('Semana', CalendarFormat.week),
                    ],
                  );

                  if (compacto) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [titulo, const SizedBox(height: 10), toggle],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: titulo),
                      toggle,
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              TableCalendar<Planejamento>(
                locale: 'pt_BR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _formato,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mês',
                  CalendarFormat.week: 'Semana',
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _eventosDoDia(dados, day),
                onFormatChanged: (formato) {
                  setState(() => _formato = formato);
                },
                onDaySelected: (selecionado, focado) {
                  setState(() {
                    _selectedDay = selecionado;
                    _focusedDay = focado;
                  });
                },
                onPageChanged: (focado) => _focusedDay = focado,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppCores.textoPrimario,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left_rounded,
                    color: AppCores.textoSecundario,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right_rounded,
                    color: AppCores.textoSecundario,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppCores.tabelaTextoColuna,
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppCores.tabelaTextoColuna,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  cellMargin: const EdgeInsets.all(4),
                  todayDecoration: const BoxDecoration(
                    color: AppCores.verdeClaro,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppCores.verdeMarca,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppCores.verdeMarca,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  defaultTextStyle: const TextStyle(
                    fontSize: 12,
                    color: AppCores.textoPrimario,
                  ),
                  weekendTextStyle: const TextStyle(
                    fontSize: 12,
                    color: AppCores.textoPrimario,
                  ),
                  outsideTextStyle: const TextStyle(
                    fontSize: 12,
                    color: AppCores.formBorda,
                  ),
                ),
                calendarBuilders: CalendarBuilders<Planejamento>(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final evento in events.take(3))
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: _corTipo(evento.tipo),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _cardEventosDia(eventosDia),
      ],
    );
  }

  Widget _pillFormato(String rotulo, CalendarFormat formato) {
    final ativo = _formato == formato;
    return InkWell(
      onTap: () => setState(() => _formato = formato),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: ativo ? AppCores.statusPretoTexto : AppCores.whiteSmoke,
          borderRadius: BorderRadius.circular(20),
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

  Widget _cardEventosDia(List<Planejamento> eventos) {
    final data = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(_selectedDay);
    final dataFormatada = _capitalizar(data);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracaoCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataFormatada,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppCores.textoPrimario,
            ),
          ),
          const SizedBox(height: 12),
          if (eventos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: AppCores.whiteSmoke,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 28,
                    color: AppCores.iconeBusca,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nenhum planejamento neste dia.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppCores.textoSecundario,
                    ),
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < eventos.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == eventos.length - 1 ? 0 : 8,
                ),
                child: InkWell(
                  onTap: () => widget.aoAbrirPlanejamento(eventos[i].id),
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppCores.whiteSmoke,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppCores.tabelaBorda),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            _iconeTipo(eventos[i].tipo),
                            size: 18,
                            color: _corTipo(eventos[i].tipo),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventos[i].nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppCores.textoPrimario,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Wrap(
                                spacing: 8,
                                runSpacing: 3,
                                children: [
                                  Text(
                                    eventos[i].horarioLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppCores.textoSecundario,
                                    ),
                                  ),
                                  Text(
                                    eventos[i].responsavel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppCores.textoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _chipTipo(eventos[i]),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppCores.iconeBusca,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  List<Planejamento> _eventosDoDia(DadosFict dados, DateTime dia) {
    return dados.itens.where((item) => item.iniciaEm(dia)).toList();
  }

  Widget _chipTipo(Planejamento item) {
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

  Widget _linhaInfo(IconData icone, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 13, color: AppCores.iconeBusca),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(fontSize: 11, color: AppCores.textoSecundario),
        ),
      ],
    );
  }

  Widget _caixaIcone(IconData icone, Color cor, Color fundo, double tamanho) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(tamanho * 0.24),
      ),
      child: Icon(icone, color: cor, size: tamanho * 0.48),
    );
  }

  BoxDecoration _decoracaoCard() {
    return BoxDecoration(
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

  Color _corTipo(String tipo) {
    switch (tipo) {
      case 'R':
        return AppCores.statusAzulTexto;
      case 'P':
        return AppCores.statusVerdeTexto;
      default:
        return AppCores.statusRoxoTexto;
    }
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }
}
