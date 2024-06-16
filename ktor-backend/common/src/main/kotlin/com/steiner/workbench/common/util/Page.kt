package com.steiner.workbench.common.util
import kotlinx.serialization.Serializable

@Serializable
class Page<T>(
    val content: List<T>,
    val totalPages: Int
)