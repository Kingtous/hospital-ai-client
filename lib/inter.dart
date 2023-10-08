// Copyright 2023 a1147
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// 输入字符串，26个小写字母，返回第一个只出现一次的字符
// bbac -> a

class MapItem {
  late int cnt;
  late int firstIdx;
}

void output(String src) {
  Map<int, MapItem> codeCnt = Map();
  for (int idx = 0; idx < src.codeUnits.length; idx++) {
    final ch = src.codeUnits[idx];
    if (codeCnt.containsKey(ch)) {
      codeCnt[ch]!.cnt += 1;
    } else {
      codeCnt[ch] = MapItem()
        ..cnt = 1
        ..firstIdx = idx;
    }
  }
  final entries = codeCnt.entries
      .where((element) => element.value.cnt == 1)
      .toList(growable: false);
  if (entries.isEmpty) {
    print('not exists');
  } else {
    int firstCh = 0;
    int firstIdx = src.length + 1;
    for (final entry in entries) {
      if (entry.value.firstIdx < firstIdx) {
        firstCh = entry.key;
        firstIdx = entry.value.firstIdx;
      }
    }
    print(String.fromCharCode(firstCh));
  }
}

// 版本号判断

// example: 1.2.3   4.5.6
int judgeVersionCode(String firstVer, String secondVer) {
  final ver1 = firstVer.split('.');
  final ver2 = secondVer.split('.');

  assert(ver1.length == ver2.length);
  final maxCnt = ver1.length;
  for (int i = 0; i < maxCnt; i++) {
    final v1 = int.tryParse(ver1[i]);
    final v2 = int.tryParse(ver2[i]);
    assert(v1 != null && v2 != null);
    if (v1! < v2!) {
      return -1;
    } else if (v1 > v2) {
      return 1;
    }
  }
  return 0;
}

// 有25匹马，5个跑道，找到最快的前3匹马

void main() {
  final res = judgeVersionCode('1.2.5', '1.2.6');
  print(res == 1
      ? "大于"
      : res == 0
          ? '等于'
          : '小于');
}
