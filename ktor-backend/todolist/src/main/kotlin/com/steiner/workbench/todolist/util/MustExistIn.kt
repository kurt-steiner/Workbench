package com.steiner.workbench.todolist.util

import io.ktor.server.plugins.*
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq

fun mustExistIn(id: Int?, table: IntIdTable) {
    if (id == null) {
        return
    }

    val exist = table.select(table.id eq id).firstOrNull() != null

    if (!exist) {
        throw NotFoundException("element not exist")
    }
}