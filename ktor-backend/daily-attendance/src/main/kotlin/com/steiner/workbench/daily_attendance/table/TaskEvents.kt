package com.steiner.workbench.daily_attendance.table

import com.steiner.workbench.common.formatter
import com.steiner.workbench.daily_attendance.model.Progress
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.json.jsonb
import org.jetbrains.exposed.sql.kotlin.datetime.datetime

object TaskEvents: IntIdTable("daily-attendance-taskevents") {
    val taskname = reference("taskname", Tasks.name, onDelete = ReferenceOption.CASCADE)
    val taskid = reference("taskid", Tasks, onDelete = ReferenceOption.CASCADE)
    val time = datetime("time")
    val progress = jsonb<Progress>("progress", formatter)
}