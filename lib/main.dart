import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: Colors.black,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            )),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
        ),
        cardColor: Colors.orange[50],
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> recipes = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isSearchActive = false;
  bool isFilterFavoritesActive = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? recipeString = prefs.getString('recipes');
    recipes = List<Map<String, dynamic>>.from(json.decode(recipeString!));

    setState(() {
      for (var recipe in recipes) {
        if (recipe['isFavorite'] is! bool) {
          recipe['isFavorite'] = recipe['isFavorite'] == 'true';
        }
      }
    });
  }

  Future<void> _saveRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('recipes', json.encode(recipes));
  }

  void _addRecipe(Map<String, dynamic> recipe) {
    setState(() {
      recipes.add(recipe);
      _saveRecipes();
    });
  }

  void _togglefavorites(int index) {
    setState(() {
      bool currentValue = recipes[index]['isFavorite'] as bool;
      recipes[index]['isFavorite'] = !currentValue;
      _saveRecipes();
    });
  }

  List<Map<String, dynamic>> _buildFilteredRecipes() {
    List<Map<String, dynamic>> filteredRecipes = recipes.where((recipe) {
      final title = recipe['title']?.toLowerCase() ?? '';
      return title.contains(searchQuery);
    }).toList();

    if (isFilterFavoritesActive) {
      filteredRecipes = filteredRecipes
          .where((recipe) => recipe['isFavorite'] as bool)
          .toList();
    }

    return filteredRecipes;
  }

  void _toggleFilterFavorites() {
    setState(() {
      isFilterFavoritesActive = !isFilterFavoritesActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Row(
                children: [
                  if (!isSearchActive) ...[
                    const Text(
                      'Recipes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {
                        setState(() {
                          isSearchActive = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      tooltip: 'View Favorites',
                      onPressed: () {
                        final favoriteRecipes = recipes
                            .where((recipe) => recipe['isFavorite'] as bool)
                            .toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FavoritesPage(favoriteRecipes: favoriteRecipes),
                          ),
                        );
                      },
                    ),
                  ],
                  if (isSearchActive) ...[
                    SizedBox(
                      width: constraints.maxWidth - 56,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Stack(
                          children: [
                            TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.white70),
                              ),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                            if (searchQuery.isNotEmpty)
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.clear),
                                  tooltip: 'Clear Search',
                                  onPressed: () {
                                    setState(() {
                                      searchController.clear();
                                      searchQuery = '';
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          isSearchActive = false;
                          searchController.clear();
                          searchQuery = '';
                        });
                      },
                    ),
                  ],
                ],
              );
            } else {
              return Row(
                children: [
                  const Text(
                    'Recipes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 300,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search recipes...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value.toLowerCase();
                              });
                            },
                          ),
                          if (searchQuery.isNotEmpty)
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: 'Clear Search',
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    searchQuery = '';
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.filter_alt,
                      color: isFilterFavoritesActive
                          ? Colors.brown[600]
                          : Colors.white,
                    ),
                    tooltip: 'Filter by Favorites',
                    onPressed: () {
                      _toggleFilterFavorites();
                    },
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Tooltip(
                    message: 'View Favorites',
                    child: TextButton.icon(
                      onPressed: () {
                        final favoriteRecipes = recipes
                            .where((recipe) => recipe['isFavorite'] as bool)
                            .toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FavoritesPage(favoriteRecipes: favoriteRecipes),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Favorites',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent[700],
                        padding: const EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _buildFilteredRecipes().length,
              itemBuilder: (context, index) {
                final filteredRecipes = _buildFilteredRecipes();
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    hoverColor: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.orange.withOpacity(0.3),
                    highlightColor: Colors.orange.withOpacity(0.1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailPage(recipe: filteredRecipes[index]),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filteredRecipes[index]['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  filteredRecipes[index]['description']!,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              filteredRecipes[index]['isFavorite'] as bool
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  filteredRecipes[index]['isFavorite'] as bool
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                            tooltip:
                                filteredRecipes[index]['isFavorite'] as bool
                                    ? 'Remove from Favorites'
                                    : 'Add to Favorites',
                            onPressed: () {
                              _togglefavorites(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add New Recipe',
        child: const Icon(Icons.add),
        onPressed: () async {
          final newRecipe = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipePage()),
          );
          if (newRecipe != null) {
            _addRecipe(newRecipe);
          }
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe['title']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              recipe['description']!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AddRecipePage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  AddRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final title = titleController.text;
                  final description = descriptionController.text;
                  if (title.isNotEmpty && description.isNotEmpty) {
                    Navigator.pop(context, {
                      'title': title,
                      'description': description,
                      'isFavorite': false,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Save Recipe'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<Map<String, dynamic>> favoriteRecipes;

  const FavoritesPage({super.key, required this.favoriteRecipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoriteRecipes.isEmpty
          ? const Center(
              child: Text(
                'No favorite recipes yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                const SizedBox(
                  height: 16.0,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: favoriteRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = favoriteRecipes[index];
                        return Card(
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          child: ListTile(
                            title: Text(
                              recipe['title'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              recipe['description'],
                            ),
                            trailing: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailPage(recipe: recipe)));
                            },
                          ),
                        );
                      }),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Go to Home',
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
