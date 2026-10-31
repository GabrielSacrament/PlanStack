import 'package:flutter/material.dart';

import 'AppCores.dart';
import 'botao_app.dart';

Future<bool> confirmarExclusao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppCores.backgroundDialog,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppCores.statusVermelhoTexto,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppCores.textoPrimario,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          mensagem,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppCores.textoSecundario,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppCores.textoSecundario),
            ),
          ),
          BotaoApp.perigo(
            texto: 'Excluir',
            icone: Icons.delete_outline_rounded,
            aoPressionar: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  );

  return resultado ?? false;
}
