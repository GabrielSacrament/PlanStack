import 'package:flutter/material.dart';

import 'AppCores.dart';

class BotaoApp extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback? aoPressionar;
  final Color fundo;
  final Color corTexto;
  final BorderSide? borda;
  final bool carregando;
  final bool expandido;

  const BotaoApp.primario({
    super.key,
    required this.texto,
    this.icone,
    this.aoPressionar,
    this.carregando = false,
    this.expandido = false,
  }) : fundo = AppCores.verdeMarca,
       corTexto = Colors.white,
       borda = null;

  const BotaoApp.secundario({
    super.key,
    required this.texto,
    this.icone,
    this.aoPressionar,
    this.carregando = false,
    this.expandido = false,
  }) : fundo = Colors.white,
       corTexto = AppCores.textoPrimario,
       borda = const BorderSide(color: AppCores.formBorda);

  const BotaoApp.perigo({
    super.key,
    required this.texto,
    this.icone,
    this.aoPressionar,
    this.carregando = false,
    this.expandido = false,
  }) : fundo = AppCores.statusVermelhoTexto,
       corTexto = Colors.white,
       borda = null;

  @override
  Widget build(BuildContext context) {
    final conteudo = carregando
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icone != null) ...[
                Icon(icone, size: 18, color: corTexto),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );

    return SizedBox(
      height: 42,
      width: expandido ? double.infinity : null,
      child: ElevatedButton(
        onPressed: carregando ? null : aoPressionar,
        style: ElevatedButton.styleFrom(
          backgroundColor: fundo,
          foregroundColor: corTexto,
          disabledBackgroundColor: fundo.withValues(alpha: 0.6),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borda ?? BorderSide.none,
          ),
        ),
        child: conteudo,
      ),
    );
  }
}

class BotaoIconeApp extends StatelessWidget {
  final IconData icone;
  final String tooltip;
  final VoidCallback? aoPressionar;
  final Color cor;
  final double tamanho;

  const BotaoIconeApp({
    super.key,
    required this.icone,
    required this.tooltip,
    required this.aoPressionar,
    this.cor = AppCores.iconePadrao,
    this.tamanho = 18,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: aoPressionar,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: tamanho,
      color: cor,
      icon: Icon(icone),
    );
  }
}
