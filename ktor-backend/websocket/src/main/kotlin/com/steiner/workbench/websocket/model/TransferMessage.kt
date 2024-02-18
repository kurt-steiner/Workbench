package com.steiner.workbench.websocket.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class TransferMessage {
    @Serializable
    @SerialName("notification")
    class Notification(val operation: Operation): TransferMessage()

    @Serializable
    @SerialName("error")
    class Error(val message: String): TransferMessage()
}