package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`task-group-name-length`
import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*

@Serializable
class UpdateTaskGroupRequest(
    val id: Int,
    val name: String
) {
    fun validate() = listOf(
        min(data = id, value = 1),
        length(data = name, max = `task-group-name-length`)
    ).firstOrNull {
        it is ValidationResult.Invalid
    } ?: ValidationResult.Valid
}