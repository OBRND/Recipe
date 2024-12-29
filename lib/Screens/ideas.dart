import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:meal/Models/decoration.dart';
import 'package:meal/Models/user_id.dart';
import 'package:meal/Screens/add_recipe.dart';
import 'package:provider/provider.dart';

import 'new_recipes.dart';

class IdeasTab extends StatefulWidget {
  const IdeasTab({super.key});

  @override
  State<IdeasTab> createState() => _IdeasTabState();
}

class _IdeasTabState extends State<IdeasTab> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin  {

  bool get wantKeepAlive => true; // Keeps the state alive
  final PageStorageBucket _bucket = PageStorageBucket();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = true;
  static const Color accentColor = Color(0xDBF32607);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Hide floating button when scrolling down
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showFloatingButton) {
        setState(() => _showFloatingButton = false);
      }
    } else {
      if (!_showFloatingButton) {
        setState(() => _showFloatingButton = true);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) =>
        [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            floating: true,
            pinned: true,
            title: const Text(
              'Recipe Ideas',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87),
                onPressed: () {
                  // Implement search functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.black87),
                onPressed: () {
                  // Implement filter functionality
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: accentColor,
              // unselectedLabelColor: Colors.grey[600],
              // indicatorColor: Colors.orange[700],
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'New & Trending'),
                Tab(text: 'Community Favorites'),
                Tab(text: 'Kid-Friendly'),
                Tab(text: 'Quick Meals'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildForYouTab(),
            _newTab(),
            _buildCommunityFavoritesTab(),
            _buildKidFriendlyTab(),
            _buildQuickMealsTab(),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFloatingButton ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFloatingButton ? 1 : 0,
          child: FloatingActionButton.extended(
            label: Container(
              width: 120,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  Text('Share recipe', style: TextStyle(
                      color: Colors.white
                  ),)
                ],
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddRecipeScreen()));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForYouTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWeeklyMealPlanCard(),
        const SizedBox(height: 24),
        _buildTrendingForYouSection(),
        const SizedBox(height: 24),
        _buildPersonalizedSuggestions(),
      ],
    );
  }

  Widget _buildWeeklyMealPlanCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [accentColor, Colors.orange[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week\'s Meal Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Personalized for your family',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to meal plan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('View Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingForYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending For You',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => _buildTrendingCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Healthy Salad Bowl',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '25 min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Based on Your Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all suggestions
              },
              child: Text(
                'See All',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) => _buildSuggestionCard({"name": 'Pizza'}),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(meal) {
      return InkWell(
        onTap: () {
        },
        child: Container(
          height: MediaQuery.sizeOf(context).width / 2.8,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Stack(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).width / 3.2,
                  child: Container(
                    decoration: boxDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width / 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                meal['name'],
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Perfect for family dinner',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 16,
                                      color: Colors.orange[700]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.8',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.timer_outlined,
                                      size: 16,
                                      color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '45 min',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  margin: EdgeInsets.all(0),
                  child: Container(
                    width: MediaQuery
                        .sizeOf(context)
                        .width / 2.8,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(
                          12)),
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(
                            'https://www.onehappydish.com/wp-content/uploads/2023/11/scrambled-eggs-with-cream-cheese-recipe.jpg'),
                      ),
                    ),
                  ),
                ),
              ]
          ),
        ),
      );

  }


  // Other tab building methods would follow similar patterns
  Widget _buildCommunityFavoritesTab() {
    return const Center(child: Text('Community Favorites'));
  }

  Widget _newTab() {
    final user = Provider.of<UserID>(context);

    return Center(child: NewRecipes(uid: user.uid));
  }

  Widget _buildKidFriendlyTab() {
    return const Center(child: Text('Kid-Friendly'));
  }

  Widget _buildQuickMealsTab() {
    return const Center(child: Text('Quick Meals'));
  }
}