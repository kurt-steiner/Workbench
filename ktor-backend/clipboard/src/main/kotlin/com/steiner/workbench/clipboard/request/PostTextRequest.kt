package com.steiner.workbench.clipboard.request

import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable

@Serializable
class PostTextRequest(
    val text: String
) {
    fun validate(): ValidationResult {
        return if (text.isEmpty()) {
            ValidationResult.Invalid("text cannot be empty")
        } else {
            ValidationResult.Valid
        }
    }
}