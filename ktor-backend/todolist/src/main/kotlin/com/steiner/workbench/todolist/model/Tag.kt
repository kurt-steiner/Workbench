package com.steiner.workbench.todolist.model

import com.steiner.workbench.todolist.enumeration.TagColor
import kotlinx.serialization.Serializable

@Serializable
class Tag(
    val id: Int,
    val name: String,
    val parentid: Int,
    val color: TagColor
)