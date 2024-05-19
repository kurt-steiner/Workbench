package com.steiner.workbench.app.plugin

import com.steiner.workbench.common.util.FlatUIColor
import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.daily_attendance.model.*
import com.steiner.workbench.daily_attendance.service.DailyAttendanceService
import com.steiner.workbench.todolist.enumeration.PriorityColor
import com.steiner.workbench.todolist.request.PostPriorityRequest
import com.steiner.workbench.todolist.request.PostTaskGroupRequest
import com.steiner.workbench.todolist.request.PostTaskProjectRequest
import com.steiner.workbench.todolist.request.PostTaskRequest
import com.steiner.workbench.daily_attendance.request.PostTaskRequest as daPostTaskRequest
import io.ktor.server.application.*
import kotlinx.coroutines.runBlocking
import com.steiner.workbench.todolist.service.*
import kotlinx.datetime.DateTimeUnit
import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate
import kotlinx.datetime.plus
import org.koin.ktor.ext.inject

fun Application.configureInitialize() {
    val config = environment.config
    val isInitialize = config.property("app.initialize").getString().toBoolean()

    val priorityService: PriorityService by inject<PriorityService>()
    val tagService: TagService by inject<TagService>()
    val taskProjectService: TaskProjectService by inject<TaskProjectService>()
    val taskGroupService: TaskGroupService by inject<TaskGroupService>()
    val taskService: TaskService by inject<TaskService>()
    val dailyAttendanceService: DailyAttendanceService by inject<DailyAttendanceService>()

    if (!isInitialize) {
        return
    }

    runBlocking {
        priorityService.clear()
        tagService.clear()
        taskProjectService.clear()
        taskGroupService.clear()
        taskService.clear()
        dailyAttendanceService.clear()

        val taskProjectRequest = PostTaskProjectRequest(
            name = "hello",
            avatarid = null,
            profile = null
        )

        val taskProject = taskProjectService.insertOne(taskProjectRequest)

        val priorityRequest = PostPriorityRequest(
            name = "普通",
            parentid = taskProject.id,
            order = 2,
            color = PriorityColor.Blue
        )

        val priority = priorityService.insertOne(priorityRequest)

        val taskGroupRequests = listOf(
            PostTaskGroupRequest(
                parentid = taskProject.id,
                name = "taskgroup1",
            ),

            PostTaskGroupRequest(
                parentid = taskProject.id,
                name = "taskgroup2",
            ),
        )

        taskGroupRequests.forEach { request ->
            val taskGroup = taskGroupService.insertOne(request)

            listOf(
                PostTaskRequest(
                    name = "task1",
                    parentid = taskGroup.id,
                    deadline = null,
                    expectTime = 4,
                    note = null,
                    notifyTime = null,
                    priority = priority
                ),

                PostTaskRequest(
                    name = "task2",
                    parentid = taskGroup.id,
                    deadline = null,
                    expectTime = 4,
                    note = null,
                    notifyTime = null,
                    priority = priority
                ),

                PostTaskRequest(
                    name = "task3",
                    parentid = taskGroup.id,
                    deadline = null,
                    expectTime = 4,
                    note = null,
                    notifyTime = null,
                    priority = priority
                ),

                PostTaskRequest(
                    name = "task4",
                    parentid = taskGroup.id,
                    deadline = null,
                    expectTime = 4,
                    note = null,
                    notifyTime = null,
                    priority = priority
                )
            ).reversed().forEach {
                taskService.insertOne(it)
            }


        }

        val currentDayLocalDate = LocalDate(2023, 11, 1)
        listOf(
            daPostTaskRequest(
                name = "背单词",
                encouragement = "学习一门语言当然要背单词啦",
                frequency = Frequency.Interval(2),
                goal = Goal.Amount(5, "页", 1),
                group = Group.Afternoon,
                icon = Icon.Word(char = '你', color = FlatUIColor.Orange),
                keepdays = KeepDays.Forever,
                startTime = currentDayLocalDate,
                notifyTimes = arrayOf(NotifyTime(13, 0)),
            ),

            daPostTaskRequest(
                name = "阅读",
                encouragement = "有空看看书，说不定会有新收获",
                frequency = Frequency.Days(arrayOf(DayOfWeek.MONDAY, DayOfWeek.TUESDAY, DayOfWeek.WEDNESDAY, DayOfWeek.THURSDAY, DayOfWeek.FRIDAY, DayOfWeek.SATURDAY, DayOfWeek.SUNDAY)),
                goal = Goal.CurrentDay,
                group = Group.Night,
                icon = Icon.Word(char = '好', color = FlatUIColor.Coral),
                keepdays = KeepDays.Forever,
                startTime = currentDayLocalDate.plus(1, DateTimeUnit.DAY),
                notifyTimes = arrayOf(NotifyTime(20, 0)),
            ),

            daPostTaskRequest(
                name = "吃水果",
                encouragement = "饭后来电水果就更棒了",
                frequency = Frequency.CountInWeek(2),
                goal = Goal.CurrentDay,
                group = Group.Other,
                icon = Icon.Word(char = '世', color = FlatUIColor.Peace),
                keepdays = KeepDays.Forever,
                startTime = currentDayLocalDate.plus(2, DateTimeUnit.DAY),
                notifyTimes = arrayOf(),
            ),

            daPostTaskRequest(
                name = "吃药",
                encouragement = "别忘了按时吃药",
                frequency = Frequency.CountInWeek(2),
                goal = Goal.CurrentDay,
                group = Group.Other,
                icon = Icon.Word(char = '界', color = FlatUIColor.LimeSoap),
                keepdays = KeepDays.Forever,
                startTime = currentDayLocalDate.plus(2, DateTimeUnit.DAY),
                notifyTimes = arrayOf(),
            ),
        ).forEach {
            dailyAttendanceService.insertOne(it)
        }

    }

}