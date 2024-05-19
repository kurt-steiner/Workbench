package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.common.util.min
import kotlinx.serialization.Serializable

@Serializable
class UpdateArchiveTaskRequest(
    val id: Int,
    val isarchive: Boolean
) {
    fun validate() = min(data = id, value = 1)
}