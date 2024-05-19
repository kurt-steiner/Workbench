package com.steiner.workbench.daily_attendance.model

import com.steiner.workbench.common.util.FlatUIColor
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Icon {
    @Serializable
    @SerialName("image")
    class Image(val entryId: Int, val backGroundId: Int, val backGroundColor: FlatUIColor): Icon()

    @Serializable
    @SerialName("word")
    class Word(val char: Char, val color: FlatUIColor): Icon()
}