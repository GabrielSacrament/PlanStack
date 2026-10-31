import 'package:flutter/material.dart';

import '../Components/AppCores.dart';

class BarraSuperior extends StatelessWidget {
  final int indiceAtual;
  final String? detalhe;

  const BarraSuperior({super.key, required this.indiceAtual, this.detalhe});

  @override
  Widget build(BuildContext context) {
    final partes = _partes();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 560;

        return Container(
          height: 60,
          color: AppCores.backgroundAppBar,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                indiceAtual == 0
                    ? Icons.home_outlined
                    : indiceAtual == 1
                    ? Icons.event_note_outlined
                    : Icons.calendar_month_outlined,
                size: 18,
                color: AppCores.verdeMarca,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var i = 0; i < partes.length; i++) ...[
                      if (i > 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppCores.iconeBusca,
                          ),
                        ),
                      Text(
                        partes[i],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: i == partes.length - 1
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: i == partes.length - 1
                              ? AppCores.textoPrimario
                              : AppCores.textoSecundario,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!compacto) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppCores.verdeClaro,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppCores.verdeClaroBorda),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storage_outlined,
                        size: 14,
                        color: AppCores.verdeMarca,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Dados fictícios',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppCores.verdeMarca,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
              ],
              const CircleAvatar(
                radius: 17,
                backgroundColor: AppCores.verdeMarca,
                child: Text(
                  'GBS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _partes() {
    switch (indiceAtual) {
      case 1:
        return const ['Tarefas', 'Planejamentos'];
      case 2:
        if (detalhe != null && detalhe!.isNotEmpty) {
          return ['Tarefas', 'Agenda', detalhe!];
        }
        return const ['Tarefas', 'Agenda'];
      default:
        return const ['Início'];
    }
  }
}
