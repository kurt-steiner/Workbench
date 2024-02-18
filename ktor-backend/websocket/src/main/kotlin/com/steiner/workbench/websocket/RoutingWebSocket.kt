package com.steiner.workbench.websocket

import com.steiner.workbench.websocket.endpoint.WebSocketEndpoint
import com.steiner.workbench.websocket.model.TransferData
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.request.*
import io.ktor.server.routing.*
import io.ktor.server.websocket.*
import io.ktor.websocket.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.koin.ktor.ext.inject
import java.io.IOException

val socketMap = mutableMapOf<String, WebSocketEndpoint>()

fun Application.routingWebSocket() {

    val json: Json by inject<Json>()
    routing {
        route("websocket") {
            webSocket {
                val uid: String = call.request.header("uid")!!

                if (socketMap.containsKey(uid)) {
                    socketMap.put(uid, WebSocketEndpoint(nickname = uid, session = this))
                }

                val transferData = call.receive<TransferData>()
                val touid = transferData.touid

                val toEndpoint = socketMap[touid]!!
                val toSession = toEndpoint.session

                // toSession 发送数据 transferData.operation
                try {
                    toSession.send(json.encodeToString(transferData.message))
                } catch (exception: IOException) {
                    toSession.close(reason = CloseReason(CloseReason.Codes.INTERNAL_ERROR, exception.message ?: ""))
                    socketMap.remove(uid)
                }
            }
        }
    }
}