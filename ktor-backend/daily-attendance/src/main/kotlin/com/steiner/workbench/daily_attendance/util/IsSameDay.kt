package com.steiner.workbench.daily_attendance.util

import kotlinx.datetime.LocalDate

fun isSameDay(left: LocalDate, right: LocalDate): Boolean {
    return left.year == right.year && left.month == right.month && left.dayOfMonth == right.dayOfMonth
}