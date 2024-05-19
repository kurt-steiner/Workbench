package com.steiner.workbench.clipboard.table

import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.kotlin.datetime.datetime

object Texts: IntIdTable("clipboard-texts") {
    val text = text("text")
    val createTime = datetime("create-time")
}