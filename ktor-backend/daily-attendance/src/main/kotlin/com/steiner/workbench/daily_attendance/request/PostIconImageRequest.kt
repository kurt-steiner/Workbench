package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.common.util.FlatUIColor
import com.steiner.workbench.common.util.min
import io.ktor.server.plugins.requestvalidation.*
import kotlinx.serialization.Serializable

@Serializable
class PostIconImageRequest(
    val entryId: Int,
    val backGroundId: Int,
    val backGroundColor: FlatUIColor
) {
    fun validate(): ValidationResult = listOf(
        min(data = entryId, value = 1),
        min(data = backGroundId, value = 1)
    ).firstOrNull {
        it is ValidationResult.Invalid
    } ?: ValidationResult.Valid
}