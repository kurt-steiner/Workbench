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

enum FlatUIColor {
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

extension ToStringTagColor on FlatUIColor {
  String toEnumString() {
    switch (this) {
      case FlatUIColor.GoldenSand:
        return "GoldenSand";
      case FlatUIColor.Coral:
        return "Coral";
      case FlatUIColor.WildWatermelon:
        return "WildWatermelon";
      case FlatUIColor.Peace:
        return "Peace";
      case FlatUIColor.Grisaille:
        return "Grisaille";
      case FlatUIColor.Orange:
        return "Orange";
      case FlatUIColor.BruschettaTomato:
        return "BruschettaTomato";
      case FlatUIColor.Watermelon:
        return "Watermelon";
      case FlatUIColor.BayWharf:
        return "BayWharf";
      case FlatUIColor.PrestigeBlue:
        return "PrestigeBlue";
      case FlatUIColor.LimeSoap:
        return "LimeSoap";
      case FlatUIColor.FrenchSkyBlue:
        return "FrenchSkyBlue";
      case FlatUIColor.SaturatedSky:
        return "SaturatedSky";
      case FlatUIColor.UfoGreen:
        return "UfoGreen";
      case FlatUIColor.ClearChill:
        return "ClearChill";
      case FlatUIColor.BrightGreek:
        return "BrightGreek";
    }
  }
}

final Map<String, FlatUIColor> flatUIMap = {
  'GoldenSand': FlatUIColor.GoldenSand,
  'Coral': FlatUIColor.Coral,
  'WildWatermelon': FlatUIColor.WildWatermelon,
  'Peace': FlatUIColor.Peace,
  'Grisaille': FlatUIColor.Grisaille,
  'Orange': FlatUIColor.Orange,
  'BruschettaTomato': FlatUIColor.BruschettaTomato,
  'Watermelon': FlatUIColor.Watermelon,
  'BayWharf': FlatUIColor.BayWharf,
  'PrestigeBlue': FlatUIColor.PrestigeBlue,
  'LimeSoap': FlatUIColor.LimeSoap,
  'FrenchSkyBlue': FlatUIColor.FrenchSkyBlue,
  'SaturatedSky': FlatUIColor.SaturatedSky,
  'UfoGreen': FlatUIColor.UfoGreen,
  'ClearChill': FlatUIColor.ClearChill,
  'BrightGreek': FlatUIColor.BrightGreek,
};

final Map<FlatUIColor, Color> flatUIColors = {
  FlatUIColor.GoldenSand: HexColor.fromRGBHex("#eccc68"),
  FlatUIColor.Coral:  HexColor.fromRGBHex("#ff7f50"),
  FlatUIColor.WildWatermelon: HexColor.fromRGBHex("#ff6b81"),
  FlatUIColor.Peace: HexColor.fromRGBHex("#a4b0be"),
  FlatUIColor.Grisaille: HexColor.fromRGBHex("#57606f"),
  FlatUIColor.Orange: HexColor.fromRGBHex("#ffa502"),
  FlatUIColor.BruschettaTomato: HexColor.fromRGBHex("#ff6348"),
  FlatUIColor.Watermelon: HexColor.fromRGBHex("#ff4757"),
  FlatUIColor.BayWharf: HexColor.fromRGBHex("#747d8c"),
  FlatUIColor.PrestigeBlue: HexColor.fromRGBHex("#2f3542"),
  FlatUIColor.LimeSoap: HexColor.fromRGBHex("#7bed9f"),
  FlatUIColor.FrenchSkyBlue: HexColor.fromRGBHex("#70a1ff"),
  FlatUIColor.SaturatedSky: HexColor.fromRGBHex("#5352ed"),
  FlatUIColor.UfoGreen: HexColor.fromRGBHex("#2ed573"),
  FlatUIColor.ClearChill: HexColor.fromRGBHex("#1e90ff"),
  FlatUIColor.BrightGreek: HexColor.fromRGBHex("#3742fa")
};

