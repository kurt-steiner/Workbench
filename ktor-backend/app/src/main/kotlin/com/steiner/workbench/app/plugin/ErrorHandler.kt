package com.steiner.workbench.app.plugin

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.plugins.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.response.*
import com.steiner.workbench.common.util.Response
import io.ktor.server.plugins.requestvalidation.*

fun Application.configureErrorHandler() {
    val logger = log
    install(StatusPages) {
        /// this is for debugging in the frontend
        exception<BadRequestException> { call, cause ->
            logger.error(cause.stackTraceToString())
            call.respond(HttpStatusCode.BadRequest, Response.Err("bad request! ${cause.message}"))
        }

        exception<RequestValidationException> { call, cause ->
            call.respond(HttpStatusCode.BadRequest, Response.Err("request validation failed"))
        }

        exception<Exception> { call, cause ->
            call.respond(HttpStatusCode.InternalServerError, Response.Err("there is an error in the server"))
            logger.error(cause.stackTraceToString())
        }

        exception<NotFoundException> { call, cause ->
            call.respond(HttpStatusCode.NotFound, Response.Err("not found: ${cause.message}"))
        }

        exception<NumberFormatException> { call, cause ->
            call.respond(HttpStatusCode.BadRequest, Response.Err("bad request! ${cause.message}"))
        }

        exception<NullPointerException> { call, cause ->
            logger.error(cause.stackTraceToString())
            call.respond(HttpStatusCode.NotFound, Response.Err("occur null pointer exception for not found: ${cause.message}"))
        }
    }
}