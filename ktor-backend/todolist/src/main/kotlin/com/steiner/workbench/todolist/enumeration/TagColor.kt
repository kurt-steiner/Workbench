package com.steiner.workbench.todolist.enumeration

import kotlinx.serialization.Serializable

@Serializable
enum class TagColor(val color: String) {
    GoldenSand("#eccc68"),
    Coral("#ff7f50"),
    WildWatermelon("#ff6b81"),
    Peace("#a4b0be"),
    Grisaille("#57606f"),
    Orange("#ffa502"),
    BruschettaTomato("#ff6348"),
    Watermelon("#ff4757"),
    BayWharf("#747d8c"),
    PrestigeBlue("#2f3542"),
    LimeSoap("#7bed9f"),
    FrenchSkyBlue("#70a1ff"),
    SaturatedSky("#5352ed"),
    UfoGreen("#2ed573"),
    ClearChill("#1e90ff"),
    BrightGreek("#3742fa")
}