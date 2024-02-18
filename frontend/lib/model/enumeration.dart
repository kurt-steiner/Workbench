import 'package:flutter/material.dart';
import 'package:frontend/util/extensions.dart';

enum PriorityColor {
  Red,
  Orange,
  Green,
  Blue,
  Grey
}

extension ToStringPriority on PriorityColor {
  String toEnumString() {
    switch (this) {
      case PriorityColor.Red:
        return "Red";
      case PriorityColor.Orange:
        return "Orange";
      case PriorityColor.Green:
        return "Green";
      case PriorityColor.Blue:
        return "Blue";
      case PriorityColor.Grey:
        return "Grey";
    }
  }
}

final Map<String, PriorityColor> priorityMap = {
  "Red": PriorityColor.Red,
  "Orange": PriorityColor.Orange,
  "Green": PriorityColor.Green,
  "Blue": PriorityColor.Blue,
  "Grey": PriorityColor.Grey
};

final Map<PriorityColor, Color> priorityColors = {
  PriorityColor.Red: Colors.red,
  PriorityColor.Orange: Colors.orange,
  PriorityColor.Green: Colors.green,
  PriorityColor.Blue: Colors.blue,
  PriorityColor.Grey: Colors.grey
};

enum TagColor {
  GoldenSand,
  Coral,
  WildWatermelon,
  Peace,
  Grisaille,
  Orange,
  BruschettaTomato,
  Watermelon,
  BayWharf,
  PrestigeBlue,
  LimeSoap,
  FrenchSkyBlue,
  SaturatedSky,
  UfoGreen,
  ClearChill,
  BrightGreek
}

extension ToStringTagColor on TagColor {
  String toEnumString() {
    switch (this) {
      case TagColor.GoldenSand:
        return "GoldenSand";
      case TagColor.Coral:
        return "Coral";
      case TagColor.WildWatermelon:
        return "WildWatermelon";
      case TagColor.Peace:
        return "Peace";
      case TagColor.Grisaille:
        return "Grisaille";
      case TagColor.Orange:
        return "Orange";
      case TagColor.BruschettaTomato:
        return "BruschettaTomato";
      case TagColor.Watermelon:
        return "Watermelon";
      case TagColor.BayWharf:
        return "BayWharf";
      case TagColor.PrestigeBlue:
        return "PrestigeBlue";
      case TagColor.LimeSoap:
        return "LimeSoap";
      case TagColor.FrenchSkyBlue:
        return "FrenchSkyBlue";
      case TagColor.SaturatedSky:
        return "SaturatedSky";
      case TagColor.UfoGreen:
        return "UfoGreen";
      case TagColor.ClearChill:
        return "ClearChill";
      case TagColor.BrightGreek:
        return "BrightGreek";
    }
  }
}

final Map<String, TagColor> tagMap = {
  'GoldenSand': TagColor.GoldenSand,
  'Coral': TagColor.Coral,
  'WildWatermelon': TagColor.WildWatermelon,
  'Peace': TagColor.Peace,
  'Grisaille': TagColor.Grisaille,
  'Orange': TagColor.Orange,
  'BruschettaTomato': TagColor.BruschettaTomato,
  'Watermelon': TagColor.Watermelon,
  'BayWharf': TagColor.BayWharf,
  'PrestigeBlue': TagColor.PrestigeBlue,
  'LimeSoap': TagColor.LimeSoap,
  'FrenchSkyBlue': TagColor.FrenchSkyBlue,
  'SaturatedSky': TagColor.SaturatedSky,
  'UfoGreen': TagColor.UfoGreen,
  'ClearChill': TagColor.ClearChill,
  'BrightGreek': TagColor.BrightGreek,
};

final Map<TagColor, Color> tagColors = {
  TagColor.GoldenSand: HexColor.fromRGBHex("#eccc68"),
  TagColor.Coral:  HexColor.fromRGBHex("#ff7f50"),
  TagColor.WildWatermelon: HexColor.fromRGBHex("#ff6b81"),
  TagColor.Peace: HexColor.fromRGBHex("#a4b0be"),
  TagColor.Grisaille: HexColor.fromRGBHex("#57606f"),
  TagColor.Orange: HexColor.fromRGBHex("#ffa502"),
  TagColor.BruschettaTomato: HexColor.fromRGBHex("#ff6348"),
  TagColor.Watermelon: HexColor.fromRGBHex("#ff4757"),
  TagColor.BayWharf: HexColor.fromRGBHex("#747d8c"),
  TagColor.PrestigeBlue: HexColor.fromRGBHex("#2f3542"),
  TagColor.LimeSoap: HexColor.fromRGBHex("#7bed9f"),
  TagColor.FrenchSkyBlue: HexColor.fromRGBHex("#70a1ff"),
  TagColor.SaturatedSky: HexColor.fromRGBHex("#5352ed"),
  TagColor.UfoGreen: HexColor.fromRGBHex("#2ed573"),
  TagColor.ClearChill: HexColor.fromRGBHex("#1e90ff"),
  TagColor.BrightGreek: HexColor.fromRGBHex("#3742fa")
};

