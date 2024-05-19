package com.steiner.workbench.clipboard

import com.steiner.workbench.clipboard.request.PostTextRequest
import com.steiner.workbench.clipboard.service.TextService
import com.steiner.workbench.common.util.Response
import com.steiner.workbench.common.util.uid
import com.steiner.workbench.websocket.endpoint.WebSocketEndpoint
import com.steiner.workbench.websocket.model.Operation
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.koin.ktor.ext.inject

fun Application.routingClipboard() {
    val service: TextService by inject<TextService>()

    routing {
        route("/clipboard") {
            post {
                val request = call.receive<PostTextRequest>()
                val result = service.insertOne(request)
                call.respond(Response.Ok("insert ok", result))
                WebSocketEndpoint.notifyFrom(uid(), Operation.ClipboardPost)
            }

            get {
                val page = call.request.queryParameters["page"]?.toIntOrNull() ?: 0
                val size = call.request.queryParameters["size"]?.toIntOrNull() ?: 20

                call.respond(Response.Ok("these content", service.findAll(page, size)))
            }

            delete("/id") {
                val id = call.parameters["id"]!!.toInt()

                service.deleteOne(id)
                call.respond(Response.Ok("delete ok", Unit))
                WebSocketEndpoint.notifyFrom(uid(), Operation.ClipboardDelete(id = id))
            }
        }
    }
}