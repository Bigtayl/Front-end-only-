// analytics_screen.dart
// Kullanıcının vücut analizlerini (BMI, BMR, TDEE) hesaplayan ve öneriler sunan ekran.
// Tek bir "Taylan" profili ile çalışır ve bu profilin verilerini kalıcı olarak saklar.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../core/constants/app_colors.dart'; // Renkleri import et

/// Analiz ekranı: Vücut ölçüleri, aktivite seviyesi, amaç ve sonuçlar.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // Kullanıcıdan alınan bilgiler için controller'lar
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Erkek';
  final List<String> _genderOptions = ['Erkek', 'Kadın'];

  // Scroll kontrolü için controller
  final ScrollController _scrollController = ScrollController();

  // Aktivite seviyesi ve çarpanları
  String _activityLevel = 'Hareketsiz';
  final Map<String, double> _activityMultipliers = {
    'Hareketsiz': 1.2,
    'Az Aktif': 1.375,
    'Orta Aktif': 1.55,
    'Çok Aktif': 1.725,
    'Ekstra Aktif': 1.9,
  };

  List<Map<String, dynamic>> _profiles = []; // Sadece "Taylan" profili olacak
  int _selectedIndex = 0; // Her zaman 0 olacak
  double? _bmi;
  double? _bmr;
  double? _tdee;
  String _recommendation = '';

  String _purpose = 'Kilo vermek için';
  final List<String> _purposeOptions = [
    'Kilo vermek için',
    'Kilo almak için',
    'Sadece alışveriş önerisi için',
    'Sporcu için besin önerisi',
  ];

  bool _showResults = false;
  bool _isCalculating = false;
  final GlobalKey _resultsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadProfile();

    _heightController.addListener(_onInputChanged);
    _weightController.addListener(_onInputChanged);
    _ageController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (_showResults) {
      setState(() => _showResults = false);
    }
  }

  /// "Taylan" profilini yükler veya oluşturur.
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesString = prefs.getString('profiles');
    List<Map<String, dynamic>> loadedProfiles = [];

    if (profilesString != null && profilesString.isNotEmpty) {
      try {
        loadedProfiles =
            List<Map<String, dynamic>>.from(json.decode(profilesString));
      } catch (e) {
        // Handle error if JSON is malformed
        loadedProfiles = [];
      }
    }

    if (loadedProfiles.isEmpty) {
      // Varsayılan "Taylan" profili
      loadedProfiles.add({
        'name': 'Taylan',
        'height': '180',
        'weight': '75',
        'age': '28',
        'gender': 'Erkek',
        'activityLevel': 'Orta Aktif',
        'purpose': 'Kilo vermek için',
      });
    }

    setState(() {
      _profiles = loadedProfiles;
      _selectedIndex = 0; // Her zaman ilk profili seç
    });

    _selectProfile(0); // Profili seç ve formu doldur
    await _saveProfiles(); // Değişiklikleri kaydet
  }

  /// Profili SharedPreferences ile kaydeder.
  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profiles', json.encode(_profiles));
    await prefs.setInt('selectedProfileIndex', _selectedIndex);
  }

  void _syncUserProviderWithProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final p = _profiles[index];
      userProvider.saveUserData(
        name: p['name'] ?? '',
        height: double.tryParse(p['height'].toString()),
        weight: double.tryParse(p['weight'].toString()),
        age: int.tryParse(p['age'].toString()),
        gender: p['gender'],
        activityLevel: p['activityLevel'],
        goal: p['purpose'],
        tdee: p['tdee'] != null ? double.tryParse(p['tdee'].toString()) : null,
        protein: p['protein'] != null
            ? double.tryParse(p['protein'].toString())
            : null,
        carb: p['carb'] != null ? double.tryParse(p['carb'].toString()) : null,
        fat: p['fat'] != null ? double.tryParse(p['fat'].toString()) : null,
      );
    }
  }

  /// Seçili profili yükler ve ekrana yazar.
  void _selectProfile(int index) {
    if (index < 0 || index >= _profiles.length) return;

    final profile = _profiles[index];
    setState(() {
      _selectedIndex = index;
      _heightController.text = profile['height'] ?? '';
      _weightController.text = profile['weight'] ?? '';
      _ageController.text = profile['age'] ?? '';
      _gender = profile['gender'] ?? _genderOptions[0];
      _activityLevel = profile['activityLevel'] ?? 'Hareketsiz';
      _purpose = profile['purpose'] ?? _purposeOptions[0];

      // Eğer daha önce hesaplanmış değerler varsa göster
      final tdee = profile['tdee'] as double?;
      if (tdee != null && tdee > 0) {
        _tdee = tdee;
        _bmi = _calculateCurrentBMI();
        _bmr = _calculateCurrentBMR();
        _showResults = true;
      } else {
        _bmi = null;
        _bmr = null;
        _tdee = null;
        _recommendation = '';
        _showResults = false;
      }
    });
    _syncUserProviderWithProfile(index);
  }

  /// Profil adını düzenlemek için diyalog gösterir.
  void _editProfileName() {
    final TextEditingController nameController =
        TextEditingController(text: _profiles[_selectedIndex]['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.midnightBlue, // Temaya uygun renk
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: AppColors.whiteSmoke, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Profil Adı',
            labelStyle: TextStyle(color: AppColors.whiteSmoke.withOpacity(0.8)),
            filled: true,
            fillColor: AppColors.deepFern.withOpacity(0.7), // Temaya uygun renk
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                  color: AppColors.tropicalLime,
                  width: 2.0), // Temaya uygun renk
            ),
          ),
          cursorColor: AppColors.tropicalLime, // Temaya uygun renk
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tropicalLime, // Temaya uygun renk
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _profiles[_selectedIndex]['name'] = nameController.text;
                });
                _saveProfiles();
                _syncUserProviderWithProfile(_selectedIndex);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Kaydet',
              style: TextStyle(
                  color: AppColors.deepFern,
                  fontWeight: FontWeight.bold), // Temaya uygun renk
            ),
          ),
        ],
      ),
    );
  }

  /// BMI, BMR ve TDEE hesaplar ve öneri üretir.
  void _calculateResults() async {
    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);
    final double? age = double.tryParse(_ageController.text);

    if (height == null ||
        weight == null ||
        age == null ||
        height <= 0 ||
        weight <= 0 ||
        age <= 0) {
      setState(
          () => _recommendation = 'Lütfen geçerli bir boy, kilo ve yaş girin.');
      return;
    }

    setState(() {
      _isCalculating = true;
      _showResults = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final double bmi = weight / ((height / 100) * (height / 100));
    final double bmr = (_gender == 'Erkek')
        ? (10 * weight) + (6.25 * height) - (5 * age) + 5
        : (10 * weight) + (6.25 * height) - (5 * age) - 161;
    final double tdee = bmr * _activityMultipliers[_activityLevel]!;
    final double proteinGrams = (tdee * 0.30) / 4;
    final double fatGrams = (tdee * 0.30) / 9;
    final double carbGrams = (tdee * 0.40) / 4;

    setState(() {
      _bmi = bmi;
      _bmr = bmr;
      _tdee = tdee;
      _isCalculating = false;
      _showResults = true;

      // Profili güncelle
      final profile = _profiles[_selectedIndex];
      profile['height'] = _heightController.text;
      profile['weight'] = _weightController.text;
      profile['age'] = _ageController.text;
      profile['gender'] = _gender;
      profile['activityLevel'] = _activityLevel;
      profile['purpose'] = _purpose;
      profile['tdee'] = tdee;
      profile['protein'] = proteinGrams;
      profile['carb'] = carbGrams;
      profile['fat'] = fatGrams;
      _saveProfiles();
      _syncUserProviderWithProfile(_selectedIndex);

      if (bmi < 18.5)
        _recommendation =
            'Kilo alman faydalı olabilir. Günlük kalori ihtiyacın: ${tdee.toStringAsFixed(0)} kcal';
      else if (bmi < 25)
        _recommendation =
            'Kilonu koruyorsun, böyle devam! Günlük kalori ihtiyacın: ${tdee.toStringAsFixed(0)} kcal';
      else if (bmi < 30)
        _recommendation =
            'Biraz kilo vermen önerilir. Günlük kalori ihtiyacın: ${tdee.toStringAsFixed(0)} kcal';
      else
        _recommendation =
            'Sağlığın için kilo vermen önemli. Günlük kalori ihtiyacın: ${tdee.toStringAsFixed(0)} kcal';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _resultsKey.currentContext != null) {
        final RenderBox renderBox =
            _resultsKey.currentContext!.findRenderObject() as RenderBox;
        _scrollController.animateTo(
          _scrollController.offset +
              renderBox.localToGlobal(Offset.zero).dy -
              100,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  double? _calculateCurrentBMI() {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h != null && w != null && h > 0) return w / ((h / 100) * (h / 100));
    return null;
  }

  double? _calculateCurrentBMR() {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    final a = double.tryParse(_ageController.text);
    if (h != null && w != null && a != null && h > 0 && w > 0 && a > 0) {
      return (_gender == 'Erkek')
          ? (10 * w) + (6.25 * h) - (5 * a) + 5
          : (10 * w) + (6.25 * h) - (5 * a) - 161;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    const Color midnightBlue = Color(0xFF2C3E50);
    const Color deepFern = Color(0xFF52796F);
    const Color analyticsColor = Color(0xFF50FA7B); // Ana sayfa buton rengi
    final Color analyticsLight = analyticsColor.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: midnightBlue,
      appBar: AppBar(
        backgroundColor: analyticsColor.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, analyticsColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Analizlerim',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [analyticsColor.withValues(alpha: 0.8), midnightBlue],
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
                    color: analyticsLight,
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
                    color: analyticsLight,
                  ),
                ),
              ),
              // Ana içerik: profil seçimi, ölçüler, aktivite, amaç, sonuçlar
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil seçimi kartı
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: analyticsColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: analyticsLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        analyticsColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          analyticsColor.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: analyticsColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Profil Seçimi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.white, size: 22),
                                tooltip: 'Profil Adını Düzenle',
                                onPressed: _editProfileName,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_profiles.isEmpty)
                            Center(
                              child: Text(
                                'Profil yükleniyor...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: Text(
                                    _profiles[_selectedIndex]['name'],
                                    style: TextStyle(
                                      color: deepFern,
                                      fontSize: 14,
                                    ),
                                  ),
                                  selected: true,
                                  onSelected: (selected) {
                                    // Sadece tek profil olduğu için bir şey yapma
                                  },
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  selectedColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Vücut ölçüleri kartı
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.monitor_weight_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Vücut Ölçüleri',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _heightController,
                                  label: 'Boy (cm)',
                                  icon: Icons.height,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: _weightController,
                                  label: 'Kilo (kg)',
                                  icon: Icons.monitor_weight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: _ageController,
                                  label: 'Yaş',
                                  icon: Icons.cake,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  value: _gender,
                                  items: _genderOptions,
                                  label: 'Cinsiyet',
                                  icon: Icons.person,
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value!;
                                      if (_showResults) {
                                        _showResults = false;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Aktivite seviyesi kartı
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Aktivite Seviyesi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: _activityLevel,
                            items: _activityMultipliers.keys.toList(),
                            label: 'Günlük Aktivite',
                            icon: Icons.directions_run,
                            onChanged: (value) {
                              setState(() {
                                _activityLevel = value!;
                                if (_showResults) {
                                  _showResults = false;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Amaç kartı
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF50FA7B,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Hedef',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: _purpose,
                            items: _purposeOptions,
                            label: 'Beslenme Amacı',
                            icon: Icons.track_changes,
                            onChanged: (value) {
                              setState(() {
                                _purpose = value!;
                                if (_showResults) {
                                  _showResults = false;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Hesapla butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCalculating ? null : _calculateResults,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: analyticsColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isCalculating
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Hesaplanıyor...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Hesapla',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Sonuçlar kartı - Akordiyon yapısı
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 500),
                      crossFadeState: _showResults
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        key: _resultsKey,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF50FA7B,
                                      ).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF50FA7B,
                                        ).withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.analytics,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sonuçlar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                // Kapatma butonu
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showResults = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildResultCard(
                              title: 'Vücut Kitle İndeksi (BMI)',
                              value: _bmi?.toStringAsFixed(1) ?? 'N/A',
                              color: _bmiColor(),
                              icon: Icons.monitor_weight,
                            ),
                            const SizedBox(height: 12),
                            _buildResultCard(
                              title: 'Bazal Metabolizma Hızı (BMR)',
                              value: _bmr != null
                                  ? '${_bmr!.toStringAsFixed(0)} kcal'
                                  : 'N/A',
                              color: Colors.blue,
                              icon: Icons.local_fire_department,
                            ),
                            const SizedBox(height: 12),
                            _buildResultCard(
                              title: 'Günlük Kalori İhtiyacı (TDEE)',
                              value: _tdee != null
                                  ? '${_tdee!.toStringAsFixed(0)} kcal'
                                  : 'N/A',
                              color: Colors.orange,
                              icon: Icons.restaurant,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _recommendation,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sayısal giriş alanı oluşturan yardımcı fonksiyon.
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  /// Dropdown (açılır liste) alanı oluşturan yardımcı fonksiyon.
  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF2C3E50),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Sonuç kartı oluşturan yardımcı fonksiyon (ör: BMI, BMR, TDEE)
  Widget _buildResultCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BMI değerine göre renk döndürür (görsel gösterim için)
  Color _bmiColor() {
    if (_bmi == null) {
      return Colors.grey; // Null durumunda gri renk
    } else if (_bmi! < 18.5) {
      return Colors.lightBlue;
    } else if (_bmi! >= 18.5 && _bmi! <= 24.9) {
      return Colors.green;
    } else if (_bmi! >= 25 && _bmi! <= 29.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
