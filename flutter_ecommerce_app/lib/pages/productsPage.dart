// Imports flutter design widgets
import 'package:flutter/material.dart';
import 'dart:async';

// Imports product model and products service
import '../models/product.dart';
import '../services/products_service.dart';

// Imports productDetailsPage.dart
import 'productDetailsPage.dart';

// Separate stateful widget for banner carousel (allows it to update independanty of other products)
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  // timer for auto scrolling bannerss
  late Timer _bannerTimer;
  // Banner index
  int _currentBannerIndex = 0;
  // Total amount of banners
  final int _bannerCount = 4;

  @override
  void initState() {
    super.initState();
    // Initializes page controller and starts auto-scrolling timer
    _pageController = PageController();
    _startAutoScroll();
  }

// Starts a timer that auto-scrolls the banner every 5 seconds
  void _startAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Updates the current banner index and animates to the next banner
      if (mounted) {
        // Loops back to the first banner after reaching the end
        _currentBannerIndex = (_currentBannerIndex + 1) % _bannerCount;
        // Animates to the next banner
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancels the timer and disposes the page controller when the widget is removed from the widget tree
    _bannerTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Banner Images
    final List<String> bannerImages = [
      'banners/banner1.jpg',
      'banners/banner2.jpg',
      'banners/banner3.jpg',
      'banners/banner4.jpg',
    ];

    // Labels for banners
    final List<String> bannerLabels = [
      '',
      'New Arrivals',
      'Free Shipping',
      'Exclusive Deals'
    ];

    return SizedBox(
      height: 180,

      // PageView for swiping through banners
      child: PageView.builder(
        controller: _pageController,
        // Updates the current banner index when the user manually swipes
        onPageChanged: (index) {
          setState(() {
            _currentBannerIndex = index;
          });
        },
        itemCount: bannerImages.length,
        // Builds each banner with a colored background and label
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(bannerImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  bannerLabels[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Main products page widget (Stateful because it needs to update when products are loaded from Firebase)
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

// Builds the featured products section, which is a horizontally scrollable list of hardcoded products
  Widget buildFeaturedSection() {
    final List<String> featuredIds = ['1', '2', '3', '4'];

    return FutureBuilder<List<Product>>(
      future: ProductsService().getProductsByIds(featuredIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final featured = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Featured Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            // Horizontally scrollable list of featured products
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                itemBuilder: (context, index) {
                  final product = featured[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12, left: 8),
                    // Each product is displayed in a card that can be tapped to navigate to the product details page
                    child: GestureDetector(
                      onTap: () {
                        // Navigates to the ProductDetailsPage when tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsPage(product: product),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: SizedBox(
                          width: 140,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Displays product image
                              AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  // Loads online first, if not loads locally (this is the way the project works for demonstration)
                                  child: product.image.startsWith('http')
                                      ? Image.network(product.image,
                                          fit: BoxFit.cover)
                                      : Image.asset(product.image,
                                          fit: BoxFit.cover),
                                ),
                              ),
                              // Displays product name and price
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Displays product price, formated to 2 decimal points
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6.0),
                                child: Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title centered
      appBar: AppBar(title: const Text('Shop'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const BannerCarousel(), // Display the banner at the top
              const SizedBox(
                  height: 16), // Adds spacing between banner and products
              buildFeaturedSection(), // Builds Featured products section
              // Future builder object that waits for the list of products to be retrieved from Firebase
              FutureBuilder<List<Product>>(
                // Calls Firebase service
                future: ProductsService().getAllProducts(),
                builder: (context, snapshot) {
                  // Loading screen
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Displayes error message
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  // Load products list, or return empty if null
                  final products = snapshot.data ?? [];
                  // Grid for products
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final Product product = products[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigates to the ProductDetailsPage when tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Displays product image
                              AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  // Loads online first, if not loads locally (this is the way the project works for demonstration)
                                  child: product.image.startsWith('http')
                                      ? Image.network(product.image,
                                          fit: BoxFit.cover)
                                      : Image.asset(product.image,
                                          fit: BoxFit.cover),
                                ),
                              ),
                              // Displays product name
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              // Displays product price, formated to 2 decimal points
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                    '\$${product.price.toStringAsFixed(2)}'),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
