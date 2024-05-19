package com.steiner.workbench.common.util

import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.util.pipeline.*

fun PipelineContext<Unit, ApplicationCall>.uid(): String {
    return call.request.header("uid")!!
}