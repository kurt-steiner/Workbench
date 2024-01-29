package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`task-project-name-length`
import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*

@Serializable
class UpdateTaskProjectRequest(
    val id: Int,
    val name: String?,
    val avatarid: Int?,
    val profile: String?
) {
    fun validate() = listOf(
        min(data = id, value = 1),
        length(data = name, max = `task-project-name-length`),
        min(data = avatarid, value = 1)
    ).firstOrNull {
        it is ValidationResult.Invalid
    } ?: ValidationResult.Valid
}