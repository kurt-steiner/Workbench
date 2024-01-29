package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`subtask-name-length`
import com.steiner.workbench.common.util.min

@Serializable
class PostSubTaskRequest(
    val parentid: Int,
    val name: String
) {
    fun validate(): ValidationResult {
        return listOf(
            min(data = parentid, value = 1),
            length(data = name, max = `subtask-name-length`)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}