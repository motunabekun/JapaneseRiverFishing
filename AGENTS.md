# AGENTS.md

## プロジェクト概要

JapaneseRiverFishing は、Godot 4.6.3 で作成している日本の河川を舞台にした2D釣りゲーム。

現在の目的は、既存のMVPを遊べる状態で維持しながら、魚を単なるランダム抽選ではなく、フィールド内に存在する個体として扱う仕組みに段階的に置き換えること。

## 壊してはいけない既存MVP

以下の動作は維持すること。

- プレイヤー移動
- Camera2D追従
- 釣りエリア判定
- 釣り開始・終了
- キャスト方向ライン
- 着水地点表示
- アタリ
- 合わせ
- ファイトUI
- 魚GET表示
- CatchRecord
- 釣果一覧パネル
- 所持金表示
- 魚売却

## 主要ドキュメント

関連システムを変更する前に、必要に応じて以下を読むこと。

- `docs/game_design.md`
- `docs/fish_system_design.md`
- `docs/fish_species_design.md`
- `docs/fish_fight_design.md`
- `docs/development_log.md`
- `docs/todo.md`
- `docs/codex_tasks.md`

## 開発方針

小さな単位で進める。大きな作り直しよりも、常にゲームが起動できる状態を優先する。

### 完了済み

- Godotプロジェクト作成
- MVP釣りループ
- 釣果記録と所持金
- 魚個体管理の土台
- `scripts/fish_instance.gd`
- `scripts/fish_manager.gd`
- `data/fish_spawn_data.json`

### 次にやること

1. `FishManager` を Autoload 登録する。
2. 起動時に `FishManager.initialize_fish()` を呼ぶ。
3. `FishManager.get_all_fish()` で魚個体が生成されていることを確認する。
4. キャスト後に `FishManager.get_fish_near_position(cast_target_position, radius)` を使う。
5. キャスト地点の近くに魚がいない場合は、アタリなしにする。
6. キャスト地点の近くに魚がいる場合だけ、アタリとファイトに進める。
7. 釣れた魚は `FishManager.mark_fish_caught(fish_id)` で捕獲済みにする。
8. 釣れた魚を `CatchRecord` に追加する。
9. 釣果後に `FishManager.replenish_if_needed()` を呼ぶ。
10. 所持金、釣果、魚個体、プレイヤー状態を保存するセーブデータを設計する。

## 実装ルール

- 変更範囲は依頼された機能に絞る。
- 明示的に置き換える作業でない限り、既存MVPの動作を維持する。
- 新しい抽象化より、既存コードの書き方を優先する。
- Variant推論で警告が出そうな箇所は、GDScriptの型を明示する。
- 釣りシステム接続中は、大規模なリファクタリングを避ける。
- コメントは、分かりにくいゲームロジックを補足する場合だけ短く書く。
- 意味のある機能を完了したら `docs/development_log.md` を更新する。
- 優先順位が変わったら `docs/todo.md` を更新する。

## ソースコード中のコメント記述ルール

- 見れば分かる処理にはコメントを書かない。
- コメントは「何をしているか」ではなく、「なぜそうしているか」を説明する。
- 仕様意図、ゲームデザイン上の判断、Godot特有の制約、データ形式の注意点がある場合に書く。
- 関数コメントは全関数に付けない。外部から呼ばれる重要な関数や、仕様上の意味がある関数に限定する。
- 変数コメントは、単位・値域・座標系・ゲーム上の意味が分かりにくい場合だけ書く。
- 仮実装には、仮である理由と後で置き換える条件を書く。
- コメントがコードとズレた場合は、コメントを更新するか削除する。
- TODOコメントは、解決条件が分かる具体的な内容にする。
- コメントは日本語で書く。API名、クラス名、関数名、ファイルパス、コマンドは翻訳しない。

## GDScriptの注意点

Godotでは警告がエラー扱いになることがある。JSONやDictionaryを扱う箇所では、型を明示すること。

良い例:

```gdscript
var fish_data: Dictionary = {}
var fishes: Array[Dictionary] = []
var position: Vector2 = Vector2.ZERO
var parsed_data: Variant = JSON.parse_string(text)
```

JSONを読むときは、値を使う前に `Array` や `Dictionary` であることを確認する。

## Godot CLI

使用するGodot実行ファイル:

```text
/mnt/c/Tools/Godot/Godot_v4.6.3-stable_win64_console.exe
```

これはWindows版のGodotなので、`--path` にはWindows形式のパスを渡す。

```bash
/mnt/c/Tools/Godot/Godot_v4.6.3-stable_win64_console.exe --headless --path 'C:\Users\motunabe\Documents\japanese-river-fishing' --quit-after 2
```

スクリプト構文確認:

```bash
/mnt/c/Tools/Godot/Godot_v4.6.3-stable_win64_console.exe --headless --path 'C:\Users\motunabe\Documents\japanese-river-fishing' --check-only --script res://scripts/fish_manager.gd
```

Autoloadに依存するスクリプトは、単体の `--script` 確認だと失敗する場合がある。その場合はプロジェクト起動確認で判断する。

## 完了条件

ゲームプレイに関わる変更では、可能な範囲で以下を確認する。

- プロジェクトがheadless modeで起動する。
- 関連スクリプトの構文確認が通る。
- 既存MVPの流れが壊れていない。
- 意味のある新規動作は `docs/development_log.md` に記録されている。

## 現在の優先順位

1. `FishManager` を実際の釣りフローに接続する。
2. 魚個体のステータスを使ってファイトシステムを仮調整する。
3. セーブデータを設計・実装する。
4. 釣果と売却の流れを改善する。
5. フィールド表示と水表現を改善する。
