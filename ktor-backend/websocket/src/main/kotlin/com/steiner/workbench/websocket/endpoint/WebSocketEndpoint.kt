package com.steiner.workbench.websocket.endpoint

import com.steiner.workbench.websocket.model.Operation
import com.steiner.workbench.websocket.model.TransferData
import com.steiner.workbench.websocket.model.TransferMessage
import com.steiner.workbench.websocket.socketMap
import io.ktor.websocket.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class WebSocketEndpoint(
    val nickname: String,
    val session: WebSocketSession
): KoinComponent {
    companion object {
        const val SERVER_NAME = "server"
        @JvmStatic
        suspend fun notifyFrom(fromuid: String, operation: Operation) {
            socketMap.values.filter {
                it.nickname != fromuid
            }.forEach {
                val data = TransferData(
                    fromuid = SERVER_NAME,
                    touid = it.nickname,
                    message = TransferMessage.Notification(operation)
                )

                it.session.send(it.json.encodeToString(data))
            }
        }

        @JvmStatic
        suspend fun notifyAll(operation: Operation) {
            socketMap.values.forEach {
                val data = TransferData(
                    fromuid = SERVER_NAME,
                    touid = it.nickname,
                    message = TransferMessage.Notification(operation)
                )

                it.session.send(it.json.encodeToString(data))
            }
        }
    }

    val json: Json by inject<Json>()

}