package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.common.util.FlatUIColor
import kotlinx.serialization.Serializable

@Serializable
class PostIconWordRequest(
    val word: Char,
    val color: FlatUIColor
)