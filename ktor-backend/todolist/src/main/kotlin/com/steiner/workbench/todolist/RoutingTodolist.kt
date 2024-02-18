package com.steiner.workbench.todolist

import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.todolist.request.*
import com.steiner.workbench.todolist.service.*
import com.steiner.workbench.websocket.endpoint.WebSocketEndpoint
import com.steiner.workbench.websocket.model.Operation
import io.ktor.server.plugins.*
import io.ktor.util.pipeline.*
import org.koin.ktor.ext.inject

fun Application.routingTodolist() {
    val tagService: TagService by inject<TagService>()
    val subTaskService: SubTaskService by inject<SubTaskService>()
    val taskService: TaskService by inject<TaskService>()
    val taskGroupService: TaskGroupService by inject<TaskGroupService>()
    val taskProjectService: TaskProjectService by inject<TaskProjectService>()
    val priorityService: PriorityService by inject<PriorityService>()

    routing {
        route("/todolist/priority") {

            post {
                val request = call.receive<PostPriorityRequest>()
                val priority = priorityService.insertOne(request)
                call.respond(Response.Ok("insert ok", priority))

                WebSocketEndpoint.notifyFrom(uid(), Operation.PriorityPost(parentid = priority.parentid))
            }

            delete("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val priority = priorityService.findOne(id)!!
                priorityService.deleteOne(id)
                call.respond(Response.Ok("delete ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.PriorityDelete(parentid = priority.parentid, id = priority.id))
            }

            put {
                val request = call.receive<UpdatePriorityRequest>()
                val priority = priorityService.updateOne(request)
                call.respond(Response.Ok("update ok", priority))

                WebSocketEndpoint.notifyFrom(uid(), Operation.PriorityUpdate(id = priority.id))
            }

            get("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val result = priorityService.findOne(id)!!
                call.respond(Response.Ok("this priority", result))
            }

            get {
                val taskid = call.request.queryParameters["parentid"]?.toIntOrNull() ?: throw NotFoundException("expect parentid")
                val result = priorityService.findAll(taskid)
                call.respond(Response.Ok("these priority", result))
            }
        }

        route("/todolist/tag") {
            post {
                val request = call.receive<PostTagRequest>()
                val tag = tagService.insertOne(request)
                call.respond(Response.Ok("insert ok", tag))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TagPost(parentid = tag.parentid))
            }

            delete("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                tagService.deleteOne(id)

                call.respond(Response.Ok("delete ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TagDelete(id = id))
            }

            put {
                val request = call.receive<UpdateTagRequest>()
                call.respond(Response.Ok("update ok", tagService.updateOne(request)))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TagUpdate(id = request.id))
            }

            get {
                val parentid = call.request.queryParameters["parentid"]?.toIntOrNull() ?: throw NotFoundException("expect parentid")
                call.respond(Response.Ok("all tags", tagService.findAll(parentid)))
            }
        }

        route("/todolist/subtask") {
            post {
                val request = call.receive<PostSubTaskRequest>()
                val subtask = subTaskService.insertOne(request)
                call.respond(Response.Ok("insert ok", subtask))


                WebSocketEndpoint.notifyFrom(uid(), Operation.SubTaskPost(parentid = subtask.parentid))
            }

            delete("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val subtask = subTaskService.findOne(id)!!
                subTaskService.deleteOne(id)
                call.respond(Response.Ok("delete ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.SubTaskDelete(parentid = subtask.parentid, id = subtask.id))
            }

            put {
                val request = call.receive<UpdateSubTaskRequest>()
                val subtask = subTaskService.findOne(request.id)!!
                call.respond(Response.Ok("update ok", subTaskService.updateOne(request)))

                WebSocketEndpoint.notifyFrom(uid(), Operation.SubTaskUpdate(parentid = subtask.parentid, id = request.id))
            }
        }

        route("/todolist/task") {
            post {
                val request = call.receive<PostTaskRequest>()

                val result = taskService.insertOne(request)

                call.respond(Response.Ok("insert ok", result))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskPost(parentid = result.parentid))
            }

            post("/tag") {
                val request = call.receive<PostTaskTagRequest>()
                val task = taskService.findOne(request.taskid)!!

                taskService.insertTag(request)

                call.respond(Response.Ok("insert tag ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskUpdate(parentid = task.parentid, id = task.id))
            }

            delete("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val task = taskService.findOne(id)!!

                taskService.deleteOne(id)
                call.respond(Response.Ok("delete ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskDelete(parentid = task.parentid, id = task.id))
            }

            delete("/deadline/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val task = taskService.findOne(id)!!
                taskService.removeDeadline(id)

                call.respond(Response.Ok("remove deadline ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskUpdate(parentid = task.parentid, id = task.id))
            }

            delete("/tag") {
                val taskid = call.request.queryParameters["taskid"]?.toIntOrNull()
                    ?: throw NotFoundException("expect taskid")
                val tagid = call.request.queryParameters["tagid"]?.toIntOrNull()
                    ?: throw NotFoundException("expect tagid")
                val task = taskService.findOne(taskid)!!
                taskService.removeTag(taskid, tagid)

                call.respond(Response.Ok("remove tag ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskUpdate(parentid = task.parentid, id = task.id))
            }

            delete("/notify-time/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val task = taskService.findOne(id)!!

                taskService.removeNotifyTime(id)

                call.respond(Response.Ok("remove notify time ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskUpdate(parentid = task.parentid, id = task.id))
            }

            delete("/note/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val task = taskService.findOne(id)!!
                taskService.removeNote(id)

                call.respond(Response.Ok("remove note ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskUpdate(parentid = task.parentid, id = task.id))
            }
            put {
                val request = call.receive<UpdateTaskRequest>()
                val result = taskService.updateTask(request)
                val task = taskService.findOne(request.id)!!

                call.respond(Response.Ok("update ok", result))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskUpdate(parentid = task.parentid, id = task.id))
            }

            put("/reorder") {
                val request = call.receive<ReorderRequest>()
                taskService.reorder(request)
                call.respond(Response.Ok("reorder ok", Unit))
            }

            get("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val result = taskService.findOne(id)!!
                call.respond(Response.Ok("this task", result))
            }

        }

        route("/todolist/taskgroup") {
            post {
                val request = call.receive<PostTaskGroupRequest>()
                val result = taskGroupService.insertOne(request)

                call.respond(Response.Ok("insert ok", result))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskGroupPost(parentid = result.parentid))
            }

            delete("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val taskGroup = taskGroupService.findOne(id)!!
                taskGroupService.deleteOne(id)

                call.respond(Response.Ok("delete ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskDelete(parentid = taskGroup.parentid, id = taskGroup.id))
            }

            put {
                val request = call.receive<UpdateTaskGroupRequest>()
                val result = taskGroupService.updateOne(request)

                call.respond(Response.Ok("update ok", result))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskUpdate(parentid = result.parentid, id = result.id))
            }

            put("/reorder") {
                val request = call.receive<ReorderRequest>()

                taskGroupService.reorder(request)
                call.respond(Response.Ok("reorder ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskGroupReorder(id = request.id, reorderAfter = request.reorderAfter))
            }

            get {
                val parentid = call.request.queryParameters["parentid"]?.toIntOrNull() ?: throw NotFoundException("expect parentid")
                call.respond(Response.Ok("all taskgroup", taskGroupService.findAll(parentid)))
            }

            get("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val result = taskGroupService.findOne(id)!!
                call.respond(Response.Ok("this taskgroup", result))
            }

        }

        route("/todolist/taskproject") {
            post {
                val request = call.receive<PostTaskProjectRequest>()
                val result = taskProjectService.insertOne(request)

                call.respond(Response.Ok("insert ok", result))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskProjectPost)
            }

            delete("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                taskProjectService.deleteOne(id)

                call.respond(Response.Ok("delete ok", Unit))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskProjectDelete(id = id))
            }

            put {
                val request = call.receive<UpdateTaskProjectRequest>()
                val result = taskProjectService.updateOne(request)

                call.respond(Response.Ok("update ok", result))

                WebSocketEndpoint.notifyFrom(uid(), Operation.TaskProjectUpdate(id = request.id))
            }

            get {
                val result = taskProjectService.findAll()

                call.respond(Response.Ok("all task projects", result))
            }

            get("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val result = taskProjectService.findOne(id)!!
                call.respond(Response.Ok("this task project", result))
            }
        }

    }
}

fun PipelineContext<Unit, ApplicationCall>.uid(): String {
    return call.request.header("uid")!!
}
