package com.steiner.workbench.daily_attendance.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Progress {
    @Serializable
    @SerialName("not-scheduled")
    object NotScheduled: Progress() {
        override fun equals(other: Any?): Boolean {
            if (other == null) {
                return false
            }

            if (other !is NotScheduled) {
                return false
            }

            return true
        }
    }

    @Serializable
    @SerialName("ready")
    object Ready: Progress() {
        override fun equals(other: Any?): Boolean {
            if (other == null) {
                return false
            }

            if (other !is Ready) {
                return false
            }

            return true
        }
    }

    @Serializable
    @SerialName("done")
    object Done: Progress() {
        override fun equals(other: Any?): Boolean {
            if (other == null) {
                return false
            }

            if (other !is Done) {
                return false
            }

            return true
        }
    }

    @Serializable
    @SerialName("doing")
    class Doing(val total: Int, val unit: String, val amount: Int): Progress()
}