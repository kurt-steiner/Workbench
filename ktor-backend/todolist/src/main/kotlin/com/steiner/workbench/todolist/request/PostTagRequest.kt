package com.steiner.workbench.todolist.request

import com.steiner.workbench.common.util.length
import com.steiner.workbench.common.util.color as vColor
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable
import com.steiner.workbench.common.`tag-name-length`
import com.steiner.workbench.common.util.min

@Serializable
class PostTagRequest(
    val name: String,
    val parentid: Int,
    val color: String
) {
    fun validate(): ValidationResult {
        return listOf(
            length(data = name, max = `tag-name-length`),
            vColor(data = this.color),
            min(data = parentid, value = 1)
        ).firstOrNull {
            it is ValidationResult.Invalid
        } ?: ValidationResult.Valid
    }
}