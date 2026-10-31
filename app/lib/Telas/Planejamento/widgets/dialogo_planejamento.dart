import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Components/AppCores.dart';
import '../../../Components/botao_app.dart';
import '../../../DadosFict.dart';

Future<Planejamento?> abrirDialogoPlanejamento(
  BuildContext context, {
  Planejamento? inicial,
}) {
  return showDialog<Planejamento>(
    context: context,
    barrierDismissible: false,
    builder: (_) => DialogoPlanejamento(inicial: inicial),
  );
}

class DialogoPlanejamento extends StatefulWidget {
  final Planejamento? inicial;

  const DialogoPlanejamento({super.key, this.inicial});

  @override
  State<DialogoPlanejamento> createState() => _DialogoPlanejamentoState();
}

class _DialogoPlanejamentoState extends State<DialogoPlanejamento> {
  final _formKey = GlobalKey<FormState>();
  final _dataFormatada = DateFormat('dd/MM/yyyy');

  late final TextEditingController _ctrlNome;
  late final TextEditingController _ctrlResponsavel;
  late final TextEditingController _ctrlArea;
  late final TextEditingController _ctrlLocal;
  late final TextEditingController _ctrlDataInicio;
  late final TextEditingController _ctrlDataFim;
  late final TextEditingController _ctrlHoraInicio;
  late final TextEditingController _ctrlHoraFim;
  late final TextEditingController _ctrlPautas;
  late final TextEditingController _ctrlNotas;
  late final TextEditingController _ctrlTarefas;
  late final TextEditingController _ctrlConcluidas;

  late String _tipo;
  late String _status;

  @override
  void initState() {
    super.initState();
    final item = widget.inicial;
    final hoje = DateTime.now();

    _ctrlNome = TextEditingController(text: item?.nome ?? '');
    _ctrlResponsavel = TextEditingController(text: item?.responsavel ?? '');
    _ctrlArea = TextEditingController(text: item?.area ?? '');
    _ctrlLocal = TextEditingController(text: item?.local ?? '');
    _ctrlDataInicio = TextEditingController(
      text: _dataFormatada.format(item?.dataInicio ?? hoje),
    );
    _ctrlDataFim = TextEditingController(
      text: _dataFormatada.format(item?.dataFim ?? hoje),
    );
    _ctrlHoraInicio = TextEditingController(text: item?.horaInicio ?? '09:00');
    _ctrlHoraFim = TextEditingController(text: item?.horaFim ?? '10:00');
    _ctrlPautas = TextEditingController(text: item?.pautas.join('\n') ?? '');
    _ctrlNotas = TextEditingController(text: item?.notas ?? '');
    _ctrlTarefas = TextEditingController(text: (item?.tarefas ?? 0).toString());
    _ctrlConcluidas = TextEditingController(
      text: (item?.tarefasConcluidas ?? 0).toString(),
    );
    _tipo = item?.tipo ?? 'R';
    _status = item?.status ?? 'R';
  }

  @override
  void dispose() {
    _ctrlNome.dispose();
    _ctrlResponsavel.dispose();
    _ctrlArea.dispose();
    _ctrlLocal.dispose();
    _ctrlDataInicio.dispose();
    _ctrlDataFim.dispose();
    _ctrlHoraInicio.dispose();
    _ctrlHoraFim.dispose();
    _ctrlPautas.dispose();
    _ctrlNotas.dispose();
    _ctrlTarefas.dispose();
    _ctrlConcluidas.dispose();
    super.dispose();
  }

  DateTime? _lerData(String valor) {
    try {
      return _dataFormatada.parseStrict(valor);
    } catch (_) {
      return null;
    }
  }

  Future<void> _escolherData(
    TextEditingController controller, {
    DateTime? inicial,
  }) async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _lerData(controller.text) ?? inicial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecionar data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (escolhida != null) {
      controller.text = _dataFormatada.format(escolhida);
      setState(() {});
    }
  }

  Future<void> _escolherHora(TextEditingController controller) async {
    final partes = controller.text.split(':');
    final horaInicial = int.tryParse(partes.isNotEmpty ? partes[0] : '') ?? 9;
    final minutoInicial = int.tryParse(partes.length > 1 ? partes[1] : '') ?? 0;

    final escolhida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: horaInicial, minute: minutoInicial),
      helpText: 'Selecionar horário',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (escolhida != null) {
      controller.text =
          '${escolhida.hour.toString().padLeft(2, '0')}:${escolhida.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final inicio = _lerData(_ctrlDataInicio.text) ?? DateTime.now();
    var fim = _lerData(_ctrlDataFim.text) ?? inicio;
    if (fim.isBefore(inicio)) fim = inicio;

    final tarefas = int.tryParse(_ctrlTarefas.text.trim()) ?? 0;
    final concluidas = int.tryParse(_ctrlConcluidas.text.trim()) ?? 0;

    final pautas = _ctrlPautas.text
        .split('\n')
        .map((linha) => linha.trim())
        .where((linha) => linha.isNotEmpty)
        .toList();

    final item = Planejamento(
      id: widget.inicial?.id ?? 0,
      nome: _ctrlNome.text.trim(),
      tipo: _tipo,
      status: _status,
      dataInicio: inicio,
      dataFim: fim,
      horaInicio: _ctrlHoraInicio.text.trim(),
      horaFim: _ctrlHoraFim.text.trim(),
      responsavel: _ctrlResponsavel.text.trim(),
      area: _ctrlArea.text.trim(),
      local: _ctrlLocal.text.trim(),
      notas: _ctrlNotas.text.trim(),
      pautas: pautas,
      tarefas: math.max(0, tarefas),
      tarefasConcluidas: math.max(
        0,
        math.min(concluidas, math.max(0, tarefas)),
      ),
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.sizeOf(context);
    final largura = math.min(780.0, tamanho.width - 40);
    final altura = math.min(720.0, tamanho.height - 40);

    return Dialog(
      backgroundColor: AppCores.backgroundDialog,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: largura,
        height: altura,
        child: Column(
          children: [
            _cabecalho(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final duasColunas = constraints.maxWidth >= 600;
                      final larguraCampo = duasColunas
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;

                      Widget campo(Widget child) {
                        return SizedBox(width: larguraCampo, child: child);
                      }

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          campo(
                            TextFormField(
                              controller: _ctrlNome,
                              decoration: const InputDecoration(
                                labelText: 'Nome do planejamento *',
                                hintText: 'Ex.: Reunião de alinhamento semanal',
                                prefixIcon: Icon(Icons.title_rounded, size: 18),
                              ),
                              validator: (valor) {
                                if (valor == null || valor.trim().isEmpty) {
                                  return 'Informe o nome';
                                }
                                return null;
                              },
                            ),
                          ),
                          campo(
                            DropdownButtonFormField<String>(
                              initialValue: _tipo,
                              decoration: const InputDecoration(
                                labelText: 'Tipo *',
                                prefixIcon: Icon(
                                  Icons.category_outlined,
                                  size: 18,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'R',
                                  child: Text('Reunião'),
                                ),
                                DropdownMenuItem(
                                  value: 'C',
                                  child: Text('Ciclo'),
                                ),
                                DropdownMenuItem(
                                  value: 'P',
                                  child: Text('Projeto'),
                                ),
                              ],
                              onChanged: (valor) {
                                if (valor != null) {
                                  setState(() => _tipo = valor);
                                }
                              },
                            ),
                          ),
                          campo(
                            DropdownButtonFormField<String>(
                              initialValue: _status,
                              decoration: const InputDecoration(
                                labelText: 'Situação *',
                                prefixIcon: Icon(Icons.flag_outlined, size: 18),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'R',
                                  child: Text('Rascunho'),
                                ),
                                DropdownMenuItem(
                                  value: 'A',
                                  child: Text('Ativo'),
                                ),
                                DropdownMenuItem(
                                  value: 'E',
                                  child: Text('Encerrado'),
                                ),
                              ],
                              onChanged: (valor) {
                                if (valor != null) {
                                  setState(() => _status = valor);
                                }
                              },
                            ),
                          ),
                          campo(
                            TextFormField(
                              controller: _ctrlResponsavel,
                              decoration: const InputDecoration(
                                labelText: 'Responsável *',
                                hintText: 'Nome do responsável',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                ),
                              ),
                              validator: (valor) {
                                if (valor == null || valor.trim().isEmpty) {
                                  return 'Informe o responsável';
                                }
                                return null;
                              },
                            ),
                          ),
                          campo(
                            TextFormField(
                              controller: _ctrlArea,
                              decoration: const InputDecoration(
                                labelText: 'Área *',
                                hintText: 'Ex.: Operações',
                                prefixIcon: Icon(
                                  Icons.work_outline_rounded,
                                  size: 18,
                                ),
                              ),
                              validator: (valor) {
                                if (valor == null || valor.trim().isEmpty) {
                                  return 'Informe a área';
                                }
                                return null;
                              },
                            ),
                          ),
                          campo(
                            TextFormField(
                              controller: _ctrlLocal,
                              decoration: const InputDecoration(
                                labelText: 'Local',
                                hintText: 'Sala, link ou cidade',
                                prefixIcon: Icon(
                                  Icons.place_outlined,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          campo(
                            _CampoData(
                              controller: _ctrlDataInicio,
                              label: 'Data de início *',
                              aoTocar: () => _escolherData(
                                _ctrlDataInicio,
                                inicial: _lerData(_ctrlDataFim.text),
                              ),
                              validator: (valor) {
                                if (_lerData(valor ?? '') == null) {
                                  return 'Data inválida';
                                }
                                return null;
                              },
                            ),
                          ),
                          campo(
                            _CampoData(
                              controller: _ctrlDataFim,
                              label: 'Data de término *',
                              aoTocar: () => _escolherData(
                                _ctrlDataFim,
                                inicial: _lerData(_ctrlDataInicio.text),
                              ),
                              validator: (valor) {
                                final fim = _lerData(valor ?? '');
                                if (fim == null) return 'Data inválida';
                                final inicio = _lerData(_ctrlDataInicio.text);
                                if (inicio != null && fim.isBefore(inicio)) {
                                  return 'Deve ser após o início';
                                }
                                return null;
                              },
                            ),
                          ),
                          campo(
                            _CampoHora(
                              controller: _ctrlHoraInicio,
                              label: 'Hora de início',
                              aoTocar: () => _escolherHora(_ctrlHoraInicio),
                            ),
                          ),
                          campo(
                            _CampoHora(
                              controller: _ctrlHoraFim,
                              label: 'Hora de término',
                              aoTocar: () => _escolherHora(_ctrlHoraFim),
                            ),
                          ),
                          campo(
                            TextFormField(
                              controller: _ctrlTarefas,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Tarefas previstas',
                                prefixIcon: Icon(
                                  Icons.checklist_rounded,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          campo(
                            TextFormField(
                              controller: _ctrlConcluidas,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Tarefas concluídas',
                                prefixIcon: Icon(
                                  Icons.task_alt_rounded,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          campo(
                            TextFormField(
                              controller: _ctrlPautas,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Pautas',
                                hintText: 'Uma pauta por linha',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(
                                  Icons.format_list_bulleted,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          campo(
                            TextFormField(
                              controller: _ctrlNotas,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Notas',
                                hintText: 'Observações gerais do planejamento',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.notes_rounded, size: 18),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppCores.textoSecundario),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BotaoApp.primario(
                    texto: widget.inicial == null
                        ? 'Criar planejamento'
                        : 'Salvar alterações',
                    icone: widget.inicial == null
                        ? Icons.add_rounded
                        : Icons.save_outlined,
                    aoPressionar: _salvar,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    final editando = widget.inicial != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 16, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppCores.verdeClaro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              editando ? Icons.edit_calendar_outlined : Icons.add_task_rounded,
              color: AppCores.verdeMarca,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editando ? 'Editar planejamento' : 'Novo planejamento',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppCores.textoPrimario,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Preencha as informações abaixo. Os dados ficam apenas em memória.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppCores.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Fechar',
            icon: const Icon(
              Icons.close_rounded,
              color: AppCores.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoData extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback aoTocar;
  final String? Function(String?)? validator;

  const _CampoData({
    required this.controller,
    required this.label,
    required this.aoTocar,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: aoTocar,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.event_outlined, size: 18),
        suffixIcon: IconButton(
          onPressed: aoTocar,
          tooltip: 'Selecionar data',
          icon: const Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: AppCores.iconeBusca,
          ),
        ),
      ),
    );
  }
}

class _CampoHora extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback aoTocar;

  const _CampoHora({
    required this.controller,
    required this.label,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: aoTocar,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.schedule_rounded, size: 18),
        suffixIcon: IconButton(
          onPressed: aoTocar,
          tooltip: 'Selecionar horário',
          icon: const Icon(
            Icons.access_time_rounded,
            size: 16,
            color: AppCores.iconeBusca,
          ),
        ),
      ),
    );
  }
}
