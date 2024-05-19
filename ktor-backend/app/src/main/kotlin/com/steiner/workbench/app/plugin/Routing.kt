package com.steiner.workbench.app.plugin

import com.steiner.workbench.clipboard.routingClipboard
import com.steiner.workbench.common.model.ImageItem
import com.steiner.workbench.common.service.ImageItemService
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.common.util.urljoin
import com.steiner.workbench.daily_attendance.routingDailyAttendance
import com.steiner.workbench.todolist.routingTodolist
import com.steiner.workbench.websocket.routingWebSocket
import io.ktor.http.*
import io.ktor.http.content.*
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.koin.ktor.ext.inject
import java.io.File
import java.util.*

fun Application.configureRouting() {
    val imageItemService: ImageItemService by inject<ImageItemService>()
    val imageFolderPath = environment.config.property("app.storage.image-url").getString()

    intercept(ApplicationCallPipeline.Call) {
        val uid = call.request.headers["uid"]
        if (call.request.path().contains("/image/download")) {
            return@intercept
        } else {
            uid ?: throw BadRequestException("no uid field in the request header")
        }
    }

    /// routing of image items
    routing {
        route("image") {
            post("/upload") {
                val data = call.receiveMultipart()
                var result: ImageItem? = null
                data.forEachPart { part ->
                    if (part is PartData.FileItem) {
                        part.streamProvider().use { input ->
                            val filename = "${UUID.randomUUID().toString().slice(1..16)}_${part.originalFileName ?: "untitled"}"
                            val filepath = imageFolderPath.urljoin(filename)

                            result = imageItemService.insertOne(filename, filepath)
                            val file = File(filepath)
                            input.transferTo(file.outputStream())
                            input.close()
                        }

                        return@forEachPart
                    }
                }

                call.respond(Response.Ok("insert ok", result!!))
            }

            get("/download/{id}") {
                val id = call.parameters["id"]?.toIntOrNull()
                if (id == null) {
                    throw NotFoundException("no such image item with id $id")
                }

                val imageitem = imageItemService.findOne(id)
                if (imageitem != null) {
                    val file = File(imageitem.path!!)
                    if (file.exists()) {

                        call.respondFile(file)
                    } else {
                        call.respond(HttpStatusCode.NotFound)
                    }
                } else {
                    call.respond(HttpStatusCode.NotFound)
                }
            }

        }
    }

    routingTodolist()
    routingWebSocket()
    routingDailyAttendance()
    routingClipboard()
}