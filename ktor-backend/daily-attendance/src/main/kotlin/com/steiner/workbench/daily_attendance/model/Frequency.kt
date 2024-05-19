package com.steiner.workbench.daily_attendance.model

import kotlinx.datetime.DayOfWeek
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Frequency {
    @Serializable
    @SerialName("days")
    class Days(val weekdays: Array<DayOfWeek>): Frequency()

    @Serializable
    @SerialName("count-in-week")
    class CountInWeek(val count: Int): Frequency()

    @Serializable
    @SerialName("interval")
    class Interval(val count: Int): Frequency()
}