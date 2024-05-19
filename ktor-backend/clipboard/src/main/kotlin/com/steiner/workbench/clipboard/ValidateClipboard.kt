package com.steiner.workbench.clipboard

import com.steiner.workbench.clipboard.request.PostTextRequest
import io.ktor.server.plugins.requestvalidation.*

fun RequestValidationConfig.validateClipboard() {
    validate<PostTextRequest> {
        it.validate()
    }
}