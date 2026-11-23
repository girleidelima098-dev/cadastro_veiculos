import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';


SupabaseClient conectar() {
  final env = DotEnv()..load();
  final url = env['SUPABASE_URL'];
  final chave = env['SUPABASE_PUBLISHABLE_KEY'];

  if (url == null || url.isEmpty || chave == null || chave.isEmpty) {
    throw Exception(
        'Defina SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY no arquivo .env.');
  }
  return SupabaseClient(url, chave);
}
