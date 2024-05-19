package com.steiner.workbench.daily_attendance.request

import com.steiner.workbench.common.util.min
import com.steiner.workbench.daily_attendance.model.Progress
import kotlinx.serialization.Serializable

@Serializable
class UpdateProgressRequest(
    val id: Int,
    val progress: Progress
) {
    fun validate() = min(data = id, value = 1)
}