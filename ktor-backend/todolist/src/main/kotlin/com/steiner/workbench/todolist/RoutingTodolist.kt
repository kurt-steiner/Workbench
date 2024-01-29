package com.steiner.workbench.todolist

import com.steiner.workbench.common.`normal-jwt`
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.login.principal.IdPrincipal
import com.steiner.workbench.login.service.UserService
import com.steiner.workbench.todolist.request.*
import com.steiner.workbench.todolist.service.*
import io.ktor.server.auth.*
import io.ktor.server.plugins.*
import org.koin.ktor.ext.inject

fun Application.routingTodolist() {
    val tagService: TagService by inject<TagService>()
    val subTaskService: SubTaskService by inject<SubTaskService>()
    val taskService: TaskService by inject<TaskService>()
    val taskGroupService: TaskGroupService by inject<TaskGroupService>()
    val taskProjectService: TaskProjectService by inject<TaskProjectService>()
    val priorityService: PriorityService by inject<PriorityService>()

    routing {
        authenticate(`normal-jwt`) {
            route("/todolist/priority") {
                post {
                    val request = call.receive<PostPriorityRequest>()
                    call.respond(Response.Ok("insert ok", priorityService.insertOne(request)))
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    priorityService.deleteOne(id)
                    call.respond(Response.Ok("delete ok", Unit))
                }

                put {
                    val request = call.receive<UpdatePriorityRequest>()
                    call.respond(Response.Ok("update ok", priorityService.updateOne(request)))
                }

                get("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val result = priorityService.findOne(id)!!
                    call.respond(Response.Ok("this priority", result))
                }

                get {
                    val taskid = call.request.queryParameters["taskid"]?.toIntOrNull() ?: throw NotFoundException("expect taskid")
                    val result = priorityService.findAll(taskid)
                    call.respond(Response.Ok("these priority", result))
                }
            }

            route("/todolist/tag") {
                post {
                    val request = call.receive<PostTagRequest>()
                    call.respond(Response.Ok("insert ok", tagService.insertOne(request)))
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    tagService.deleteOne(id)

                    call.respond(Response.Ok("delete ok", Unit))
                }

                put {
                    val request = call.receive<UpdateTagRequest>()
                    call.respond(Response.Ok("update ok", tagService.updateOne(request)))
                }

                get {
                    val parentid = call.request.queryParameters["parentid"]?.toIntOrNull() ?: throw NotFoundException("expect parentid")
                    call.respond(Response.Ok("all tags", tagService.findAll(parentid)))
                }
            }

            route("/todolist/subtask") {
                post {
                    val request = call.receive<PostSubTaskRequest>()
                    call.respond(Response.Ok("insert ok", subTaskService.insertOne(request)))
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    subTaskService.deleteOne(id)
                    call.respond(Response.Ok("delete ok", Unit))
                }

                put {
                    val request = call.receive<UpdateSubTaskRequest>()
                    call.respond(Response.Ok("update ok", subTaskService.updateOne(request)))
                }
            }

            route("/todolist/task") {
                post {
                    val request = call.receive<PostTaskRequest>()
                    val taskgroup = taskGroupService.findOne(request.parentid)!!

                    val result = taskService.insertOne(request)

                    call.respond(Response.Ok("insert ok", result))
                }

                post("/tag") {
                    val request = call.receive<PostTaskTagRequest>()
                    val task = taskService.findOne(request.taskid)!!

                    val taskgroup = taskGroupService.findOne(task.parentid)!!

                    taskService.insertTag(request)

                    call.respond(Response.Ok("insert tag ok", Unit))
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val task = taskService.findOne(id)!!
                    val taskgroup = taskGroupService.findOne(task.parentid)!!

                    taskService.deleteOne(id)
                    call.respond(Response.Ok("delete ok", Unit))
                }

                delete("/deadline/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val task = taskService.findOne(id)!!
                    val taskgroup = taskGroupService.findOne(task.parentid)!!

                    taskService.removeDeadline(id)

                    call.respond(Response.Ok("remove deadline ok", Unit))
                }

                delete("/tag") {
                    val taskid = call.request.queryParameters["taskid"]?.toIntOrNull()
                        ?: throw NotFoundException("expect taskid")
                    val tagid = call.request.queryParameters["tagid"]?.toIntOrNull()
                        ?: throw NotFoundException("expect tagid")
                    val task = taskService.findOne(taskid)!!
                    val taskgroup = taskGroupService.findOne(task.parentid)!!
                    taskService.removeTag(taskid, tagid)

                    call.respond(Response.Ok("remove tag ok", Unit))
                }

                delete("/notify-time/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val task = taskService.findOne(id)!!
                    val taskgroup = taskGroupService.findOne(task.parentid)!!

                    taskService.removeNotifyTime(id)

                    call.respond(Response.Ok("remove notify time ok", Unit))
                }

                put {
                    val request = call.receive<UpdateTaskRequest>()
                    val result = taskService.updateTask(request)
                    val task = taskService.findOne(request.id)!!

                    val taskgroup = taskGroupService.findOne(task.parentid)!!

                    call.respond(Response.Ok("update ok", result))
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
                    val taskProject = taskProjectService.findOne(result.parentid)!!

                    call.respond(Response.Ok("insert ok", result))
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    val taskGroup = taskGroupService.findOne(id)!!
                    taskGroupService.deleteOne(id)

                    call.respond(Response.Ok("delete ok", Unit))
                }

                put {
                    val request = call.receive<UpdateTaskGroupRequest>()
                    val result = taskGroupService.updateOne(request)
                    val taskProject = taskProjectService.findOne(result.parentid)!!
                    call.respond(Response.Ok("update ok", result))
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
                }

                delete("/{id}") {
                    val id = call.parameters["id"]!!.toInt()
                    taskProjectService.deleteOne(id)

                    call.respond(Response.Ok("delete ok", Unit))
                }

                put {
                    val request = call.receive<UpdateTaskProjectRequest>()
                    val result = taskProjectService.updateOne(request)

                    call.respond(Response.Ok("update ok", result))
                }

                get {
                    val principal = call.principal<IdPrincipal>()!!
                    val userid = principal.id
                    val result = taskProjectService.findAll(userid)

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
}