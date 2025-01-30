import 'package:flutter/material.dart';
import 'package:meal/Screens/recipes/recipes.dart';
import 'package:meal/Theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../Models/connection.dart';
import '../Models/user_id.dart';
import 'connectivity_scaffold.dart';
import 'home.dart';
import 'ideas/ideas.dart';

class bottomNav extends StatefulWidget {
  const bottomNav({super.key});

  @override
  State<bottomNav> createState() => _bottomNavState();
}

class _bottomNavState extends State<bottomNav> with SingleTickerProviderStateMixin{
  late PageController _controller;
  int _selectedIndex = 1;
  int _previousIndex = 1;
  bool _isAnimating = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _selectedIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onItemSelected(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });

    if ((_controller.page ?? 0).round() == index - 1 || (_controller.page ?? 0).round() == index + 1) {
      // Smooth animation for adjacent pages
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    } else {
      // Slide animation for non-adjacent pages
      _isAnimating = true;

      // Determine direction of the slide
      final isForward = index > _previousIndex;
      _slideAnimation = Tween<Offset>(
        begin: Offset(isForward ? 1.0 : -1.0, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuad,
      ));

      _animationController.forward(from: 0.0).then((_) {
        _controller.jumpToPage(index);
        setState(() {
          _isAnimating = false;
        });
      });
    }
  }
  @override
  Widget build(BuildContext context) {

    final connectivityNotifier = Provider.of<ConnectivityNotifier>(context, listen: false);
    final uid = Provider.of<UserID>(context).uid; // Replace with your UID provider

    // Set the UID in the ConnectivityNotifier
    connectivityNotifier.setUid(uid);

    return ConnectivityAwareScaffold(
      child: Scaffold(
        body: Stack(
          children: [PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            children: const [
              IdeasTab(),
              MyHomePage(),
              RecipeScreen(),
            ],
          ),
            if (_isAnimating)
              SlideTransition(
                position: _slideAnimation,
                child: _listOfWidget[_selectedIndex],
              )
          ]
        ),
        bottomNavigationBar: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                icon: Icons.lightbulb_outline,
                label: 'Ideas',
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemSelected(0),
              ),
              _NavBarItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemSelected(1),
              ),
              _NavBarItem(
                icon: Icons.restaurant_menu,
                label: 'Recipes',
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 100,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isSelected ? -20 : 15,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 0 : 1,
                child: Icon(
                  icon,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: isSelected ? 12 : -20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1 : 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppThemes.accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xDBF32607),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
List<Widget> _listOfWidget = <Widget>[
  const IdeasTab(),
  const MyHomePage(),
  const RecipeScreen(),
];