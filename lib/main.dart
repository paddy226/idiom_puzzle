import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:package_info_plus/package_info_plus.dart';
import 'level_generator.dart';
import 'idiom_data.dart';

void main() {
  runApp(const IdiomPuzzleApp());
}

enum GameState {
  startPage,
  playing,
  gameOver,
}

enum AppThemeStyle {
  traditional,
  tech,
  cartoon,
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}

class IdiomPuzzleApp extends StatefulWidget {
  const IdiomPuzzleApp({super.key});

  @override
  State<IdiomPuzzleApp> createState() => _IdiomPuzzleAppState();
}

class _IdiomPuzzleAppState extends State<IdiomPuzzleApp> {
  AppThemeStyle _currentStyle = AppThemeStyle.traditional;
  bool _isSoundEnabled = true;
  static const String _themeKey = 'app_theme_style';
  static const String _soundKey = 'app_sound_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedThemeIndex = prefs.getInt(_themeKey);
    if (savedThemeIndex != null && savedThemeIndex >= 0 && savedThemeIndex < AppThemeStyle.values.length) {
      setState(() {
        _currentStyle = AppThemeStyle.values[savedThemeIndex];
      });
    }

    final savedSound = prefs.getBool(_soundKey);
    if (savedSound != null) {
      setState(() {
        _isSoundEnabled = savedSound;
      });
    }
  }

  Future<void> _changeTheme(AppThemeStyle style) async {
    setState(() {
      _currentStyle = style;
    });
    if (_isSoundEnabled) SystemSound.play(SystemSoundType.click);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, style.index);
  }

  Future<void> _toggleSound(bool enabled) async {
    setState(() {
      _isSoundEnabled = enabled;
    });
    if (enabled) SystemSound.play(SystemSoundType.click);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  static const TextStyle _baseTextStyle = TextStyle(inherit: true);

  ThemeData _buildTheme(AppThemeStyle style) {
    if (style == AppThemeStyle.traditional) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF795548),
          primary: const Color(0xFF795548),
          secondary: const Color(0xFFFFC107),
          surface: const Color(0xFFFFF8E1),
          background: const Color(0xFFF5F5DC),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: const Color(0xFF3E2723),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF795548),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFF8E1),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF795548),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: _baseTextStyle.copyWith(color: const Color(0xFF3E2723)),
          titleLarge: _baseTextStyle.copyWith(color: const Color(0xFF3E2723), fontWeight: FontWeight.bold),
        ),
      );
    } else if (style == AppThemeStyle.tech) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFD500F9),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Color(0xFF00E5FF),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF2C2C2C),
          elevation: 4,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            side: BorderSide(color: Color(0xFF00E5FF), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            foregroundColor: Colors.black,
            elevation: 5,
            shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
            textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: _baseTextStyle.copyWith(color: Colors.white),
          titleLarge: _baseTextStyle.copyWith(color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          primary: Colors.pinkAccent,
          secondary: Colors.lightGreenAccent,
          surface: Colors.white,
          background: Colors.lightBlue.shade50,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.lightBlue.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellowAccent,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w900, fontSize: 18),
            shadowColor: Colors.transparent,
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: _baseTextStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          titleLarge: _baseTextStyle.copyWith(color: Colors.black, fontWeight: FontWeight.w900),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '成語拼圖',
      theme: _buildTheme(_currentStyle),
      home: IdiomPuzzleHomePage(
        onThemeChanged: _changeTheme,
        currentStyle: _currentStyle,
        isSoundEnabled: _isSoundEnabled,
        onSoundChanged: _toggleSound,
      ),
    );
  }
}

class IdiomPuzzleHomePage extends StatefulWidget {
  final Function(AppThemeStyle) onThemeChanged;
  final AppThemeStyle currentStyle;
  final bool isSoundEnabled;
  final Function(bool) onSoundChanged;

  const IdiomPuzzleHomePage({
    super.key,
    required this.onThemeChanged,
    required this.currentStyle,
    required this.isSoundEnabled,
    required this.onSoundChanged,
  });

  @override
  State<IdiomPuzzleHomePage> createState() => _IdiomPuzzleHomePageState();
}

class _IdiomPuzzleHomePageState extends State<IdiomPuzzleHomePage> with WidgetsBindingObserver {
  GameState _gameState = GameState.startPage;
  Timer? _timer;
  int _remainingTime = 100;
  bool _isChallengeMode = false;
  GameDifficulty _difficulty = GameDifficulty.easy;

  late List<Map<String, String>> gameCharacters = [];
  List<String> _selectedCharacters = [];
  List<int> _selectedIndices = [];
  int _currentLevel = 1;
  Idiom? _lastFoundIdiom;
  
  int _wrongAttempts = 0;
  String? _hintMessage;

  // Save State flags
  bool _hasChallengeSave = false;
  bool _hasCasualSave = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
    _checkSavedGames();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final difficultyIndex = prefs.getInt('game_difficulty');
    if (difficultyIndex != null && difficultyIndex >= 0 && difficultyIndex < GameDifficulty.values.length) {
      setState(() {
        _difficulty = GameDifficulty.values[difficultyIndex];
      });
    }
  }

  Future<void> _setDifficulty(GameDifficulty difficulty) async {
    setState(() {
      _difficulty = difficulty;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('game_difficulty', difficulty.index);
  }

  int _getTimeReward() {
    switch (_difficulty) {
      case GameDifficulty.easy:
        return 10;
      case GameDifficulty.medium:
        return 5;
      case GameDifficulty.hard:
        return 2;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _triggerFeedback({bool isSuccess = false, bool isError = false}) {
    if (!widget.isSoundEnabled) return;

    SystemSound.play(SystemSoundType.click);
    if (isSuccess) {
      HapticFeedback.mediumImpact();
    } else if (isError) {
      HapticFeedback.vibrate();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_gameState == GameState.playing) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        _timer?.cancel();
        _saveProgress();
      } else if (state == AppLifecycleState.resumed && _isChallengeMode) {
        _startTimer();
      }
    }
  }

  String _getSavePrefix(bool isChallenge) => isChallenge ? 'challenge_' : 'casual_';

  Future<void> _checkSavedGames() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasChallengeSave = prefs.containsKey('challenge_level');
      _hasCasualSave = prefs.containsKey('casual_level');
    });
  }

  Future<void> _saveProgress() async {
    if (_gameState != GameState.playing) return;

    final prefs = await SharedPreferences.getInstance();
    final prefix = _getSavePrefix(_isChallengeMode);

    await prefs.setInt('${prefix}level', _currentLevel);
    await prefs.setInt('${prefix}time', _remainingTime);
    await prefs.setString('${prefix}characters', jsonEncode(gameCharacters));
    await prefs.setString('${prefix}selected_chars', jsonEncode(_selectedCharacters));
    await prefs.setString('${prefix}selected_indices', jsonEncode(_selectedIndices));
    await prefs.setInt('${prefix}wrong', _wrongAttempts);
    if (_lastFoundIdiom != null) {
      await prefs.setString('${prefix}last_idiom', _lastFoundIdiom!.idiom);
    } else {
      await prefs.remove('${prefix}last_idiom');
    }
    if (_hintMessage != null) {
      await prefs.setString('${prefix}hint', _hintMessage!);
    } else {
      await prefs.remove('${prefix}hint');
    }
    
    _checkSavedGames();
  }

  Future<void> _resumeGame(bool isChallenge) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _getSavePrefix(isChallenge);

    if (!prefs.containsKey('${prefix}level')) return;

    try {
      final level = prefs.getInt('${prefix}level') ?? 1;
      final time = prefs.getInt('${prefix}time') ?? 100;
      
      final charsJson = prefs.getString('${prefix}characters');
      final List<dynamic> charsList = charsJson != null ? jsonDecode(charsJson) : [];
      final List<Map<String, String>> loadedCharacters = charsList.map((e) => Map<String, String>.from(e)).toList();

      final selectedCharsJson = prefs.getString('${prefix}selected_chars');
      final List<String> loadedSelectedChars = selectedCharsJson != null ? List<String>.from(jsonDecode(selectedCharsJson)) : [];

      final selectedIndicesJson = prefs.getString('${prefix}selected_indices');
      final List<int> loadedSelectedIndices = selectedIndicesJson != null ? List<int>.from(jsonDecode(selectedIndicesJson)) : [];

      final wrong = prefs.getInt('${prefix}wrong') ?? 0;
      final hint = prefs.getString('${prefix}hint');
      
      final lastIdiomStr = prefs.getString('${prefix}last_idiom');
      Idiom? loadedLastIdiom;
      if (lastIdiomStr != null) {
        try {
          loadedLastIdiom = sampleIdioms.firstWhere((i) => i.idiom == lastIdiomStr);
        } catch (_) {}
      }

      _triggerFeedback();
      setState(() {
        _isChallengeMode = isChallenge;
        _gameState = GameState.playing;
        _currentLevel = level;
        _remainingTime = time;
        gameCharacters = loadedCharacters;
        _selectedCharacters = loadedSelectedChars;
        _selectedIndices = loadedSelectedIndices;
        _wrongAttempts = wrong;
        _hintMessage = hint;
        _lastFoundIdiom = loadedLastIdiom;

        if (_isChallengeMode) {
          _startTimer();
        }
      });
    } catch (e) {
      _clearSave(isChallenge);
      _showSnackBar("無法讀取存檔", Colors.red);
    }
  }

  Future<void> _clearSave(bool isChallenge) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _getSavePrefix(isChallenge);
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (var key in keys) {
      await prefs.remove(key);
    }
    _checkSavedGames();
  }

  void _startGame({required bool isChallenge}) {
    _triggerFeedback();
    _clearSave(isChallenge);

    setState(() {
      _currentLevel = 1;
      _isChallengeMode = isChallenge;
      _gameState = GameState.playing;
      _lastFoundIdiom = null;
      _wrongAttempts = 0;
      _hintMessage = null;
      _initializeGame();
      
      if (_isChallengeMode) {
        _remainingTime = 100;
        _startTimer();
      }
    });
  }

  Future<void> _resetToStartPage() async {
    _triggerFeedback();
    await _saveProgress();
    setState(() {
      _timer?.cancel();
      _gameState = GameState.startPage;
      _currentLevel = 1;
      _lastFoundIdiom = null;
      _wrongAttempts = 0;
      _hintMessage = null;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          _gameState = GameState.gameOver;
          _triggerFeedback(isError: true);
          _clearSave(_isChallengeMode);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showGameOverDialog();
          });
        }
      });
    });
  }
  
  void _showGameOverDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('時間到！'),
          content: Text('遊戲結束！\n您的最終等級是：$_currentLevel'),
          actions: <Widget>[
            TextButton(
              child: const Text('回到主選單'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                   _gameState = GameState.startPage;
                   _currentLevel = 1;
                   _lastFoundIdiom = null;
                   _wrongAttempts = 0;
                   _hintMessage = null;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      _showSnackBar('無法開啟連結 $url', Colors.red);
    }
  }

  void _showInfoDialog() {
    _triggerFeedback();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('關於本程式'),
          content: FutureBuilder<PackageInfo>( 
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              String versionText = '版本: 讀取中...';
              if (snapshot.hasData) {
                versionText = '版本: ${snapshot.data!.version}';
              }
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(versionText),
                    const SizedBox(height: 8),
                    const Text('作者: Paddy'),
                    const SizedBox(height: 8),
                    InkWell(
                      child: Text(
                        'GitHub(建制中): https://github.com/paddy226/idiom_puzzle',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary, 
                          decoration: TextDecoration.underline
                        ),
                      ),
                      onTap: () => _launchUrl('https://github.com/PaddyS-code/idiom_puzzle'),
                    ),
                    const SizedBox(height: 8),
                    Text('成語詞庫數量: ${sampleIdioms.length}'),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('關閉'),
              onPressed: () {
                _triggerFeedback();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    _triggerFeedback();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: const Text('設定'),
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Text('遊戲難度', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: DropdownButton<GameDifficulty>(
                    value: _difficulty,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: GameDifficulty.easy,
                        child: Text('簡單 (答對 +10秒)'),
                      ),
                      DropdownMenuItem(
                        value: GameDifficulty.medium,
                        child: Text('中等 (答對 +5秒)'),
                      ),
                      DropdownMenuItem(
                        value: GameDifficulty.hard,
                        child: Text('困難 (答對 +2秒)'),
                      ),
                    ],
                    onChanged: (GameDifficulty? newValue) {
                      if (newValue != null) {
                        _triggerFeedback();
                        _setDifficulty(newValue);
                        setState(() {});
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Text('主題風格', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: DropdownButton<AppThemeStyle>(
                    value: widget.currentStyle,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: AppThemeStyle.traditional,
                        child: Text('新中式風格 (預設)'),
                      ),
                      DropdownMenuItem(
                        value: AppThemeStyle.tech,
                        child: Text('科技暗色風格'),
                      ),
                      DropdownMenuItem(
                        value: AppThemeStyle.cartoon,
                        child: Text('卡通可愛風格'),
                      ),
                    ],
                    onChanged: (AppThemeStyle? newValue) {
                      if (newValue != null) {
                        _triggerFeedback();
                        widget.onThemeChanged(newValue);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('音效與震動'),
                  value: widget.isSoundEnabled,
                  onChanged: (bool value) {
                    widget.onSoundChanged(value);
                    setState(() {});
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _initializeGame() {
    gameCharacters = generateLevelCharacters(
      idiomCount: 4,
    );
    _clearSelection();
  }

  void _onCharacterTap(String character, int index) {
    if (_gameState != GameState.playing) return;

    _triggerFeedback();

    setState(() {
      if (_selectedIndices.contains(index)) {
        int listIndex = _selectedIndices.indexOf(index);
        _selectedIndices.removeAt(listIndex);
        _selectedCharacters.removeAt(listIndex);
      } else {
        if (_selectedCharacters.length == 4) {
          _selectedCharacters.clear();
          _selectedIndices.clear();
        }

        _selectedCharacters.add(character);
        _selectedIndices.add(index);

        if (_selectedCharacters.length == 4) {
          _checkIdiom();
        }
      }
    });
  }

  void _clearSelection() {
    _triggerFeedback();
    setState(() {
      _selectedCharacters.clear();
      _selectedIndices.clear();
    });
  }

  void _generateHint() {
    List<String> currentChars = gameCharacters.map((e) => e['char']!).toList();
    Idiom? targetIdiom;
    
    for (var idiom in sampleIdioms) {
      bool allCharsPresent = true;
      List<String> tempChars = List.from(currentChars);
      
      for (int i = 0; i < idiom.idiom.length; i++) {
        String char = idiom.idiom[i];
        if (tempChars.contains(char)) {
          tempChars.remove(char);
        } else {
          allCharsPresent = false;
          break;
        }
      }
      
      if (allCharsPresent) {
        targetIdiom = idiom;
        break;
      }
    }

    if (targetIdiom != null) {
      List<int> indices = [0, 1, 2, 3];
      indices.shuffle();
      String hint = '';
      for (int i = 0; i < 4; i++) {
        if (i == indices[0] || i == indices[1]) {
          hint += targetIdiom.idiom[i];
        } else {
          hint += '〇';
        }
      }
      setState(() {
        _hintMessage = "提示：$hint";
      });
    }
  }

  bool _checkAndConsumeIdiom() {
    String selectedIdiomString = _selectedCharacters.join('');
    if (selectedIdiomString.length != 4) return false;

    try {
      final foundIdiom = sampleIdioms.firstWhere((idiom) => idiom.idiom == selectedIdiomString);
      
      _selectedIndices.sort((a, b) => b.compareTo(a));
      for (int index in _selectedIndices) {
        gameCharacters.removeAt(index);
      }

      _triggerFeedback(isSuccess: true);

      setState(() {
        _lastFoundIdiom = foundIdiom;
        _wrongAttempts = 0;
        _hintMessage = null;
        if (_isChallengeMode) {
          _remainingTime += _getTimeReward();
        }
      });

      if (gameCharacters.isEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _triggerFeedback(isSuccess: true);
          setState(() {
            _currentLevel++;
            _initializeGame();
          });
        });
      }
      return true;

    } catch (e) {
      _triggerFeedback(isError: true);
      _showSnackBar('這個組合不是有效的成語！', Colors.red);
      
      setState(() {
        _wrongAttempts++;
        if (_isChallengeMode) {
          _remainingTime = (_remainingTime > 10) ? _remainingTime - 10 : 0;
        }
        if (_wrongAttempts >= 3) {
          _generateHint();
        }
      });
      return false;
    }
  }

  void _checkIdiom() {
    setState(() {
      _checkAndConsumeIdiom();
      _selectedIndices.clear();
    });
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    bool showContinue = false,
    VoidCallback? onContinuePressed,
  }) {
    bool isTech = widget.currentStyle == AppThemeStyle.tech;
    bool isCartoon = widget.currentStyle == AppThemeStyle.cartoon;

    Color btnColor = color;
    if (isTech) {
      if (color == const Color(0xFFD84315)) btnColor = const Color(0xFF00E5FF);
      if (color == const Color(0xFF2E7D32)) btnColor = const Color(0xFFD500F9);
    }
    if (isCartoon) {
       if (color == const Color(0xFFD84315)) btnColor = Colors.orangeAccent;
       if (color == const Color(0xFF2E7D32)) btnColor = Colors.lightGreenAccent;
    }

    Widget mainButton;

    if (isCartoon) {
      mainButton = Container(
        width: showContinue ? 160 : 220,
        height: 60,
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: Colors.black),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
              ],
            ),
          ),
        ),
      );
    } else {
      mainButton = SizedBox(
        width: showContinue ? 160 : 220,
        height: 60,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isTech ? Colors.black45 : btnColor,
            foregroundColor: isTech ? btnColor : Colors.white,
            elevation: 5,
            side: isTech ? BorderSide(color: btnColor, width: 2) : null,
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, inherit: true),
            shape: isTech 
                ? BeveledRectangleBorder(borderRadius: BorderRadius.circular(10))
                : RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 28),
          label: Text(label, style: const TextStyle(inherit: true)),
        ),
      );
    }

    if (!showContinue) return mainButton;

    Widget continueButton;
    if (isCartoon) {
      continueButton = Container(
        width: 100,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
           boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onContinuePressed,
            child: const Center(
              child: Text('繼續', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
            ),
          ),
        ),
      );
    } else {
      continueButton = SizedBox(
        width: 100,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isTech ? Colors.black45 : Colors.white,
            foregroundColor: isTech ? btnColor : btnColor,
            elevation: 5,
            side: isTech ? BorderSide(color: btnColor, width: 2) : null,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, inherit: true),
            shape: isTech 
                ? BeveledRectangleBorder(borderRadius: BorderRadius.circular(10))
                : RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onContinuePressed,
          child: const Text('繼續', style: TextStyle(inherit: true)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mainButton,
        const SizedBox(width: 12),
        continueButton,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTech = widget.currentStyle == AppThemeStyle.tech;
    bool isCartoon = widget.currentStyle == AppThemeStyle.cartoon;
    
    return Scaffold(
      appBar: AppBar(
        leading: _gameState == GameState.playing
            ? IconButton(
                icon: const Icon(Icons.home),
                onPressed: _resetToStartPage,
                tooltip: '回到主選單',
                color: isCartoon ? Colors.black : null,
              )
            : null,
        title: Text(
          _gameState == GameState.playing
            ? '等級: $_currentLevel' + (_isChallengeMode ? ' | 時間: $_remainingTime' : '')
            : '成語拼圖',
          style: isCartoon ? const TextStyle(fontWeight: FontWeight.w900, color: Colors.black) : null,
        ),
        actions: <Widget>[
           IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: _showSettingsDialog,
            color: isCartoon ? Colors.black : null,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '關於本程式',
            onPressed: _showInfoDialog,
            color: isCartoon ? Colors.black : null,
          ),
        ],
      ),
      body: _buildGameBody(isTech, isCartoon),
    );
  }

  Widget _buildGameBody(bool isTech, bool isCartoon) {
    switch (_gameState) {
      case GameState.startPage:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isCartoon)
                    Text(
                      '成語拼圖',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                        foreground: Paint()..style = PaintingStyle.stroke ..strokeWidth = 6 ..color = Colors.black,
                      ),
                    ),
                  Text(
                    '成語拼圖',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isTech 
                        ? const Color(0xFF00E5FF) 
                        : (isCartoon ? Colors.pinkAccent : const Color(0xFF5D4037)),
                      letterSpacing: 4.0,
                      shadows: [
                        if (!isCartoon)
                        Shadow(
                          offset: isTech ? const Offset(0, 0) : const Offset(2, 2),
                          blurRadius: isTech ? 15.0 : 3.0,
                          color: isTech ? const Color(0xFF00E5FF).withOpacity(0.8) : Colors.black26,
                        ),
                        if (isCartoon)
                        const Shadow(
                          offset: Offset(4, 4),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              _buildMenuButton(
                label: '挑戰模式',
                onPressed: () => _startGame(isChallenge: true),
                icon: Icons.timer,
                color: const Color(0xFFD84315),
                showContinue: _hasChallengeSave,
                onContinuePressed: () => _resumeGame(true),
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                label: '休閒模式',
                onPressed: () => _startGame(isChallenge: false),
                icon: Icons.spa,
                color: const Color(0xFF2E7D32),
                showContinue: _hasCasualSave,
                onContinuePressed: () => _resumeGame(false),
              ),
            ],
          ),
        );
      case GameState.playing:
      case GameState.gameOver:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isTech ? Colors.black45 : Colors.white,
                        borderRadius: BorderRadius.circular(isTech ? 4 : (isCartoon ? 16 : 12)),
                        border: Border.all(
                          color: isTech ? const Color(0xFF00E5FF) : (isCartoon ? Colors.black : const Color(0xFF795548)), 
                          width: isCartoon ? 2 : 2
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isTech ? const Color(0xFF00E5FF).withOpacity(0.3) : (isCartoon ? Colors.black : Colors.black12),
                            blurRadius: isTech ? 8 : (isCartoon ? 0 : 4),
                            offset: isCartoon ? const Offset(4, 4) : const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        _selectedCharacters.join(''),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32.0, 
                          fontWeight: FontWeight.bold,
                          color: isTech ? Colors.white : Colors.black,
                          letterSpacing: 8.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  
                  if (isCartoon)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 2),
                         boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 0,
                            offset: Offset(3, 3),
                          )
                        ],
                      ),
                      child: IconButton(
                        onPressed: _clearSelection,
                        icon: const Icon(Icons.backspace_outlined, color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _clearSelection,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: isTech 
                          ? BeveledRectangleBorder(borderRadius: BorderRadius.circular(5))
                          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.backspace_outlined, color: Colors.white),
                    ),
                ],
              ),
              if (_hintMessage != null || _lastFoundIdiom != null)
                Container(
                  margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isTech ? const Color(0xFF1E1E1E) : (isCartoon ? Colors.yellow[100] : const Color(0xFFFFF3E0)),
                    borderRadius: BorderRadius.circular(isTech ? 4 : (isCartoon ? 16 : 12)),
                    border: Border.all(
                      color: isTech ? const Color(0xFFD500F9) : (isCartoon ? Colors.black : const Color(0xFFFFB74D)), 
                      width: isCartoon ? 2 : 1
                    ),
                    boxShadow: [
                       BoxShadow(
                         color: isTech ? const Color(0xFFD500F9).withOpacity(0.2) : (isCartoon ? Colors.black : Colors.black12),
                         blurRadius: isTech ? 6 : (isCartoon ? 0 : 4),
                         offset: isCartoon ? const Offset(4, 4) : const Offset(0, 2),
                       ),
                    ],
                  ),
                  child: _hintMessage != null 
                    ? Text(
                        _hintMessage!,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: isTech ? const Color(0xFFD500F9) : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _lastFoundIdiom!.idiom,
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: isTech ? const Color(0xFFD500F9) : (isCartoon ? Colors.purple : const Color(0xFFD84315)),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            _lastFoundIdiom!.meaning,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: isTech ? Colors.white70 : Colors.black,
                              height: 1.4,
                              fontWeight: isCartoon ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                ),
              const SizedBox(height: 16.0),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: gameCharacters.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedIndices.contains(index);
                    final charData = gameCharacters[index];
                    final character = charData['char']!;
                    final baseZhuyin = charData['baseZhuyin']!;
                    final tone = charData['tone']!;

                    Color cardColor;
                    Color textColor;
                    if (isTech) {
                      cardColor = isSelected ? const Color(0xFF00E5FF).withOpacity(0.2) : const Color(0xFF2C2C2C);
                      textColor = isSelected ? const Color(0xFF00E5FF) : Colors.white;
                    } else if (isCartoon) {
                       cardColor = isSelected ? Colors.cyanAccent : Colors.white;
                       textColor = Colors.black;
                    } else {
                      cardColor = isSelected ? const Color(0xFF5D4037) : const Color(0xFFFFF8E1);
                      textColor = isSelected ? Colors.white : const Color(0xFF3E2723);
                    }

                    ShapeBorder cardShape;
                    if (isTech) {
                      cardShape = BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent, 
                          width: 1
                        )
                      );
                    } else if (isCartoon) {
                       cardShape = RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.black, 
                          width: isSelected ? 3 : 2
                        )
                      );
                    } else {
                      cardShape = RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      );
                    }

                    if (isCartoon) {
                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: isSelected ? 3 : 2),
                          boxShadow: [
                             BoxShadow(
                              color: Colors.black,
                              offset: isSelected ? const Offset(1, 1) : const Offset(3, 3),
                              blurRadius: 0,
                            )
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _onCharacterTap(character, index),
                          child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              character,
                              style: TextStyle(
                                fontSize: 36.0, 
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                             if (baseZhuyin.isNotEmpty)
                              Positioned(
                                right: 12,
                                top: 0,
                                bottom: 0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: baseZhuyin.split('').map((char) => Text(
                                    char, 
                                    style: const TextStyle(
                                      fontSize: 10.0, 
                                      color: Colors.black, 
                                      fontWeight: FontWeight.w900
                                    )
                                  )).toList(),
                                ),
                              ),
                            if (tone.isNotEmpty)
                              Positioned(
                                right: 6,
                                top: 0,
                                bottom: 0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: tone.split('').map((char) => Text(
                                    char, 
                                    style: const TextStyle(
                                      fontSize: 14.0, 
                                      color: Colors.black, 
                                      fontWeight: FontWeight.w900
                                    )
                                  )).toList(),
                                ),
                              ),
                          ],
                        ), 
                        ),
                      );
                    }

                    return Material(
                      elevation: isSelected ? 8 : 2,
                      shape: cardShape, 
                      color: cardColor,
                      child: InkWell(
                        onTap: () => _onCharacterTap(character, index),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              character,
                              style: TextStyle(
                                fontSize: 36.0, 
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                shadows: isTech && isSelected ? [
                                  const Shadow(blurRadius: 10, color: Color(0xFF00E5FF))
                                ] : null,
                              ),
                            ),
                            if (baseZhuyin.isNotEmpty)
                              Positioned(
                                right: 12,
                                top: 0,
                                bottom: 0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: baseZhuyin.split('').map((char) => Text(
                                    char, 
                                    style: TextStyle(
                                      fontSize: 10.0, 
                                      color: isTech ? Colors.white54 : (isSelected ? Colors.white70 : const Color(0xFF5D4037)), 
                                      fontWeight: FontWeight.bold
                                    )
                                  )).toList(),
                                ),
                              ),
                            if (tone.isNotEmpty)
                              Positioned(
                                right: 6,
                                top: 0,
                                bottom: 0,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: tone.split('').map((char) => Text(
                                    char, 
                                    style: TextStyle(
                                      fontSize: 14.0, 
                                      color: isTech ? Colors.white54 : (isSelected ? Colors.white70 : const Color(0xFF5D4037)), 
                                      fontWeight: FontWeight.bold
                                    )
                                  )).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
    }
  }
}
