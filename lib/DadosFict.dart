import 'package:flutter/foundation.dart';

class Planejamento {
  final int id;
  final String nome;
  final String tipo;
  final String status;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String horaInicio;
  final String horaFim;
  final String responsavel;
  final String area;
  final String local;
  final String notas;
  final List<String> pautas;
  final int tarefas;
  final int tarefasConcluidas;

  const Planejamento({
    this.id = 0,
    required this.nome,
    required this.tipo,
    required this.status,
    required this.dataInicio,
    required this.dataFim,
    this.horaInicio = '09:00',
    this.horaFim = '10:00',
    required this.responsavel,
    required this.area,
    this.local = '',
    this.notas = '',
    this.pautas = const [],
    this.tarefas = 0,
    this.tarefasConcluidas = 0,
  });

  String get tipoLabel {
    switch (tipo) {
      case 'R':
        return 'Reunião';
      case 'P':
        return 'Projeto';
      default:
        return 'Ciclo';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'A':
        return 'Ativo';
      case 'E':
        return 'Encerrado';
      default:
        return 'Rascunho';
    }
  }

  bool get encerrado => status == 'E';

  bool get atrasado {
    if (encerrado) return false;
    final fim = DateTime(dataFim.year, dataFim.month, dataFim.day, 23, 59);
    return fim.isBefore(DateTime.now());
  }

  double get progresso {
    if (tarefas <= 0) return 0;
    return (tarefasConcluidas / tarefas).clamp(0, 1).toDouble();
  }

  String get periodoLabel {
    final inicio = _dataCurta(dataInicio);
    final fim = _dataCurta(dataFim);
    if (inicio == fim) return inicio;
    return '$inicio a $fim';
  }

  String get horarioLabel {
    if (horaInicio.isEmpty && horaFim.isEmpty) return 'Sem horário';
    if (horaFim.isEmpty) return horaInicio;
    return '$horaInicio às $horaFim';
  }

  bool iniciaEm(DateTime dia) {
    return dataInicio.year == dia.year &&
        dataInicio.month == dia.month &&
        dataInicio.day == dia.day;
  }

  Planejamento copyWith({
    int? id,
    String? nome,
    String? tipo,
    String? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? horaInicio,
    String? horaFim,
    String? responsavel,
    String? area,
    String? local,
    String? notas,
    List<String>? pautas,
    int? tarefas,
    int? tarefasConcluidas,
  }) {
    return Planejamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      responsavel: responsavel ?? this.responsavel,
      area: area ?? this.area,
      local: local ?? this.local,
      notas: notas ?? this.notas,
      pautas: pautas ?? this.pautas,
      tarefas: tarefas ?? this.tarefas,
      tarefasConcluidas: tarefasConcluidas ?? this.tarefasConcluidas,
    );
  }

  static String _dataCurta(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }
}

class DadosFict extends ChangeNotifier {
  DadosFict._() {
    _semear();
  }

  static final DadosFict instance = DadosFict._();

  factory DadosFict() => instance;

  final List<Planejamento> _itens = [];
  int _proximoId = 1;

  List<Planejamento> get itens {
    final lista = List<Planejamento>.from(_itens)
      ..sort((a, b) => a.dataInicio.compareTo(b.dataInicio));
    return List.unmodifiable(lista);
  }

  List<String> get responsaveis {
    final valores = _itens.map((item) => item.responsavel).toSet().toList()
      ..sort();
    return valores;
  }

  List<String> get areas {
    final valores = _itens.map((item) => item.area).toSet().toList()..sort();
    return valores;
  }

  Planejamento? buscarPorId(int id) {
    for (final item in _itens) {
      if (item.id == id) return item;
    }
    return null;
  }

  Planejamento criar(Planejamento planejamento) {
    final novo = planejamento.copyWith(id: _proximoId++);
    _itens.add(novo);
    notifyListeners();
    return novo;
  }

  void atualizar(Planejamento planejamento) {
    final indice = _itens.indexWhere((item) => item.id == planejamento.id);
    if (indice < 0) return;
    _itens[indice] = planejamento;
    notifyListeners();
  }

  void excluir(int id) {
    final antes = _itens.length;
    _itens.removeWhere((item) => item.id == id);
    if (_itens.length != antes) notifyListeners();
  }

  List<Planejamento> filtrar({
    String busca = '',
    Set<String> tipos = const {},
    String? responsavel,
    String? periodo,
  }) {
    final termo = busca.trim().toLowerCase();
    final agora = DateTime.now();

    return itens.where((item) {
      if (termo.isNotEmpty) {
        final conteudo =
            '${item.nome} ${item.responsavel} ${item.area} ${item.local}'
                .toLowerCase();
        if (!conteudo.contains(termo)) return false;
      }

      if (tipos.isNotEmpty && !tipos.contains(item.tipo)) return false;

      if (responsavel != null &&
          responsavel.isNotEmpty &&
          item.responsavel != responsavel) {
        return false;
      }

      if (periodo == 'mes') {
        if (item.dataInicio.year != agora.year ||
            item.dataInicio.month != agora.month) {
          return false;
        }
      }

      if (periodo == 'proximos') {
        final limite = DateTime(agora.year, agora.month, agora.day + 30);
        final inicio = DateTime(
          item.dataInicio.year,
          item.dataInicio.month,
          item.dataInicio.day,
        );
        if (inicio.isAfter(limite)) return false;
        if (item.dataFim.isBefore(
          DateTime(agora.year, agora.month, agora.day),
        )) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void restaurar() {
    _itens.clear();
    _proximoId = 1;
    _semear();
    notifyListeners();
  }

  void _semear() {
    final hoje = DateTime.now();
    DateTime dia(int acrescimo) {
      return DateTime(hoje.year, hoje.month, hoje.day + acrescimo);
    }

    final seed = <Planejamento>[
      Planejamento(
        id: _proximoId++,
        nome: 'Reunião de alinhamento semanal',
        tipo: 'R',
        status: 'A',
        dataInicio: dia(1),
        dataFim: dia(1),
        horaInicio: '09:00',
        horaFim: '10:00',
        responsavel: 'Ana Souza',
        area: 'Diretoria',
        local: 'Sala de reuniões 1',
        notas:
            'Alinhamento das prioridades da semana e distribuição das frentes.',
        pautas: [
          'Revisão dos indicadores da semana',
          'Prioridades dos próximos 7 dias',
          'Pontos de atenção dos projetos',
        ],
        tarefas: 8,
        tarefasConcluidas: 3,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Ciclo mensal de outubro',
        tipo: 'C',
        status: 'A',
        dataInicio: dia(-5),
        dataFim: dia(25),
        horaInicio: '08:00',
        horaFim: '18:00',
        responsavel: 'Mariana Lima',
        area: 'Operações',
        local: 'Operações',
        notas: 'Ciclo de acompanhamento das entregas operacionais do mês.',
        pautas: [
          'Consolidar entregas da primeira quinzena',
          'Revisar gargalos operacionais',
          'Planejar a próxima sprint',
        ],
        tarefas: 24,
        tarefasConcluidas: 14,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Projeto Novo Portal',
        tipo: 'P',
        status: 'A',
        dataInicio: dia(-10),
        dataFim: dia(40),
        horaInicio: '08:30',
        horaFim: '17:30',
        responsavel: 'Carlos Pereira',
        area: 'Tecnologia',
        local: 'Remoto',
        notas:
            'Construção da nova experiência digital para clientes e parceiros.',
        pautas: [
          'Validar protótipo navegável',
          'Fechar escopo da primeira entrega',
          'Definir cronograma de homologação',
        ],
        tarefas: 36,
        tarefasConcluidas: 12,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Reunião de resultados',
        tipo: 'R',
        status: 'A',
        dataInicio: dia(3),
        dataFim: dia(3),
        horaInicio: '14:00',
        horaFim: '15:30',
        responsavel: 'Ana Souza',
        area: 'Financeiro',
        local: 'Sala de reuniões 2',
        notas:
            'Apresentação dos resultados financeiros e projeções do trimestre.',
        pautas: [
          'Resultado consolidado do mês',
          'Análise de desvios',
          'Projeções para o próximo trimestre',
        ],
        tarefas: 6,
        tarefasConcluidas: 2,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Ciclo de melhorias contínuas',
        tipo: 'C',
        status: 'R',
        dataInicio: dia(6),
        dataFim: dia(35),
        horaInicio: '09:00',
        horaFim: '18:00',
        responsavel: 'João Santos',
        area: 'Qualidade',
        local: 'Qualidade',
        notas:
            'Rascunho do ciclo de melhorias com foco em redução de retrabalho.',
        pautas: [
          'Mapear retrabalho por etapa',
          'Priorizar ações de curto prazo',
          'Definir responsáveis',
        ],
        tarefas: 18,
        tarefasConcluidas: 4,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Projeto Campanha de Inverno',
        tipo: 'P',
        status: 'A',
        dataInicio: dia(2),
        dataFim: dia(20),
        horaInicio: '10:00',
        horaFim: '17:00',
        responsavel: 'Mariana Lima',
        area: 'Marketing',
        local: 'Marketing',
        notas:
            'Campanha integrada de inverno com foco em conversão e retenção.',
        pautas: [
          'Aprovar conceito criativo',
          'Fechar mídia e cronograma',
          'Configurar acompanhamento de metas',
        ],
        tarefas: 14,
        tarefasConcluidas: 5,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Reunião de onboarding',
        tipo: 'R',
        status: 'E',
        dataInicio: dia(-8),
        dataFim: dia(-8),
        horaInicio: '10:00',
        horaFim: '11:00',
        responsavel: 'Carlos Pereira',
        area: 'Pessoas',
        local: 'Auditório',
        notas: 'Integração dos novos colaboradores com apresentação das áreas.',
        pautas: [
          'Boas-vindas',
          'Apresentação da cultura',
          'Tour pelas ferramentas internas',
        ],
        tarefas: 4,
        tarefasConcluidas: 4,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Ciclo de planejamento 2027',
        tipo: 'C',
        status: 'R',
        dataInicio: dia(12),
        dataFim: dia(42),
        horaInicio: '08:00',
        horaFim: '18:00',
        responsavel: 'Ana Souza',
        area: 'Diretoria',
        local: 'Sala de estratégia',
        notas: 'Construção do plano integrado para o próximo exercício.',
        pautas: [
          'Consolidar premissas econômicas',
          'Definir metas por área',
          'Revisar plano de investimentos',
        ],
        tarefas: 20,
        tarefasConcluidas: 1,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Projeto Automação de processos',
        tipo: 'P',
        status: 'A',
        dataInicio: dia(-3),
        dataFim: dia(30),
        horaInicio: '09:00',
        horaFim: '18:00',
        responsavel: 'João Santos',
        area: 'Tecnologia',
        local: 'Remoto',
        notas: 'Automação dos fluxos de aprovação e conferência de documentos.',
        pautas: [
          'Mapear processos candidatos',
          'Validar integrações necessárias',
          'Executar piloto com uma área',
        ],
        tarefas: 16,
        tarefasConcluidas: 7,
      ),
      Planejamento(
        id: _proximoId++,
        nome: 'Reunião de retrospectiva',
        tipo: 'R',
        status: 'A',
        dataInicio: dia(8),
        dataFim: dia(8),
        horaInicio: '16:00',
        horaFim: '17:00',
        responsavel: 'Mariana Lima',
        area: 'Produto',
        local: 'Sala de reuniões 3',
        notas: 'Retrospectiva do ciclo atual com identificação de melhorias.',
        pautas: [
          'O que funcionou bem',
          'O que pode melhorar',
          'Ações para o próximo ciclo',
        ],
        tarefas: 7,
        tarefasConcluidas: 3,
      ),
    ];

    _itens.addAll(seed);
  }
}
