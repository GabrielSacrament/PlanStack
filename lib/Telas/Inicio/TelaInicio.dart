import 'dart:math' as math;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../../Components/AppCores.dart';

class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
  bool _mostrarTextoAnimado = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _mostrarTextoAnimado = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lado = math.min(
          850.0,
          math.min(constraints.maxWidth * 0.74, constraints.maxHeight * 0.82),
        );

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seja bem-vindo(a) ao BSCSuite!',
                    style: TextStyle(
                      letterSpacing: 2.2,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppCores.textoPrimario,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.airplay,
                        size: 15,
                        color: AppCores.textoSecundario,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _mostrarTextoAnimado
                            ? AnimatedTextKit(
                                isRepeatingAnimation: true,
                                pause: const Duration(milliseconds: 1400),
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'Seu Hub de gestão estratégica. O que faremos hoje?',
                                    textStyle: const TextStyle(
                                      letterSpacing: 2.4,
                                      fontSize: 14,
                                      color: AppCores.textoSecundario,
                                    ),
                                    speed: const Duration(milliseconds: 50),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _selo('Planejamento', Icons.event_note_outlined),
                      _selo('Agenda integrada', Icons.calendar_month_outlined),
                      _selo('Dados fictícios', Icons.storage_outlined),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Image.asset(
                      'assets/tudoconecta.png',
                      width: lado,
                      height: lado,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _selo(String texto, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppCores.tabelaBorda),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: AppCores.verdeMarca),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppCores.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
