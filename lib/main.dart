// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Örneği',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  List<String> apiData = [];

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://45.141.150.134:3000/getUsers'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        apiData = data
            .map<String>((item) => '${item['username']} - ${item['email']}')
            .toList();
      });
    } else {
      throw Exception('API çağrısı başarısız oldu.');
    }
  }

  Future<void> postData() async {
    const String apiUrl = 'http://45.141.150.134:3000/addUser';
    final Map<String, dynamic> data = {
      "username": usernameController.text,
      "email": emailController.text,
    };

    bool userExists = apiData.any((item) =>
        item.contains(usernameController.text) &&
        item.contains(emailController.text));

    if (userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı zaten mevcut.'),
        ),
      );
    } else {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        fetchData();
        usernameController.clear();
        emailController.clear();
      } else {
        throw Exception('API çağrısı başarısız oldu.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Örneği'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                postData();
              },
              child: const Text('Kullanıcı Ekle'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: apiData.isEmpty
                  ? const CircularProgressIndicator()
                  : ListView.builder(
                      itemCount: apiData.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(apiData[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
