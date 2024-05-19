package com.steiner.workbench.daily_attendance.model

import kotlinx.datetime.LocalDateTime

class TaskEvent(
    val id: Int,
    val taskname: String,
    val taskid: Int,
    val time: LocalDateTime,
    val progress: Progress
)