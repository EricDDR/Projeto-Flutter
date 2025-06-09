// Flutter: main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

// Widget principal do aplicativo
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Pets',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomePage(), // Tela inicial
    );
  }
}

// Tela inicial com listagem e busca de pets
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> pets = []; // Lista de pets recebida da API
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPets(); // Busca inicial de pets
  }

  // Função para buscar pets da API, com ou sem filtro por nome
  Future<void> fetchPets({String? query}) async {
    final uri = Uri.parse('http://localhost:8080/api/petcadastro')
        .replace(queryParameters: query != null ? {'nome': query} : null);

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json; charset=utf-8',
    });

    if (response.statusCode == 200) {
      setState(() {
        String data = utf8.decode(response.bodyBytes);
        pets = json.decode(data); // Atualiza lista com dados decodificados
      });
    } else {
      throw Exception('Falha ao carregar pets');
    }
  }

  // Navega para tela de cadastro ou edição
  void navigateToForm({Map<String, dynamic>? pet}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroPetPage(pet: pet)),
    );
    if (result == true) {
      fetchPets(); // Recarrega lista após cadastro/edição
    }
  }

  // Função para deletar um pet via API
  Future<void> deletePet(String id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/petcadastro/$id'),
    );

    if (response.statusCode == 200) {
      fetchPets(); // Atualiza lista após exclusão
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erro'),
          content: Text('Não foi possível excluir o pet.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pets Cadastrados')),
      body: Column(
        children: [
          // Campo de busca por nome
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => fetchPets(query: _searchController.text),
                ),
              ),
            ),
          ),
          // Lista de pets
          Expanded(
            child: ListView.separated(
              itemCount: pets.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (context, index) {
                final pet = pets[index];
                return ListTile(
                  title: Text(pet['nomeAnimal']),
                  subtitle: Text('Raça: ${pet['raca']} | Dono: ${pet['numeroDono']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => navigateToForm(pet: pet)),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => deletePet(pet['id'])),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botão para cadastrar novo pet
      floatingActionButton: SizedBox(
        width: 160,
        height: 50,
        child: ElevatedButton(
          onPressed: () => navigateToForm(),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.teal,
          ),
          child: Text('Pet Cadastro', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}

// Tela de cadastro/edição de pets
class CadastroPetPage extends StatefulWidget {
  final Map<String, dynamic>? pet;
  CadastroPetPage({this.pet});
  @override
  _CadastroPetPageState createState() => _CadastroPetPageState();
}

class _CadastroPetPageState extends State<CadastroPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _numeroDonoController = TextEditingController();
  List<String> racas = [];
  String? selectedRaca;

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nomeController.text = widget.pet!['nomeAnimal'];
      _numeroDonoController.text = widget.pet!['numeroDono'];
      selectedRaca = widget.pet!['raca'];
    }
    fetchDogBreeds(); // Busca raças da API externa
  }

  // Função para buscar raças da API dog.ceo
  Future<void> fetchDogBreeds() async {
    final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        racas = (data['message'] as Map).keys.cast<String>().toList();
      });
    }
  }

  // Função para salvar (cadastrar ou editar) pet
  Future<void> salvarPet() async {
    final petData = {
      'nomeAnimal': _nomeController.text,
      'raca': selectedRaca,
      'numeroDono': _numeroDonoController.text,
    };

    final url = widget.pet == null
        ? 'http://localhost:8080/api/petcadastro'
        : 'http://localhost:8080/api/petcadastro/${widget.pet!['id']}';

    final response = await (widget.pet == null
        ? http.post(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: json.encode(petData))
        : http.put(Uri.parse(url), headers: {'Content-Type': 'application/json'}, body: json.encode(petData)));

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erro'),
          content: Text('Erro ao salvar o pet'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet == null ? 'Cadastrar Pet' : 'Editar Pet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome do Animal'),
                validator: (value) => value!.isEmpty ? 'Informe o nome do animal' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedRaca,
                items: racas.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => selectedRaca = val),
                decoration: InputDecoration(labelText: 'Raça'),
                validator: (value) => value == null ? 'Selecione uma raça' : null,
              ),
              TextFormField(
                controller: _numeroDonoController,
                decoration: InputDecoration(labelText: 'Número do Dono'),
                validator: (value) => value!.isEmpty ? 'Informe o número do dono' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) salvarPet();
                },
                child: Text(widget.pet == null ? 'Cadastrar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
