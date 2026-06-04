# Codex作業指示書

## 目的

現在のMVP釣りゲームを壊さずに、魚個体管理システムを段階的に導入する。

Codexには、既存のMVP機能を維持したまま、魚個体を管理するための新規スクリプトとデータ構造を追加してもらう。

---

## 前提

Godot 4.6.3 を使用している。

現在のMVPでは以下が実装済み。

```text
プレイヤー移動
Camera2D追従
釣りエリア判定
釣り開始
キャスト方向ライン
着水地点表示
アタリ
合わせ
ファイト
魚GET
魚種・サイズ・重量表示
CatchRecord
釣果一覧UI
所持金表示
魚売却
Git管理
```

---

## 参照する設計書

Codexは以下の設計書を参照すること。

```text
docs/game_design.md
docs/fish_system_design.md
docs/fish_species_design.md
docs/fish_fight_design.md
docs/development_log.md
docs/todo.md
```

---

## 第1実装目標

魚をランダム抽選ではなく、フィールド内に存在する個体として扱う。

現在の

```text
FishDatabase.get_random_fish()
```

による取得を、将来的に

```text
FishManager.get_fish_near_position()
```

へ置き換えられる構造にする。

---

## 作成するファイル

```text
scripts/fish_instance.gd
scripts/fish_manager.gd
data/fish_spawn_data.json
```

---

## fish_instance.gd

魚個体を表すクラス。

持つべき情報：

```text
id
species_id
species_name

size
weight

age_days
growth_rate

stamina
power

position

is_caught

spawn_time
last_update_time
```

最低限必要な関数：

```text
setup(data: Dictionary)
grow(days: float)
to_dict() -> Dictionary
from_dict(data: Dictionary)
```

---

## fish_manager.gd

魚個体群を管理するAutoload候補。

持つべき責務：

```text
魚個体の生成
魚個体リストの保持
キャスト地点周辺の魚検索
釣れた魚の削除
個体数不足時の補充
```

最低限必要な関数：

```text
initialize_fish()
get_fish_near_position(position: Vector2, radius: float) -> Dictionary
mark_fish_caught(fish_id: String)
create_fish_instance(species_id: String, position: Vector2) -> Dictionary
replenish_if_needed()
get_all_fish() -> Array
```

---

## data/fish_spawn_data.json

魚の初期スポーンと個体数管理用データ。

例：

```json
[
  {
	"area_id": "test_river",
	"species_id": "yamame",
	"min_count": 5,
	"max_count": 20,
	"initial_count": 8,
	"spawn_radius": 300,
	"spawn_center": {
	  "x": 0,
	  "y": 0
	}
  },
  {
	"area_id": "test_river",
	"species_id": "ugui",
	"min_count": 3,
	"max_count": 15,
	"initial_count": 5,
	"spawn_radius": 400,
	"spawn_center": {
	  "x": 100,
	  "y": 0
	}
  }
]
```

---

## 既存コードへの影響

第1段階では、既存の釣りMVPを大きく壊さない。

まずは FishManager を追加するだけでもよい。

既存の `field.gd` の `catch_fish()` は、最初の段階ではまだ `FishDatabase.get_random_fish()` のままでもよい。

次段階で以下に置き換える。

```text
キャスト地点
↓
FishManagerで周辺魚検索
↓
魚がいればアタリ候補
↓
釣れたらその個体を削除
```

---

## 壊してはいけない動作

以下は実装後も動作すること。

```text
プレイヤー移動できる

川辺で釣り開始できる

キャストできる

アタリが出る

合わせできる

ファイトできる

魚GETできる

釣果一覧が表示できる

魚売却で所持金が増える
```

---

## 実装方針

段階的に実装する。

### Step 1

```text
fish_instance.gd 作成
fish_manager.gd 作成
fish_spawn_data.json 作成
```

既存ゲーム動作は変更しない。

---

### Step 2

```text
FishManagerをAutoload登録できる状態にする
initialize_fish() で魚個体を生成
printで個体一覧を確認
```

---

### Step 3

```text
キャスト地点周辺の魚を検索する
魚がいない場合はアタリなし
魚がいる場合のみアタリ判定
```

---

### Step 4

```text
釣れた魚個体をFishManagerから削除
CatchRecordに登録
個体数不足なら補充
```

---

## 注意点

Godot 4.6.3 のGDScriptで警告がエラー扱いになる可能性がある。

型推論で Variant になりそうな箇所は、明示的に型を書くこと。

例：

```gdscript
var fish_data: Dictionary = {}
var fishes: Array[Dictionary] = []
var position: Vector2 = Vector2.ZERO
```

---

## Godot CLI確認方法

この環境ではGodot CLIは以下を使う。

```text
/mnt/c/Tools/Godot/Godot_v4.6.3-stable_win64_console.exe
```

Windows版Godotなので、`--path` にはWSL形式の `/mnt/c/...` ではなく、Windows形式のパスを渡す。

```bash
/mnt/c/Tools/Godot/Godot_v4.6.3-stable_win64_console.exe --headless --path 'C:\Users\motunabe\Documents\japanese-river-fishing' --quit-after 2
```

スクリプト単体の構文確認は `--check-only --script` を使う。

```bash
/mnt/c/Tools/Godot/Godot_v4.6.3-stable_win64_console.exe --headless --path 'C:\Users\motunabe\Documents\japanese-river-fishing' --check-only --script res://scripts/fish_manager.gd
```

Autoloadに依存する既存スクリプトは、単体 `--script` だと `GameState` などを解決できない場合がある。その場合はプロジェクト起動確認で見る。

---

## 完了条件

以下が確認できれば完了。

```text
プロジェクトが起動する

既存MVPが壊れていない

FishManagerが魚個体を生成できる

魚個体がサイズ・重量・位置を持っている

キャスト地点周辺の魚検索ができる
```

---

## コミットメッセージ案

```text
Add fish instance management foundation
```
