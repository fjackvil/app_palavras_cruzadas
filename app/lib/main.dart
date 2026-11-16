import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'dados/banco.dart';
import 'dominio/tema.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CruzaLetraApp(banco: Banco(), temas: RepositorioTemas()));
}
