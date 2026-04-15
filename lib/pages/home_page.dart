import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hustleamapp/data/models/product_models.dart';
import '../presentation/widgets/product_card.dart';
import 'package:hustleamapp/pages/shop_page.dart';
import 'package:hustleamapp/pages/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _bestSellerController;
  late PageController _newCollectionController;

  final List<Map<String, String>> _topSlides = [
    {
      "image": "assets/images/front.jpg",
      "title": "THE ART OF HUSTLE",
      "btn": "SHOP NOW",
    },
    {
      "image": "assets/images/front2.jpg",
      "title": "NEW ARRIVALS",
      "btn": "EXPLORE",
    },
    {
      "image": "assets/images/RAGLANv1.jpg",
      "title": "STREET LEGENDS",
      "btn": "SHOP NOW",
    },
    {
      "image": "assets/images/RAGLANv1.2.jpg",
      "title": "LIMITED DROPS",
      "btn": "EXPLORE",
    },
  ];

  final List<Map<String, String>> _midSlides = [
    {
      "image": "assets/images/resellpic.jpg",
      "title": "RESELL EXCLUSIVES",
      "btn": "VIEW ALL",
    },
    {
      "image": "assets/images/resellpic2.jpg",
      "title": "PREMIUM SERIES",
      "btn": "GRAB NOW",
    },
    {
      "image": "assets/images/front2.1.jpg",
      "title": "VINTAGE SOUL",
      "btn": "VIEW ALL",
    },
    {
      "image": "assets/images/front2.2.jpg",
      "title": "URBAN CULTURE",
      "btn": "GRAB NOW",
    },
  ];

  @override
  void initState() {
    super.initState();
    _bestSellerController = PageController(viewportFraction: 0.96);
    _newCollectionController = PageController(viewportFraction: 0.96);
  }

  @override
  void dispose() {
    _bestSellerController.dispose();
    _newCollectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 10,
              ),
              child: Image.asset(
                'assets/images/logo1.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchDelegate(),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                AutoHeroSlider(
                  slides: _topSlides,
                  height: 500,
                  onBtnTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopPage()),
                  ),
                ),
                const SizedBox(height: 50),
                _buildBrandStatement(),
                const SizedBox(height: 50),
                _sectionHeader("BEST SELLER", "best_seller"),
                const SizedBox(height: 20),
                _buildHorizontalGrid(_bestSellerController, 'best_seller'),
                const SizedBox(height: 60),
                AutoHeroSlider(
                  slides: _midSlides,
                  height: 500,
                  onBtnTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopPage()),
                  ),
                ),
                const SizedBox(height: 50),
                _sectionHeader("NEW COLLECTIONS", "new_collections"),
                const SizedBox(height: 20),
                _buildHorizontalGrid(
                  _newCollectionController,
                  'new_collections',
                ),
                const SizedBox(height: 20),
                _buildPremiumFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Colors.black,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ShopPage(initialCategory: tag)),
            ),
            child: const Text(
              "VIEW ALL",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalGrid(PageController controller, String tag) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('tag', isEqualTo: tag)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100);
        final products = snapshot.data!.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();
        if (products.isEmpty) return const SizedBox();
        return SizedBox(
          height: 360,
          child: PageView.builder(
            controller: controller,
            itemCount: products.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) =>
                ProductCard(product: products[index]),
          ),
        );
      },
    );
  }

  Widget _buildBrandStatement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Text(
            "EST. 2024",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "WEARABLE ART FOR THE DRIVEN",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Focused on bringing you a hardcore art style with a fashionable look. Every design is a unique work of art crafted for those who hustle.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.7,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          Image.asset('assets/images/HCC1.png', height: 70),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialBtn(
                Icons.facebook,
                "https://facebook.com/hustleamclothingco",
              ),
              const SizedBox(width: 20),
              _socialBtn(
                Icons.tiktok_outlined,
                "https://tiktok.com/@hustleamclothingco",
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "© 2024 HUSTLEAM CLOTHING CO.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 9,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialBtn(IconData icon, String url) => InkWell(
        onTap: () async => await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, size: 22, color: Colors.black),
        ),
      );
}

class _StickySearchDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 70.0;
  @override
  double get maxExtent => 70.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        ),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 225, 223, 223),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black54, size: 18),
              const SizedBox(width: 10),
              Text(
                "Search collections...",
                style: TextStyle(
                  color: const Color.fromARGB(255, 28, 27, 27),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class AutoHeroSlider extends StatefulWidget {
  final List<Map<String, String>> slides;
  final double height;
  final VoidCallback onBtnTap;
  const AutoHeroSlider({
    super.key,
    required this.slides,
    required this.height,
    required this.onBtnTap,
  });
  @override
  State<AutoHeroSlider> createState() => _AutoHeroSliderState();
}

class _AutoHeroSliderState extends State<AutoHeroSlider> {
  late PageController _controller;
  int _current = 0;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (_controller.hasClients) {
        _current = (_current + 1) % widget.slides.length;
        _controller.animateToPage(
          _current,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutExpo,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.slides[i]['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 30,
                  right: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.slides[i]['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: widget.onBtnTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 18,
                          ),
                        ),
                        child: Text(
                          widget.slides[i]['btn']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: Row(
              children: List.generate(
                widget.slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  height: 3,
                  width: _current == i ? 25 : 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_current == i ? 1 : 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
