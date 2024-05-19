package com.steiner.workbench.daily_attendance

import com.steiner.workbench.daily_attendance.request.*
import io.ktor.server.plugins.requestvalidation.*

fun RequestValidationConfig.validateDailyAttendance() {
    validate<PostIconImageRequest> {
        it.validate()
    }

    validate<PostTaskRequest> {
        it.validate()
    }

    validate<UpdateArchiveTaskRequest> {
        it.validate()
    }

    validate<UpdateProgressRequest> {
        it.validate()
    }

    validate<UpdateTaskRequest> {
        it.validate()
    }
}