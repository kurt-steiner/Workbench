package com.steiner.workbench.clipboard.model

import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable

@Serializable
class Text(
    val id: Int,
    val text: String,
    val createTime: LocalDateTime
)