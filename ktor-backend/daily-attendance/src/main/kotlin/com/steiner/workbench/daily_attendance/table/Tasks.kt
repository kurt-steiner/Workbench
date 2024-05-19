package com.steiner.workbench.daily_attendance.table

import com.steiner.workbench.common.`daily-attendance-encouragement-length`
import com.steiner.workbench.common.`daily-attendance-name-length`
import com.steiner.workbench.common.formatter
import com.steiner.workbench.daily_attendance.model.*
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.json.jsonb
import org.jetbrains.exposed.sql.kotlin.datetime.date

object Tasks: IntIdTable("daily-attendance-tasks") {
    val name = varchar("name", `daily-attendance-name-length`).uniqueIndex()
    val icon = jsonb<Icon>("icon", formatter)
    val encouragement = varchar("encouragement", `daily-attendance-encouragement-length`)
    val frequency = jsonb<Frequency>("frequency", formatter)
    val goal = jsonb<Goal>("goal", formatter)
    val startTime = date("start-time")
    val keepdays = jsonb<KeepDays>("keepdays", formatter)
    val group = enumeration<Group>("group")
    val notifyTimes = jsonb<Array<NotifyTime>>("notify-times", formatter)
    val progress = jsonb<Progress>("progress", formatter)
    val isarchived = bool("isarchived")
    val consecutiveDays = integer("consecutive-days")
    val persistenceDays = integer("persistence-days")
}