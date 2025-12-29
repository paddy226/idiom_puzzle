// 核心邏輯測試
import 'idiom_data.dart'; // 導入成語資料

bool canFormIdiomAndConsume(List<String> availableChars, String idiom) {
  List<String> tempChars = List.from(availableChars); // 創建臨時副本

  for (int i = 0; i < idiom.length; i++) {
    String char = idiom[i];
    if (tempChars.remove(char)) { // 使用 remove 返回 bool
      // 字元移除成功
    } else {
      return false; // 字元不足
    }
  }

  // 如果所有字元都找到並移除，則更新原始列表
  availableChars.clear();
  availableChars.addAll(tempChars); // 注意這裡的 availableChars 是參數名
  return true;
}

void main() {
  // 定義所有可用漢字的列表
  List<String> availableCharacters = ['畫', '心', '龍', '點', '意', '一', '睛', '一'];
  print('初始漢字列表: $availableCharacters');

  // 從 sampleIdioms 中提取成語字串
  List<String> targetIdiomStrings = sampleIdioms.map((idiom) => idiom.idiom).toList();
  print('目標成語: $targetIdiomStrings\n'); // 修正字串結束符號位置

  print('--- 開始模擬 ---');
  for (String idiomString in targetIdiomStrings) {
    if (canFormIdiomAndConsume(availableCharacters, idiomString)) {
      print('成功組成成語 "$idiomString"');
      print('剩餘漢字: $availableCharacters\n');
    } else {
      print('無法組成成語 "$idiomString"');
      print('剩餘漢字（未變動）: $availableCharacters\n');
    }
  }
  print('--- 模擬結束 ---');
}
