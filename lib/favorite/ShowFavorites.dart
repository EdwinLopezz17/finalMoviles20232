import 'package:flutter/material.dart';

import '../db/FavoritesHelper.dart';

class ShowFavorites extends StatefulWidget {
  @override
  _ShowFavorites createState() => _ShowFavorites();
}

class _ShowFavorites extends State<ShowFavorites> {
  List<Map<String, dynamic>> favoritesList = [];
  FavoritesHelper favoritesHelper = FavoritesHelper();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await favoritesHelper.getFavorites();
    setState(() {
      favoritesList = List<Map<String, dynamic>>.from(favorites);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listado SuperHéroes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: favoritesList.isEmpty
            ? Center(
          child: Text("There are no favorite heroes."),
        )
            : ListView.builder(
          itemCount: favoritesList.length,
          itemBuilder: (context, index) {
            final hero = favoritesList[index];
            return ListTile(
              title: Text(
                'Name: ${hero['name']}',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gender: ${hero['gender']}'),
                  Text('Género: ${hero['intelligence']}'),
                ],
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(hero['image']),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteFromFavorites(hero['id']);
                },
              ),
            );
          },
        ),
      ),
    );
  }
  void _deleteFromFavorites(int id) async {
    await favoritesHelper.deleteFromFavorites(id);
    _loadFavorites();
  }

}

