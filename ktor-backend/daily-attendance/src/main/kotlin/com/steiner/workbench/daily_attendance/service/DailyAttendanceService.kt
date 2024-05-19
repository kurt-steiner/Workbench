package com.steiner.workbench.daily_attendance.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.common.util.mustExistIn
import com.steiner.workbench.common.util.now
import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.daily_attendance.request.PostTaskRequest
import com.steiner.workbench.daily_attendance.request.UpdateProgressRequest
import com.steiner.workbench.daily_attendance.request.UpdateTaskRequest
import com.steiner.workbench.daily_attendance.table.TaskEvents
import com.steiner.workbench.daily_attendance.table.Tasks
import com.steiner.workbench.daily_attendance.util.isSameDay
import com.steiner.workbench.daily_attendance.iterate.*
import com.steiner.workbench.daily_attendance.request.UpdateArchiveTaskRequest
import io.ktor.server.plugins.*
import kotlinx.datetime.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.greaterEq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.lessEq
import org.jetbrains.exposed.sql.kotlin.datetime.day
import org.jetbrains.exposed.sql.kotlin.datetime.month
import org.jetbrains.exposed.sql.kotlin.datetime.year
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import kotlin.math.abs

class DailyAttendanceService(val database: Database) {
    init {
        transaction(database) {
            SchemaUtils.create(Tasks)
            SchemaUtils.create(TaskEvents)
        }

    }

    companion object {
        val dayDistance = mapOf(
            DayOfWeek.MONDAY to 0,
            DayOfWeek.TUESDAY to 1,
            DayOfWeek.WEDNESDAY to 2,
            DayOfWeek.THURSDAY to 3,
            DayOfWeek.FRIDAY to 4,
            DayOfWeek.SATURDAY to 5,
            DayOfWeek.SUNDAY to 6
        )

        val logger: Logger = LoggerFactory.getLogger(DailyAttendanceService::class.java)
    }

    suspend fun insertOne(request: PostTaskRequest): Task = dbQuery(database) {
        val exist = with (Tasks) {
            selectAll().where(name eq request.name.trim()).firstOrNull() != null
        }

        if (exist) {
            throw BadRequestException("task name duplicated")
        }

        val id = with (Tasks) {
            insert {
                it[name] = request.name.trim()
                it[icon] = request.icon
                it[encouragement] = request.encouragement
                it[frequency] = request.frequency
                it[goal] = request.goal
                it[startTime] = request.startTime
                it[keepdays] = request.keepdays
                it[group] = request.group
                it[notifyTimes] = request.notifyTimes
                it[progress] = Progress.Ready
                it[isarchived] = false
                it[consecutiveDays] = 0
                it[persistenceDays] = 0
            } get this.id
        }

        findOne(id.value)!!
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        with (Tasks) {
            deleteWhere {
                this.id eq id
            }
        }

        with (TaskEvents) {
            deleteWhere {
                taskid eq id
            }
        }
    }

    suspend fun archive(id: Int) = dbQuery(database) {
        with (Tasks) {
            update({ this@with.id eq id}) {
                it[isarchived] = true
            }
        }
    }

    suspend fun restore(id: Int): Unit = dbQuery(database) {
        with (Tasks) {
            update({ this@with.id eq id}) {
                it[isarchived] = false
            }
        }
    }

    suspend fun resetTaskCurrentDay(taskid: Int): Task = dbQuery(database) {
        mustExistIn(taskid, Tasks)
        val currentDay = now()
        val currentDayLocalDate = currentDay.date

        with (Tasks) {
            val (progress, cday, pday) = selectAll().where(id eq taskid)
                .first()
                .let {
                    listOf(it[progress], it[consecutiveDays], it[persistenceDays])
                }

            if (progress is Progress.Done) {
                if (cday != 0) {
                    update({id eq taskid}) {
                        with (SqlExpressionBuilder) {
                            it.update(consecutiveDays, consecutiveDays - 1)
                        }
                    }
                }

                if (pday != 0) {
                    update({id eq taskid}) {
                        with (SqlExpressionBuilder) {
                            it.update(persistenceDays, persistenceDays - 1)
                        }
                    }
                }
            }

            update({id eq taskid}) {
                it[this.progress] = Progress.Ready
            }
        }

        with (TaskEvents) {
            val op = (this.taskid eq taskid) and
                    (time.year() eq currentDayLocalDate.year) and
                    (time.month() eq currentDayLocalDate.monthNumber) and
                    (time.day() eq currentDayLocalDate.dayOfMonth)

            deleteWhere {
                op
            }
        }

        findOne(taskid)!!
    }

    suspend fun updateOne(request: UpdateTaskRequest): Task = dbQuery(database) {
        mustExistIn(request.id, Tasks)

        with (Tasks) {
            update({id eq request.id}) {
                if (request.name != null) {
                    it[name] = request.name
                }

                if (request.icon != null) {
                    it[icon] = request.icon
                }

                if (request.encouragement != null) {
                    it[encouragement] = request.encouragement
                }

                if (request.frequency != null) {
                    it[frequency] = request.frequency
                }

                if (request.goal != null) {
                    it[goal] = request.goal
                }

                if (request.startTime != null) {
                    it[startTime] = request.startTime
                }

                if (request.keepdays != null) {
                    it[keepdays] = request.keepdays
                }

                if (request.group != null) {
                    it[group] = request.group
                }

                if (request.notifyTimes != null) {
                    it[notifyTimes] = request.notifyTimes
                }
            }
        }

        findOne(request.id)!!
    }

    suspend fun updateArchive(request: UpdateArchiveTaskRequest) = dbQuery(database) {
        mustExistIn(request.id, Tasks)
        with (Tasks) {
            update({id eq request.id}) {
                it[isarchived] = request.isarchive
            }
        }
    }

    suspend fun updateProgress(request: UpdateProgressRequest): Task = dbQuery(database) {
        mustExistIn(request.id, Tasks)

        var progress = request.progress
        if (progress is Progress.Doing && progress.amount >= progress.total) {
            progress = Progress.Done
        }

        with (Tasks) {
            update({id eq request.id}) {
                it[this.progress] = progress
            }
        }

        val now = now()
        val yesterday = LocalDate(now.year, now.monthNumber, now.dayOfMonth - 1)
        with (Tasks) {
            selectAll().where(id eq request.id)
                .first()
                .let {
                    val taskid = it[id].value
                    val taskname = it[name]

                    with (TaskEvents) {
                        insert {
                            it[this.taskid] = taskid
                            it[this.taskname] = taskname
                            it[time] = now
                            it[this.progress] = progress
                        }

                        val op = (this.taskid eq taskid) and
                                (time.year() eq yesterday.year) and
                                (time.month() eq yesterday.monthNumber) and
                                (time.day() eq yesterday.dayOfMonth)

                        val yesterDayProgress = selectAll().where(op)
                            .firstOrNull()?.let {
                                it[this.progress]
                            }

                        var cday = it[consecutiveDays]
                        var pday = it[persistenceDays]

                        if (yesterDayProgress != null) {
                            if (yesterDayProgress is Progress.Done && progress is Progress.Done) {
                                cday += 1
                                pday += 1
                            } else {
                                cday = 0
                            }
                        } else {
                            if (progress is Progress.Done) {
                                cday = 1
                                pday += 1
                            } else {
                                cday = 0
                            }
                        }

                        with (Tasks) {
                            update({ id eq taskid}) {
                                it[consecutiveDays] = cday
                                it[persistenceDays] = pday
                            }
                        }
                    }
                }
        }

        findOne(request.id)!!
    }

    suspend fun findOne(id: Int): Task? = dbQuery(database) {
        with (Tasks) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    Task(
                        id = id,
                        name = it[name],
                        icon = it[icon],
                        encouragement = it[encouragement],
                        frequency = it[frequency],
                        goal = it[goal],
                        startTime = it[startTime],
                        keepdays = it[keepdays],
                        group = it[group],
                        notifyTimes = it[notifyTimes],
                        progress = it[progress],
                        isarchived = it[isarchived],
                        consecutiveDays = it[consecutiveDays],
                        persistenceDays = it[persistenceDays]
                    )
                }
        }
    }

    // PROBLEM: filter 的时候忘了考虑 frequency
    suspend fun findAll(localdate: LocalDate): List<Task> = dbQuery(database) {
        with (Tasks) {
            val op = (isarchived eq false) and
                    (startTime lessEq localdate)
            selectAll().where(op)
                .filter {
                    when (val keepdays = it[keepdays]) {
                        is KeepDays.Forever -> true

                        is KeepDays.Manual -> {
                            val days = keepdays.days
                            val startTime = it[startTime]
                            val endTime = startTime.plus(DatePeriod(days = days))

                            endTime >= localdate
                        }
                    }
                }.map {
                    val taskEvents = findAllEventsUntilThisWeek(it[id].value, localdate)
                    val lastProgress = taskEvents.lastOrNull { event ->
                        event.time.run {
                            year == localdate.year &&
                                    month == localdate.month &&
                                    dayOfMonth == localdate.dayOfMonth
                        }
                    }?.progress ?: Progress.Ready

                    val progress = when (val frequency = it[frequency]) {
                        is Frequency.Days -> {
                            if (frequency.weekdays.contains(localdate.dayOfWeek)) {
                                lastProgress
                            } else {
                                Progress.NotScheduled
                            }
                        }

                        is Frequency.CountInWeek -> {
                            val count = taskEvents.count { event ->
                                event.progress == Progress.Done
                            }

                            if (count >= frequency.count) {
                                Progress.Done
                            } else {
                                lastProgress
                            }
                        }

                        is Frequency.Interval -> {
                            val lastEvent = findLastEventUntilThisDay(it[this.id].value, localdate)
                            val lastDate = lastEvent?.time?.date
                            val isScheduled: Boolean = if (lastDate != null) {
                                (lastDate..localdate step frequency.count).lastOrNull() == localdate
                            } else {
                                (it[startTime]..localdate step frequency.count).lastOrNull() == localdate
                            }

                            if (isScheduled) {
                                lastProgress
                            } else {
                                Progress.NotScheduled
                            }
                        }
                    }

                    Task(
                        id = it[id].value,
                        name = it[name],
                        icon = it[icon],
                        encouragement = it[encouragement],
                        frequency = it[frequency],
                        goal = it[goal],
                        startTime = it[startTime],
                        keepdays = it[keepdays],
                        group = it[group],
                        notifyTimes = it[notifyTimes],
                        progress = progress,
                        isarchived = it[isarchived],
                        consecutiveDays = it[consecutiveDays],
                        persistenceDays = it[persistenceDays]
                    )
                }
        }
    }


    suspend fun findLatest7Days(): Map<DayOfWeek, List<Task>> = dbQuery(database) {
        val currentDay = now()
        val currentDayLocalDate = currentDay.date
        val past6LocalDate = currentDayLocalDate.minus(DatePeriod(days = 6))
        val result = mutableMapOf<DayOfWeek, List<Task>>()

        (past6LocalDate..currentDayLocalDate).forEach {
            val value = findAll(it)
            val key = it.dayOfWeek
            result[key] = value
        }

        result
    }

    suspend fun refreshDataDaily() = dbQuery(database) {
        val currentDay = now()
        val currentDayLocalDate = currentDay.date

        with (Tasks) {
            selectAll().where((isarchived eq false) and (startTime lessEq currentDayLocalDate))
                .filter {
                    when (val keepdays = it[keepdays]) {
                        is KeepDays.Forever -> true
                        is KeepDays.Manual -> {
                            val startTime = it[startTime]
                            val endTime = startTime.plus(keepdays.days, DateTimeUnit.DAY)
                            endTime >= currentDayLocalDate
                        }
                    }
                }.forEach {
                    val id = it[id].value
                    val frequency = it[frequency]

                    update({this@with.id eq id}) {
                        it[progress] = Progress.Ready
                    }

                    when (frequency) {
                        is Frequency.Days -> {
                            if (!frequency.weekdays.contains(currentDayLocalDate.dayOfWeek)) {
                                update({Tasks.id eq id}) {
                                    it[progress] = Progress.NotScheduled
                                }
                            }
                        }

                        is Frequency.CountInWeek -> {
                            val count = frequency.count
                            val events = findAllEventsOfCurrentWeek(id)
                            val doneCount = events.count {
                                val task = findOne(it.taskid)!!
                                task.progress == Progress.Done
                            }

                            if (doneCount >= count) {
                                update({Tasks.id eq id}) {
                                    it[progress] = Progress.NotScheduled
                                }
                            }
                        }

                        is Frequency.Interval -> {
                            val taskEvent = findLastEventUntilThisDay(id, currentDayLocalDate)
                            val startTime = it[startTime]
                            val lastDate = taskEvent?.time?.date

                            val isScheduled: Boolean = if (lastDate != null) {
                                (lastDate..currentDayLocalDate step frequency.count).count { date ->
                                    isSameDay(date, currentDayLocalDate)
                                } > 0
                            } else {
                                (startTime..currentDayLocalDate step frequency.count).count { date ->
                                    isSameDay(date, currentDayLocalDate)
                                } > 0
                            }

                            update({Tasks.id eq id}) {
                                it[progress] = if (isScheduled) {
                                    Progress.Ready
                                } else {
                                    Progress.NotScheduled
                                }
                            }
                        }


                    }
                }
        }

    }

    suspend fun findAllEventsOfCurrentWeek(taskid: Int): List<TaskEvent> = dbQuery(database) {
        mustExistIn(taskid, Tasks)

        val currentDay = now()
        val currentDayLocalDate = currentDay.date

        val distance = dayDistance[currentDayLocalDate.dayOfWeek]!!
        val startOfWeek = LocalDateTime(
            year = currentDayLocalDate.year,
            monthNumber = currentDayLocalDate.monthNumber,
            dayOfMonth = currentDayLocalDate.dayOfMonth - distance,
            hour = 0,
            minute = 0
        )

        val endOfWeek = LocalDateTime(
            year = startOfWeek.year,
            monthNumber = startOfWeek.monthNumber,
            dayOfMonth = startOfWeek.dayOfMonth + 6,
            hour = 0,
            minute = 0
        )

        with (TaskEvents) {
            selectAll().where((
                    this.taskid eq taskid) and
                    (time greaterEq startOfWeek) and
                    (time lessEq endOfWeek)
            ).map {
                TaskEvent(
                    id = it[id].value,
                    taskid = it[this.taskid].value,
                    taskname = it[taskname],
                    time = it[time],
                    progress = it[progress]
                )
            }
        }
    }

    suspend fun findAllEventsUntilThisWeek(taskid: Int, localdate: LocalDate): List<TaskEvent> = dbQuery(database) {
        mustExistIn(taskid, Tasks)

        val distance = dayDistance[localdate.dayOfWeek]!!
        val startOfWeek = localdate.minus(distance, DateTimeUnit.DAY).let {
            LocalDateTime(
                year = it.year,
                monthNumber = it.monthNumber,
                dayOfMonth = it.dayOfMonth,
                hour = 0,
                minute = 0
            )
        }

        val localDateTime = LocalDateTime(
            year = localdate.year,
            monthNumber = localdate.monthNumber,
            dayOfMonth = localdate.dayOfMonth,
            hour = 0,
            minute = 0
        )

        with (TaskEvents) {
            selectAll().where((this.taskid eq taskid) and (time greaterEq startOfWeek) and (time lessEq localDateTime))
                .map {
                    TaskEvent(
                        id = it[id].value,
                        taskid = it[this.taskid].value,
                        taskname = it[taskname],
                        time = it[time],
                        progress = it[progress]
                    )
                }
        }
    }

    suspend fun findLastEventUntilThisDay(taskid: Int, localdate: LocalDate): TaskEvent? = dbQuery(database) {
        val localDateTime = LocalDateTime(
            year = localdate.year,
            monthNumber = localdate.monthNumber,
            dayOfMonth = localdate.dayOfMonth,
            hour = 0,
            minute = 0
        )

        with (TaskEvents) {
            val op = (this.taskid eq taskid) and
                    (time lessEq localDateTime)

            selectAll().where(op).lastOrNull()?.let {
                TaskEvent(
                    id = it[id].value,
                    taskid = it[this.taskid].value,
                    taskname = it[taskname],
                    time = it[time],
                    progress = it[progress]
                )
            }
        }
    }

    suspend fun findAllAvailable(isarchive: Boolean): List<Task> = dbQuery(database) {
        with (Tasks) {
            selectAll().where(this.isarchived eq isarchive)
                .map {
                    findOne(it[id].value)!!
                }
        }
    }

    suspend fun statisticsThisWeek(offset: Int): Map<Int, Map<DayOfWeek, Progress>> = dbQuery(database) {
        assert(offset <= 0)

        val currentLocalDate = now().date
        val distance = dayDistance[currentLocalDate.dayOfWeek]!!
        val startOfWeek = currentLocalDate.minus(distance, DateTimeUnit.DAY)
        val startOfThisWeek = startOfWeek.minus(abs(offset), DateTimeUnit.WEEK)
        val endOfThisWeek = startOfThisWeek.plus(6, DateTimeUnit.DAY)

        val progressRecord = mutableMapOf<Int, MutableMap<DayOfWeek, Progress>>()
        (startOfThisWeek..endOfThisWeek).forEach { date ->
            val tasks = findAll(date)
            for (task in tasks) {
                if (progressRecord.containsKey(task.id)) {
                    progressRecord[task.id]!![date.dayOfWeek] = task.progress
                } else {
                    progressRecord[task.id] = mutableMapOf(date.dayOfWeek to task.progress)
                }
            }
        }


        progressRecord
    }

    suspend fun statisticsThisMonth(offset: Int): Map<Int, Map<Int, Progress>> = dbQuery(database) {
        assert(offset <= 0)

        val currentLocalDate = now().date
        val startOfMonth = LocalDate(currentLocalDate.year, currentLocalDate.monthNumber, 1)
        val thisMonth = startOfMonth.minus(abs(offset), DateTimeUnit.MONTH)
        val endOfMonth = thisMonth.plus(1, DateTimeUnit.MONTH).minus(1, DateTimeUnit.DAY)

        val progressRecord = mutableMapOf<Int, MutableMap<Int, Progress>>()
        (thisMonth..endOfMonth).forEach { date ->
            val tasks = findAll(date)
            for (task in tasks) {
                if (progressRecord.containsKey(task.id)) {
                    progressRecord[task.id]!![date.dayOfMonth] = task.progress
                } else {
                    progressRecord[task.id] = mutableMapOf(date.dayOfMonth to task.progress)
                }
            }
        }

        progressRecord
    }

    suspend fun clear() = dbQuery(database) {
        Tasks.deleteAll()
        TaskEvents.deleteAll()
    }
}