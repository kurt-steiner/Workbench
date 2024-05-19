package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Goal {
    @Serializable
    @SerialName("current-day")
    object CurrentDay: Goal()

    @Serializable
    @SerialName("amount")
    class Amount(val total: Int, val unit: String, val eachAmount: Int): Goal()
}