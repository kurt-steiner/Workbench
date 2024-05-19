package com.steiner.workbench.todolist.table

import com.steiner.workbench.common.`tag-name-length`
import com.steiner.workbench.common.util.FlatUIColor
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption

object Tags: IntIdTable("todolist-tags") {
    val name = varchar("name", `tag-name-length`).uniqueIndex()
    val parentid = reference("parentid", TaskProjects, onDelete = ReferenceOption.CASCADE)
    val color = enumeration<FlatUIColor>("color")
}