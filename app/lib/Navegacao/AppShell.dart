import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Components/AppCores.dart';
import '../DadosFict.dart';
import '../Telas/Inicio/TelaInicio.dart';
import '../Telas/Planejamento/TelaAgenda.dart';
import '../Telas/Planejamento/TelaPlanejamentos.dart';
import 'BarraLateral.dart';
import 'BarraSuperior.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indice = 0;
  int? _planejamentoSelecionado;

  void _selecionar(int indice, {int? planejamentoId}) {
    setState(() {
      _indice = indice;
      _planejamentoSelecionado = planejamentoId;
    });
  }

  String? get _detalheAtual {
    final id = _planejamentoSelecionado;
    if (id == null) return null;
    return context.read<DadosFict>().buscarPorId(id)?.nome;
  }

  Widget _conteudo() {
    switch (_indice) {
      case 1:
        return TelaPlanejamentos(
          aoAbrirAgenda: (id) => _selecionar(2, planejamentoId: id),
        );
      case 2:
        return TelaAgenda(
          key: ValueKey('agenda-${_planejamentoSelecionado ?? 0}'),
          planejamentoId: _planejamentoSelecionado,
          aoAbrirPlanejamento: (id) => _selecionar(2, planejamentoId: id),
          aoLimparSelecao: () => _selecionar(2),
        );
      default:
        return const TelaInicio();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.backgroundTela,
      body: Row(
        children: [
          BarraLateral(
            indiceAtual: _indice,
            aoSelecionar: (indice) => _selecionar(indice),
          ),
          Expanded(
            child: Column(
              children: [
                BarraSuperior(indiceAtual: _indice, detalhe: _detalheAtual),
                Expanded(
                  child: Container(
                    color: AppCores.backgroundTela,
                    child: _conteudo(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
