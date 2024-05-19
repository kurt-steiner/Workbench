package com.steiner.workbench.common

import kotlinx.serialization.json.Json

/// for priority
const val `priority-default-name` = "普通"

/// for common image items
const val `image-item-name-length` = 256
const val `image-item-path-length` = 256

/// for todolist
const val `task-project-name-length` = 32
const val `task-group-name-length` = 32
const val `tag-name-length` = 32
const val `task-name-length` = 64
const val `subtask-name-length` = 32
const val `tag-color-length` = 16
const val `priority-name-length` = 16

/// for validate
const val `common-string-length-min` = 1

val emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\$".toRegex()
val rgbHexColorPattern = Regex("^#[0-9A-Fa-f]{6}\$")

/// for daily-attendance
const val `daily-attendance-name-length` = 24
const val `daily-attendance-encouragement-length` = 24

val formatter = Json {
    classDiscriminator = "type"
}