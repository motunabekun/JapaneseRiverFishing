# 魚種データ設計

## 目的

魚種ごとの生態や釣れやすさを定義する。

魚個体とは別に管理する。

---

## FishSpecies

```text
species_id

name

base_bite_rate

preferred_areas

preferred_time_ranges

preferred_seasons

preferred_weather

preferred_water_temperature

preferred_baits
```

---

## 場所

例

```text
mountain_stream
upper_river
middle_river
lower_river
river_mouth
pool
```

---

## 時間帯

```text
morning
daytime
evening
night
```

---

## 季節

```text
spring
summer
autumn
winter
```

---

## 天候

```text
sunny
cloudy
light_rain
rain
```

---

## 水温

```text
min_temp
max_temp
```

---

## エサ

```text
worm
river_insect
corn
dough_bait
artificial_fly
lure
```

---

## ヤマメ例

```json
{
  "id": "yamame",
  "name": "ヤマメ",

  "preferred_areas": [
	"mountain_stream",
    "upper_river"
  ],

  "preferred_time_ranges": [
	"morning",
    "evening"
  ],

  "preferred_seasons": [
	"spring",
	"early_summer",
    "autumn"
  ],

  "preferred_weather": [
	"cloudy",
    "light_rain"
  ],

  "preferred_water_temperature": {
	"min": 8,
	"max": 18
  },

  "preferred_baits": [
	"river_insect",
	"worm",
    "artificial_fly"
  ],

  "base_bite_rate": 0.35
}
```

---

## アタリ計算

```text
基本値

+
場所補正

+
時間補正

+
季節補正

+
天候補正

+
水温補正

+
エサ補正
```

---

## 将来追加

```text
遊泳層

好む流速

好む水深

好む濁り

警戒心

群れやすさ

産卵期
```

---

## データファイル

```text
data/fish_species_data.json
```

---

## FishInstanceとの関係

```text
FishInstance
↓
species_id
↓
FishSpecies参照
```

魚種情報は共有し、

サイズや重量などは個体側で管理する。
