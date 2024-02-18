package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable

@Serializable
class ReorderRequest(
    val id: Int,
    val reorderAfter: Int,
    val parentid: Int?
) {
    fun validate(): ValidationResult {
        return listOf(
            min(data = id, value = 1),
            min(data = reorderAfter, value = 0),
            min(data = parentid, value = 1)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}