import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'Components/AppCores.dart';
import 'DadosFict.dart';
import 'Navegacao/AppShell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(const AppNap());
}

class AppNap extends StatelessWidget {
  const AppNap({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: DadosFict.instance,
      child: MaterialApp(
        title: 'NAP 1 - Desenvolvimento Web',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppCores.backgroundTela,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppCores.verdeMarca,
            primary: AppCores.verdeMarca,
            surface: Colors.white,
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppCores.verdeMarca,
            selectionColor: AppCores.verdeClaroBorda,
            selectionHandleColor: AppCores.verdeMarca,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppCores.formPreenchimento,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            hintStyle: const TextStyle(
              fontSize: 12,
              color: AppCores.iconeBusca,
            ),
            labelStyle: const TextStyle(
              fontSize: 12,
              color: AppCores.textoSecundario,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.formBorda),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.formBorda),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppCores.verdeMarca,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppCores.statusVermelhoTexto),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppCores.statusVermelhoTexto,
                width: 1.2,
              ),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: AppCores.tabelaBorda,
            thickness: 1,
            space: 1,
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}
