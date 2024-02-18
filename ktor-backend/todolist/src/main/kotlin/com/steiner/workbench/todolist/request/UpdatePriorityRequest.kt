package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`priority-name-length`
import com.steiner.workbench.todolist.enumeration.PriorityColor

@Serializable
class UpdatePriorityRequest(
    val id: Int,
    val name: String?,
    val order: Int?,
    val color: PriorityColor?
) {
    fun validate(): ValidationResult {
        return listOf(
            min(data = id, value = 1),
            min(data = order, value = 0),
            length(data = name, max = `priority-name-length`)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}