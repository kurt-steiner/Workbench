package com.steiner.workbench.app.plugin

import com.steiner.workbench.todolist.enumeration.PriorityColor
import com.steiner.workbench.todolist.request.PostPriorityRequest
import com.steiner.workbench.todolist.request.PostTaskGroupRequest
import com.steiner.workbench.todolist.request.PostTaskProjectRequest
import com.steiner.workbench.todolist.request.PostTaskRequest
import io.ktor.server.application.*
import kotlinx.coroutines.runBlocking
import com.steiner.workbench.todolist.service.*
import org.koin.ktor.ext.inject

fun Application.configureInitialize() {
    val config = environment.config
    val isInitialize = config.property("app.initialize").getString().toBoolean()
    val priorityService: PriorityService by inject<PriorityService>()
    val tagService: TagService by inject<TagService>()
    val taskProjectService: TaskProjectService by inject<TaskProjectService>()
    val taskGroupService: TaskGroupService by inject<TaskGroupService>()
    val taskService: TaskService by inject<TaskService>()

    if (!isInitialize) {
        return
    }

    runBlocking {
        priorityService.clear()
        tagService.clear()
        taskProjectService.clear()
        taskGroupService.clear()
        taskService.clear()

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

    }
}