import 'dart:io';

import 'package:cadastro_veiculos/conexao.dart';
import 'package:cadastro_veiculos/veiculos.dart';



String? _ler(String rotulo) {
  stdout.write('$rotulo: ');
  return stdin.readLineSync();
}


String? _lerTexto(String rotulo, int limite) {
  final texto = (_ler(rotulo) ?? '').trim();
  if (texto.isEmpty) {
    print('Erro: $rotulo não pode ser vazio.');
    return null;
  }
  if (texto.length > limite) {
    print('Erro: $rotulo deve ter no máximo $limite caracteres.');
    return null;
  }
  return texto;
}

int? _lerAno(String rotulo) {
  final ano = int.tryParse((_ler(rotulo) ?? '').trim());
  final limite = DateTime.now().year + 1; // ano atual + 1
  if (ano == null) {
    print('Erro: o ano deve ser um número inteiro.');
    return null;
  }
  if (ano < 1900 || ano > limite) {
    print('Erro: o ano deve estar entre 1900 e $limite.');
    return null;
  }
  return ano;
}

double? _lerValor(String rotulo) {
  final texto = (_ler(rotulo) ?? '').trim().replaceAll(',', '.');
  
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(texto)) {
    print('Erro: informe um número com até duas casas decimais '
        '(ex.: 65000,00), sem separador de milhar.');
    return null;
  }
  final valor = double.tryParse(texto);
  if (valor == null || !valor.isFinite || valor <= 0) {
    print('Erro: o valor deve ser maior que zero.');
    return null;
  }
  if (valor >= 10000000000) {
    print('Erro: o valor deve ser menor que 10000000000.');
    return null;
  }
  return valor;
}

int? _lerQuilometragem(String rotulo) {
  final km = int.tryParse((_ler(rotulo) ?? '').trim());
  if (km == null) {
    print('Erro: a quilometragem deve ser um número inteiro.');
    return null;
  }
  if (km < 0) {
    print('Erro: a quilometragem não pode ser negativa.');
    return null;
  }
  return km;
}

int? _lerId(String rotulo) {
  final id = int.tryParse((_ler(rotulo) ?? '').trim());
  if (id == null || id <= 0) {
    print('Erro: o ID deve ser um número inteiro positivo.');
    return null;
  }
  return id;
}



String _moeda(dynamic valor) =>
    'R\$ ${num.parse(valor.toString()).toStringAsFixed(2)}';

String _linha(Map<String, dynamic> v) =>
    'ID: ${v['id']} | ${v['marca']} ${v['modelo']} | Ano: ${v['ano']} | '
    'Valor: ${_moeda(v['valor'])} | Quilometragem: ${v['quilometragem']} km';



Future<void> _cadastrar(client) async {
  final marca = _lerTexto('Marca', 50);
  if (marca == null) return;
  final modelo = _lerTexto('Modelo', 100);
  if (modelo == null) return;
  final ano = _lerAno('Ano');
  if (ano == null) return;
  final valor = _lerValor('Valor');
  if (valor == null) return;
  final km = _lerQuilometragem('Quilometragem');
  if (km == null) return;

  final criado = await cadastrarVeiculo(client,
      marca: marca, modelo: modelo, ano: ano, valor: valor, quilometragem: km);
  print('Veículo cadastrado!');
  print(_linha(criado));
}

Future<void> _listar(client) async {
  final lista = await listarVeiculos(client);
  if (lista.isEmpty) {
    print('Nenhum veículo cadastrado.');
    return;
  }
  for (final v in lista) {
    print('ID: ${v['id']} | Marca: ${v['marca']} | Modelo: ${v['modelo']}');
    print('Ano: ${v['ano']} | Valor: ${_moeda(v['valor'])}');
    print('Quilometragem: ${v['quilometragem']} km');
    print('');
  }
}

Future<void> _atualizar(client) async {
  final id = _lerId('ID do veículo');
  if (id == null) return;
  final marca = _lerTexto('Nova marca', 50);
  if (marca == null) return;
  final modelo = _lerTexto('Novo modelo', 100);
  if (modelo == null) return;
  final ano = _lerAno('Novo ano');
  if (ano == null) return;
  final valor = _lerValor('Novo valor');
  if (valor == null) return;
  final km = _lerQuilometragem('Nova quilometragem');
  if (km == null) return;

  final atualizado = await atualizarVeiculo(client, id,
      marca: marca, modelo: modelo, ano: ano, valor: valor, quilometragem: km);
  if (atualizado == null) {
    print('Nenhum veículo encontrado com o ID $id.');
    return;
  }
  print('Veículo atualizado!');
  print(_linha(atualizado));
}

Future<void> _excluir(client) async {
  final id = _lerId('ID do veículo');
  if (id == null) return;

  final resposta = (_ler('Confirma a exclusão? S/N') ?? '').trim();
  if (resposta == 'N' || resposta == 'n') {
    print('Exclusão cancelada.');
    return;
  }
  if (resposta != 'S' && resposta != 's') {
    print('Resposta inválida. Exclusão não realizada.');
    return;
  }

  final removido = await excluirVeiculo(client, id);
  if (removido == null) {
    print('Nenhum veículo encontrado com o ID $id.');
    return;
  }
  print('Veículo excluído!');
  print('ID: ${removido['id']} | ${removido['marca']} ${removido['modelo']}');
}



Future<void> main() async {
  final client = conectar();
  try {
    while (true) {
      print('\nCADASTRO DE VEÍCULOS');
      print('1 - Cadastrar veículo');
      print('2 - Listar veículos');
      print('3 - Atualizar veículo');
      print('4 - Excluir veículo');
      print('0 - Sair');
      final opcao = _ler('O que deseja fazer?');

      if (opcao == null) break; // fim da entrada

      try {
        switch (opcao.trim()) {
          case '1':
            await _cadastrar(client);
            break;
          case '2':
            await _listar(client);
            break;
          case '3':
            await _atualizar(client);
            break;
          case '4':
            await _excluir(client);
            break;
          case '0':
            print('Sistema encerrado.');
            return;
          default:
            print('Opção inválida. Tente novamente.');
        }
      } catch (e) {
        print('Falha na operação: $e');
      }
    }
  } finally {
    client.dispose();
  }
}
