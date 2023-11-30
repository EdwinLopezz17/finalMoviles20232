import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../db/FavoritesHelper.dart';

class SearchHero extends StatefulWidget {
  @override
  _SearchHero createState() => _SearchHero();
}

class _SearchHero extends State<SearchHero> {
  final TextEditingController _nameHero = TextEditingController();
  FavoritesHelper favoritesHelper = FavoritesHelper();
  List<Map<String, dynamic>> heroList = [];
  int resultCount =0;

  @override
  void initState() {
    super.initState();
    _loadResultCount();
  }

  Future<void> _loadResultCount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        resultCount = prefs.getInt('resultCount') ?? 0;
      });
    } catch (e) {
      print("Error loading result count: $e");
    }
  }

  Future<void> _saveResultCount(int count) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setInt('resultCount', (count + resultCount));
      _loadResultCount();
    } catch (e) {
      print("Error saving result count: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consulta SuperHéroe"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Result Count: $resultCount'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameHero,
              decoration: InputDecoration(
                labelText: 'Name of hero',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showHero();
              },
              child: Text('Search Hero'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: heroList.length,
                itemBuilder: (context, index) {
                  final hero = heroList[index];
                  return ListTile(
                    title: Text('Name: ${hero['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gender: ${hero['appearance']['gender']}'),
                        Text('Intelligence: ${hero['powerstats']['intelligence']}'),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(hero['image']['url']),
                    ),
                    trailing: FutureBuilder<bool>(
                      future: favoritesHelper.isFavorite(hero['name']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          bool isFavorite = snapshot.data ?? true;

                          return IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              _addToFavorite(hero);
                            },
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHero() async {
    final name = _nameHero.text;

    if (name != "") {
      final response = await http.get(Uri.parse(
          'https://www.superheroapi.com/api.php/10157703717092094/search/${name}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('results')) {
          setState(() {
            heroList = List<Map<String, dynamic>>.from(data['results']);
            resultCount = heroList.length;
            _saveResultCount(resultCount);
          });
        }
      } else {
        throw Exception('Failed to load heroes');
      }
    } else {
      print('Please enter a valid name');
    }
  }

  Future<void> _addToFavorite(Map<String, dynamic> hero) async {
    await favoritesHelper.addToFavorite(hero);
    await _showHero();
  }
}
