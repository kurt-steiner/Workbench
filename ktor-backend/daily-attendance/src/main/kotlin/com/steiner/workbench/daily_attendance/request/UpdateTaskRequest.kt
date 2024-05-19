package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.common.`daily-attendance-encouragement-length`
import com.steiner.workbench.common.`daily-attendance-name-length`
import com.steiner.workbench.common.util.max
import com.steiner.workbench.common.util.min
import com.steiner.workbench.daily_attendance.model.*
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.datetime.LocalDate
import kotlinx.serialization.Serializable

@Serializable
class UpdateTaskRequest(
    val id: Int,
    val name: String?,
    val icon: Icon?,
    val encouragement: String?,
    val frequency: Frequency?,
    val goal: Goal?,
    val startTime: LocalDate?,
    val keepdays: KeepDays?,
    val group: Group?,
    val notifyTimes: Array<NotifyTime>?
) {
    fun validate(): ValidationResult = listOf(
        min(data = name?.length, value = 1),
        max(data = name?.length, value = `daily-attendance-name-length`),
        min(data = encouragement?.length, value = 1),
        max(data = encouragement?.length, value = `daily-attendance-encouragement-length`)
    ).firstOrNull {
        it is ValidationResult.Invalid
    } ?: ValidationResult.Valid
}