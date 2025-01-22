import 'package:flutter/material.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({Key? key}) : super(key: key);

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'distance';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> dummyRestaurants = [
    {
      'name': 'Halal Guys',
      'cuisine': 'Middle Eastern',
      'address': '123 Main St',
      'price': '\$',
      'distance': '0.8',
    },
    {
      'name': 'Kabab Express',
      'cuisine': 'Persian',
      'address': '456 Oak Ave',
      'price': '\$\$',
      'distance': '1.2',
    },
    {
      'name': 'Sultan\'s Kitchen',
      'cuisine': 'Turkish',
      'address': '789 Pine Rd',
      'price': '\$\$\$',
      'distance': '2.5',
    },
    {
      'name': 'Shawarma House',
      'cuisine': 'Lebanese',
      'address': '321 Elm St',
      'price': '\$',
      'distance': '0.5',
    },
    {
      'name': 'Biryani Corner',
      'cuisine': 'Indian',
      'address': '654 Maple Dr',
      'price': '\$\$',
      'distance': '1.8',
    },
    {
      'name': 'Hummus Palace',
      'cuisine': 'Mediterranean',
      'address': '987 Cedar Ln',
      'price': '\$\$\$',
      'distance': '3.0',
    },
    {
      'name': 'Falafel King',
      'cuisine': 'Middle Eastern',
      'address': '147 Birch Rd',
      'price': '\$',
      'distance': '1.5',
    },
    {
      'name': 'Tandoor Grill',
      'cuisine': 'Pakistani',
      'address': '258 Walnut St',
      'price': '\$\$',
      'distance': '2.2',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by distance'),
                onTap: () {
                  setState(() => _selectedFilter = 'distance');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Sort by price'),
                onTap: () {
                  setState(() => _selectedFilter = 'price');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Sort by ranking'),
                onTap: () {
                  setState(() => _selectedFilter = 'ranking');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Faves'),
              Tab(text: 'Explore'),
              Tab(text: 'Friend\'s Recs'),
            ],
            labelColor: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _showFilterOptions,
              child: Text('Filter by $_selectedFilter'),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(3, (index) {
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // Space for bottom navigation
                  itemCount: dummyRestaurants.length,
                  itemBuilder: (context, i) {
                    final restaurant = dummyRestaurants[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant['name']!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(restaurant['cuisine']!),
                                  Text(restaurant['address']!),
                                  Text(restaurant['price']!),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${restaurant['distance']} mi'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Take Me There!'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}