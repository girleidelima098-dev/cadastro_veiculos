import 'package:supabase/supabase.dart';

const _tabela = 'veiculos';


Future<Map<String, dynamic>> cadastrarVeiculo(
  SupabaseClient cliente, {
  required String marca,
  required String modelo,
  required int ano,
  required double valor,
  required int quilometragem,
}) async {
  return await cliente
      .from(_tabela)
      .insert({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'valor': valor,
        'quilometragem': quilometragem,
      })
      .select()
      .single();
}


Future<List<Map<String, dynamic>>> listarVeiculos(SupabaseClient cliente) async {
  final dados = await cliente.from(_tabela).select().order('id');
  return List<Map<String, dynamic>>.from(dados);
}


Future<Map<String, dynamic>?> atualizarVeiculo(
  SupabaseClient cliente,
  int id, {
  required String marca,
  required String modelo,
  required int ano,
  required double valor,
  required int quilometragem,
}) async {
  final dados = await cliente
      .from(_tabela)
      .update({
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
        'valor': valor,
        'quilometragem': quilometragem,
      })
      .eq('id', id)
      .select();
  return dados.isEmpty ? null : Map<String, dynamic>.from(dados.first);
}


Future<Map<String, dynamic>?> excluirVeiculo(
    SupabaseClient cliente, int id) async {
  final dados = await cliente.from(_tabela).delete().eq('id', id).select();
  return dados.isEmpty ? null : Map<String, dynamic>.from(dados.first);
}
