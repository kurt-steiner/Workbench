package com.steiner.workbench.app

import com.steiner.workbench.app.plugin.*
import io.ktor.server.application.*
import io.ktor.server.cio.*

fun main(args: Array<String>) {
    EngineMain.main(args)
}

fun Application.module() {
    configureWebSocket()
    configureHTTP()
    configureKoin()
    configureInitialize()
    configureSerialization()
    configureErrorHandler()
    configureValidation()

    configureRouting()
}