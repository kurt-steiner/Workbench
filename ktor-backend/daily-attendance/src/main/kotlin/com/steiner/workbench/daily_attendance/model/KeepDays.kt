package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class KeepDays {
    @Serializable
    @SerialName("forever")
    object Forever: KeepDays()

    @Serializable
    @SerialName("manual")
    class Manual(val days: Int): KeepDays()

}