import 'package:flutter/material.dart';

import '../Components/AppCores.dart';
import '../Components/botao_app.dart';

class BarraLateral extends StatefulWidget {
  final int indiceAtual;
  final ValueChanged<int> aoSelecionar;

  const BarraLateral({
    super.key,
    required this.indiceAtual,
    required this.aoSelecionar,
  });

  @override
  State<BarraLateral> createState() => _BarraLateralState();
}

class _BarraLateralState extends State<BarraLateral> {
  bool _expandida = true;
  bool _mouseNoCabecalho = false;

  @override
  Widget build(BuildContext context) {
    final telaEstreita = MediaQuery.sizeOf(context).width < 820;
    final expandida = _expandida && !telaEstreita;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeInOut,
        width: expandida ? 215 : 72,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppCores.menuFundo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppCores.menuBorda, width: 0.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _cabecalho(expandida, telaEstreita),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (expandida)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(22, 4, 22, 8),
                        child: Text(
                          'MENU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: AppCores.iconeBusca,
                          ),
                        ),
                      ),
                    _itemMenu(
                      indice: 0,
                      icone: Icons.home_outlined,
                      rotulo: 'Início',
                      expandida: expandida,
                    ),
                    _itemMenu(
                      indice: 1,
                      icone: Icons.event_note_outlined,
                      rotulo: 'Planejamentos',
                      expandida: expandida,
                    ),
                    _itemMenu(
                      indice: 2,
                      icone: Icons.calendar_month_outlined,
                      rotulo: 'Agenda',
                      expandida: expandida,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  expandida ? 'Versão 2026.10.001' : 'v.001',
                  style: const TextStyle(
                    color: AppCores.cinzaEscuro,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(bool expandida, bool telaEstreita) {
    if (expandida) {
      return SizedBox(
        height: 34,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 28),
                  child: Image.asset(
                    'assets/Logo/PlanStack_Logo200x51.png',
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: BotaoIconeApp(
                    icone: Icons.arrow_left,
                    tooltip: 'Recolher menu',
                    cor: AppCores.cinzaEscuro,
                    tamanho: 22,
                    aoPressionar: () => setState(() => _expandida = false),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _mouseNoCabecalho = true),
      onExit: (_) => setState(() => _mouseNoCabecalho = false),
      child: InkWell(
        onTap: telaEstreita ? null : () => setState(() => _expandida = true),
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _mouseNoCabecalho && !telaEstreita ? 0 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/Isotipo/IsotipoPT30.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (!telaEstreita)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _mouseNoCabecalho ? 1 : 0,
                    child: const Icon(
                      Icons.arrow_right,
                      size: 30,
                      color: AppCores.cinzaEscuro,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemMenu({
    required int indice,
    required IconData icone,
    required String rotulo,
    required bool expandida,
  }) {
    final selecionado = widget.indiceAtual == indice;

    final conteudo = InkWell(
      onTap: () => widget.aoSelecionar(indice),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.symmetric(
          horizontal: expandida ? 8 : 6,
          vertical: 3,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: expandida ? 6 : 0,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selecionado ? AppCores.menuSelecionado : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: selecionado
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, 3),
              blurRadius: 7,
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: expandida
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              child: Center(
                child: Icon(
                  icone,
                  size: 18,
                  color: selecionado ? AppCores.verdeMarca : AppCores.iconePadrao,
                ),
              ),
            ),
            if (expandida) ...[
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  rotulo,
                  style: TextStyle(
                    color: AppCores.textoPrimario,
                    fontSize: 12,
                    fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selecionado) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppCores.verdeMarca,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );

    if (expandida) return conteudo;

    return Tooltip(
      message: rotulo,
      waitDuration: const Duration(milliseconds: 250),
      child: conteudo,
    );
  }
}