package com.steiner.workbench.websocket.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class Operation {
    @Serializable
    @SerialName("taskproject:post")
    object TaskProjectPost: Operation()

    @Serializable
    @SerialName("taskproject:delete")
    class TaskProjectDelete(val id: Int): Operation()

    @Serializable
    @SerialName("taskproject:update")
    class TaskProjectUpdate(val id: Int): Operation()

    @Serializable
    @SerialName("tag:post")
    class TagPost(val parentid: Int): Operation()

    @Serializable
    @SerialName("tag:delete")
    class TagDelete(val id: Int): Operation()

    @Serializable
    @SerialName("tag:update")
    class TagUpdate(val id: Int): Operation()

    @Serializable
    @SerialName("priority:post")
    class PriorityPost(val parentid: Int): Operation()

    @Serializable
    @SerialName("priority:delete")
    class PriorityDelete(val parentid: Int, val id: Int): Operation()

    @Serializable
    @SerialName("priority:update")
    class PriorityUpdate(val id: Int): Operation()
    @Serializable
    @SerialName("taskgroup:post")
    class TaskGroupPost(val parentid: Int): Operation()

    @Serializable
    @SerialName("taskgroup:delete")
    class TaskGroupDelete(val parentid: Int, val id: Int): Operation()

    @Serializable
    @SerialName("taskgroup:update")
    class TaskGroupUpdate(val parentid: Int, val id: Int): Operation()

    @Serializable
    @SerialName("taskgroup:reorder")
    class TaskGroupReorder(val id: Int, val reorderAfter: Int): Operation()

    @Serializable
    @SerialName("task:post")
    class TaskPost(val parentid: Int): Operation()

    @Serializable
    @SerialName("task:delete")
    class TaskDelete(val parentid: Int, val id: Int): Operation()

    @Serializable
    @SerialName("task:update")
    class TaskUpdate(val parentid: Int, val id: Int): Operation()

    @Serializable
    @SerialName("task:reorder")
    class TaskReorder(val id: Int, val reorderAfter: Int, val parentid: Int): Operation()

    @Serializable
    @SerialName("subtask:post")
    class SubTaskPost(val parentid: Int): Operation()

    @Serializable
    @SerialName("subtask:delete")
    class SubTaskDelete(val parentid: Int, val id: Int): Operation()

    @Serializable
    @SerialName("subtask:update")
    class SubTaskUpdate(val parentid: Int, val id: Int): Operation()

    @Serializable
    @SerialName("subtask:reorder")
    class SubTaskReorder(val id: Int, val reorderAfter: Int): Operation()
    @Serializable
    @SerialName("daily-attendance:post")
    object DailyAttendancePost: Operation()

    @Serializable
    @SerialName("daily-attendance:delete")
    class DailyAttendanceDelete(val id: Int): Operation()

    @Serializable
    @SerialName("daily-attendance:update")
    class DailyAttendanceUpdate(val id: Int): Operation()

    @Serializable
    @SerialName("daily-attendance:archive")
    class DailyAttendanceArchive(val id: Int, val archive: Boolean): Operation()

    @Serializable
    @SerialName("daily-attendance:refresh")
    object DailyAttendanceRefresh: Operation()

    @Serializable
    @SerialName("clipboard:post")
    object ClipboardPost: Operation()

    @Serializable
    @SerialName("clipboard:delete")
    class ClipboardDelete(val id: Int): Operation()
}