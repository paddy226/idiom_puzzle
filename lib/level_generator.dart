import 'dart:math';
import 'idiom_data.dart'; // 導入成語資料

List<Map<String, String>> generateLevelCharacters({
  required int idiomCount,
  // 移除 difficulty 參數，改為從所有成語中隨機選擇
}) {
  final _random = Random();

  // 1. 獲取所有成語，不進行難度過濾
  List<Idiom> allIdioms = List.from(sampleIdioms); // 創建一個可變副本

  // 2. 打亂所有成語列表
  allIdioms.shuffle(_random);

  // 3. 選擇指定數量的成語
  List<Idiom> selectedIdioms = [];
  if (allIdioms.length >= idiomCount) {
    selectedIdioms = allIdioms.sublist(0, idiomCount);
  } else {
    // 如果指定數量大於可用數量，則選擇所有可用成語
    selectedIdioms = allIdioms;
    print('警告: 指定成語數量 ($idiomCount) 超過可用數量 (${allIdioms.length})，將使用所有可用成語。');
  }
  
  // 4. 從選定的成語中提取所有字元及其注音
  List<Map<String, String>> gameBoardCharacters = [];
  for (Idiom idiom in selectedIdioms) {
    gameBoardCharacters.addAll(idiom.getCharacterZhuyins());
  }

  // 5. 打亂所有字元及其注音的順序
  gameBoardCharacters.shuffle(_random);

  return gameBoardCharacters;
}