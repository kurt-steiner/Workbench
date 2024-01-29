package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import com.steiner.workbench.todolist.model.Priority
import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`task-name-length`
import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*

@Serializable
class UpdateTaskRequest(
    val id: Int,
    val name: String?,
    val isdone: Boolean?,
    val deadline: LocalDateTime?,
    val notifyTime: LocalDateTime?,
    val note: String?,
    val priority: Priority?,
    val expectTime: Int?,
    val finishTime: Int?,
    val parentid: Int?
) {
    fun validate() = listOf(
        min(data = id, value = 1),
        length(data = name, max = `task-name-length`)
    ).firstOrNull {
        it is ValidationResult.Invalid
    } ?: ValidationResult.Valid
}