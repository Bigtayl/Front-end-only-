// home_screen.dart
// Uygulamanın ana ekranı. Kullanıcıya selam, ana fonksiyonlara hızlı erişim, animasyonlu grid kartlar ve alt gezinme çubuğu içerir.
// AppBar'da bildirimler ve profil avatarı gösterilir. Navigasyon ve ekran geçişleri burada yönetilir.

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'core/utils/localization.dart';
import 'models/product.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'services/mock_data_service.dart';

/// Ana ekran widget'ı. Kullanıcıya selam verir ve ana fonksiyonlara erişim sağlar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Alt menüde seçili olan index
  bool _showedOnboarding = false; // Onboarding gösterildi mi?
  List<Product> _productList = []; // Ürün listesi
  bool _isLoading = true; // Yükleme durumu
  List<Widget> _pages = []; // Sayfaları tutan liste

  @override
  void initState() {
    super.initState();
    _loadProducts();
    // Uygulama ilk açıldığında onboarding göster
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOnboardingIfFirstTime();
    });
  }

  /// Mock veri servisinden ürünleri yükle
  Future<void> _loadProducts() async {
    final mockService = MockDataService();
    final products = mockService.getSampleProducts();

    setState(() {
      _productList = products;
      _isLoading = false;
      _initializePages();
    });
  }

  /// Sayfaları başlat
  void _initializePages() {
    _pages = [
      HomeContent(productList: _productList), // Ana sayfa içeriği
      const ShoppingListScreen(),
      NutritionScreen(
        iconColor: AppColors.orangeAccent,
        detailText: 'Sağlıklı beslenme için öneriler ve ipuçları!',
        products: _productList,
      ),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];
  }

  /// Uygulama ilk açıldığında kullanıcıya hoş geldin mesajı gösterir.
  Future<void> _showOnboardingIfFirstTime() async {
    if (!_showedOnboarding) {
      setState(() {
        _showedOnboarding = true;
      });
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(Localization.t("Hoş geldin!")),
          content: Text(
            Localization.t(
              "Besinova ile sağlıklı yaşam yolculuğuna başla! Ana ekrandaki butonlardan alışveriş listeni, besin önerilerini, analizlerini ve ayarları keşfedebilirsin. Alt menüden hızlıca geçiş yapabilirsin.",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(Localization.t("Başla")),
            ),
          ],
        ),
      );
    }
  }

  /// Alt menüde bir sekmeye tıklanınca ilgili ekrana geçiş yapar.
  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _pages.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.midnightBlue,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.tropicalLime,
          ),
        ),
      );
    }

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.midnightBlue,
        // Uygulamanın üst kısmı: AppBar
        appBar: _selectedIndex == 0
            ? AppBar(
                backgroundColor: AppColors.deepFern.withValues(alpha: 0.95),
                elevation: 0,
                centerTitle: true,
                title: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.tropicalLime, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Besinova',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                actions: [
                  // Bildirim ikonu
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return IconButton(
                          onPressed: () {
                            _showNotificationsPopup(context, userProvider);
                          },
                          icon: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                              // Bildirim sayısı badge'i (sadece bildirim varsa göster)
                              if (userProvider.notificationCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      userProvider.notificationCount >
                                              AppConstants.maxNotificationCount
                                          ? AppConstants.maxNotificationDisplay
                                          : userProvider.notificationCount
                                              .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Profil ikonu
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return GestureDetector(
                          onTap: () {
                            // Profil sayfasına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                userProvider.avatar.isNotEmpty
                                    ? userProvider.avatar
                                    : userProvider.name.isNotEmpty
                                        ? userProvider.name[0].toUpperCase()
                                        : '🍏',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : null,
        // Ana içerik
        body: _pages[_selectedIndex],
        // Alt gezinme çubuğu
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  /// Alt gezinme çubuğu oluşturan yardımcı fonksiyon
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepFern,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Alışveriş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Besinler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analiz',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  void _showNotificationsPopup(
      BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.midnightBlue,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.tropicalLime.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.tropicalLime.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: AppColors.tropicalLime,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Bildirimler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bildirim sayısı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.tropicalLime.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: AppColors.tropicalLime,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${userProvider.notificationCount} yeni bildirim',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Örnek bildirimler
                if (userProvider.notificationCount > 0) ...[
                  _buildNotificationItem(
                    '🥗 Besin Önerisi',
                    'Günlük protein hedefinizi tamamlamak için tavuk göğsü önerilir.',
                    '2 saat önce',
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    '📊 Analiz Hatırlatması',
                    'Haftalık sağlık analizinizi yapmayı unutmayın.',
                    '1 gün önce',
                  ),
                  const SizedBox(height: 12),
                  _buildNotificationItem(
                    '🛒 Alışveriş Listesi',
                    'Alışveriş listenizde 3 ürün kaldı.',
                    '2 gün önce',
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Henüz bildiriminiz yok',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yeni bildirimler geldiğinde burada görünecek',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Tümünü temizle butonu
                if (userProvider.notificationCount > 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Bildirimleri temizle
                        userProvider.saveUserData(notificationCount: 0);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tropicalLime,
                        foregroundColor: AppColors.midnightBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tümünü Temizle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(String title, String message, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ana sayfa içeriği widget'ı
class HomeContent extends StatelessWidget {
  final List<Product> productList;

  const HomeContent({
    super.key,
    required this.productList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.deepFern.withValues(alpha: 0.8),
            AppColors.midnightBlue
          ],
          stops: const [0.0, 0.6],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Dekoratif arka plan daireleri
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tropicalLime.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.deepFern.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Kullanıcıya selam ve motivasyon kartı
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  return Text(
                                    'Merhaba, ${userProvider.name.isNotEmpty ? userProvider.name : 'Kullanıcı'}!',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bugün sağlıklı beslenmeye devam edelim!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Ana fonksiyonlara erişim için animasyonlu grid kartlar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Arka plan desenleri (dekoratif daireler, noktalar, dalgalar)
                          Positioned(
                            right: 20,
                            top: 20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.redAccent.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 20,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.orangeAccent
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: 60,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.greenAccent
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          // Noktalı desen
                          Positioned.fill(
                            child: CustomPaint(
                              painter: DotsPatternPainter(
                                color: Colors.grey.withValues(alpha: 0.15),
                                dotRadius: 1.5,
                                spacing: 20,
                              ),
                            ),
                          ),
                          // Dalgalı çizgiler
                          Positioned.fill(
                            child: CustomPaint(
                              painter: WavePatternPainter(
                                color: Colors.grey.withValues(alpha: 0.15),
                                waveHeight: 20,
                                waveWidth: 100,
                              ),
                            ),
                          ),
                          // Ana içerik: animasyonlu grid kartlar
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            child: Center(
                              child: AnimationLimiter(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.75,
                                  padding: const EdgeInsets.all(12),
                                  children:
                                      AnimationConfiguration.toStaggeredList(
                                    duration: const Duration(milliseconds: 375),
                                    childAnimationBuilder: (widget) =>
                                        SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: widget,
                                      ),
                                    ),
                                    children: [
                                      // Ana fonksiyon kartları
                                      _buildHomeCard(
                                        icon: Icons.shopping_cart_outlined,
                                        title: 'Alışveriş\nListem',
                                        subtitle: 'Alışveriş listeni\nyönet',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ShoppingListScreen()),
                                          );
                                        },
                                        iconColor: AppColors.redAccent,
                                        iconBackgroundColor: AppColors.redAccent
                                            .withValues(alpha: 0.15),
                                      ),
                                      _buildHomeCard(
                                        icon: Icons.restaurant_menu_outlined,
                                        title: 'Besin\nÖnerileri',
                                        subtitle: 'Sağlıklı\nbeslenme',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => NutritionScreen(
                                                iconColor:
                                                    AppColors.orangeAccent,
                                                detailText:
                                                    'Sağlıklı beslenme için öneriler ve ipuçları!',
                                                products: productList,
                                              ),
                                            ),
                                          );
                                        },
                                        iconColor: AppColors.orangeAccent,
                                        iconBackgroundColor: AppColors
                                            .orangeAccent
                                            .withValues(alpha: 0.15),
                                      ),
                                      _buildHomeCard(
                                        icon: Icons.analytics_outlined,
                                        title: 'Analizlerim',
                                        subtitle: 'Vücut analizi\nve öneriler',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const AnalyticsScreen()),
                                          );
                                        },
                                        iconColor: AppColors.greenAccent,
                                        iconBackgroundColor: AppColors
                                            .greenAccent
                                            .withValues(alpha: 0.15),
                                      ),
                                      _buildHomeCard(
                                        icon: Icons.settings_outlined,
                                        title: 'Ayarlar',
                                        subtitle: 'Uygulama\nayarları',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const SettingsScreen()),
                                          );
                                        },
                                        iconColor: Color(0xFFBD93F9),
                                        iconBackgroundColor:
                                            Color(0xFFBD93F9).withOpacity(0.15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Alt bilgi
                  const Text(
                    'Besinova v1.0.0 • Sağlıklı yaşa 💚',
                    style: TextStyle(fontSize: 13, color: Color(0xFFFFE0B2)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ana ekrandaki fonksiyon kartlarını oluşturan yardımcı fonksiyon.
  Widget _buildHomeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    required Color iconBackgroundColor,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.9)
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Arka plan için noktalı desen çizen yardımcı painter.
class DotsPatternPainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  DotsPatternPainter({
    required this.color,
    required this.dotRadius,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Arka plan için dalgalı çizgi deseni çizen yardımcı painter.
class WavePatternPainter extends CustomPainter {
  final Color color;
  final double waveHeight;
  final double waveWidth;

  WavePatternPainter({
    required this.color,
    required this.waveHeight,
    required this.waveWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    var y = size.height / 2;

    path.moveTo(0, y);
    for (double x = 0; x < size.width; x += waveWidth) {
      path.quadraticBezierTo(
        x + waveWidth / 2,
        y + waveHeight,
        x + waveWidth,
        y,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
