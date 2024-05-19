package com.steiner.workbench.todolist.model

import com.steiner.workbench.common.util.FlatUIColor
import kotlinx.serialization.Serializable

@Serializable
class Tag(
    val id: Int,
    val name: String,
    val parentid: Int,
    val color: FlatUIColor
)