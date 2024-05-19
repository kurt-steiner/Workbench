package com.steiner.workbench.daily_attendance

import com.steiner.workbench.common.util.Response
import com.steiner.workbench.common.util.now
import com.steiner.workbench.common.util.uid
import com.steiner.workbench.daily_attendance.request.PostTaskRequest
import com.steiner.workbench.daily_attendance.request.UpdateArchiveTaskRequest
import com.steiner.workbench.daily_attendance.request.UpdateProgressRequest
import com.steiner.workbench.daily_attendance.request.UpdateTaskRequest
import com.steiner.workbench.daily_attendance.service.DailyAttendanceService
import com.steiner.workbench.websocket.endpoint.WebSocketEndpoint
import com.steiner.workbench.websocket.model.Operation
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.koin.ktor.ext.inject

fun Application.routingDailyAttendance() {
    val service: DailyAttendanceService by inject<DailyAttendanceService>()

    routing {
        route("/daily-attendance") {
            post {
                val request = call.receive<PostTaskRequest>()
                val result = service.insertOne(request)

                call.respond(Response.Ok("insert ok", result))
                WebSocketEndpoint.notifyFrom(uid(), Operation.DailyAttendancePost)
            }

            put {
                val request = call.receive<UpdateTaskRequest>()
                val result = service.updateOne(request)

                call.respond(Response.Ok("update ok", result))
                WebSocketEndpoint.notifyFrom(uid(), Operation.DailyAttendanceUpdate(id = request.id))
            }

            put("/progress") {
                val request = call.receive<UpdateProgressRequest>()
                val result = service.updateProgress(request)

                call.respond(Response.Ok("update progress ok", result))
                WebSocketEndpoint.notifyFrom(uid(), Operation.DailyAttendanceUpdate(id = request.id))
            }

            put("/archive") {
                val request = call.receive<UpdateArchiveTaskRequest>()
                service.updateArchive(request)

                call.respond(Response.Ok("update archive ok", Unit))
                WebSocketEndpoint.notifyFrom(uid(), Operation.DailyAttendanceArchive(id = request.id, archive = request.isarchive))
            }

            delete("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                service.deleteOne(id)
                call.respond(Response.Ok("delete ok", Unit))
                WebSocketEndpoint.notifyFrom(uid(), Operation.DailyAttendanceDelete(id = id))
            }

            get("/current-day") {
                val now = now().date
                call.respond(Response.Ok("all daily attendance", service.findAll(now)))
            }

            get("/current-7") {
                call.respond(Response.Ok("all daily attendance", service.findLatest7Days()))
            }

            get("/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val item = service.findOne(id) ?: throw NotFoundException("no such item")
                call.respond(Response.Ok("this daily attendance", item))
            }

            get {
                val isarchive = if (call.request.queryParameters["isarchived"]?.toBoolean() == true) {
                    true
                } else {
                    false
                }

                call.respond(
                    Response.Ok(
                        "all available",
                        service.findAllAvailable(isarchive)
                    )
                )

            }

            put("/reset/{id}") {
                val id = call.parameters["id"]!!.toInt()
                val result = service.resetTaskCurrentDay(id)
                WebSocketEndpoint.notifyFrom(uid(), Operation.DailyAttendanceUpdate(id = id))
                call.respond(Response.Ok("reset ok", result))
            }

            get("/statistics/week") {
                val offset = call.request.queryParameters["offset"]?.toInt() ?: 0
                call.respond(Response.Ok("statistics weekly", service.statisticsThisWeek(offset)))
            }

            get("/statistics/month") {
                val offset = call.request.queryParameters["offset"]?.toInt() ?: 0
                call.respond(Response.Ok("statistics monthly", service.statisticsThisMonth(offset)))
            }
        }
    }
}