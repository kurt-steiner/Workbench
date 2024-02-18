package com.steiner.workbench.app.plugin

import com.steiner.workbench.todolist.validateTodolist
import io.ktor.server.application.*
import io.ktor.server.plugins.requestvalidation.*

fun Application.configureValidation() {
    install(RequestValidation) {
        validateTodolist()
    }
}