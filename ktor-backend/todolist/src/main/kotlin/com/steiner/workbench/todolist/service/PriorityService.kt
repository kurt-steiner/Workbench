package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.`priority-default-name`
import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.todolist.enumeration.PriorityColor
import com.steiner.workbench.todolist.model.Priority
import com.steiner.workbench.todolist.request.PostPriorityRequest
import com.steiner.workbench.todolist.request.UpdatePriorityRequest
import com.steiner.workbench.todolist.table.Priorities
import com.steiner.workbench.todolist.table.TaskPriority
import com.steiner.workbench.common.util.mustExistIn
import io.ktor.server.plugins.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction

class PriorityService(val database: Database) {
    init {
        transaction(database) {
            SchemaUtils.create(Priorities)
            SchemaUtils.create(TaskPriority)
        }
    }

    suspend fun insertOne(request: PostPriorityRequest): Priority = dbQuery(database) {
        val exist = with (Priorities) {
            selectAll().where((parentid eq request.parentid) and (name eq request.name))
                .firstOrNull() != null
        }

        if (exist) {
            throw BadRequestException("priority ${request.name} duplicate")
        }

        val id = with (Priorities) {
            insert {
                it[name] = request.name
                it[order] = request.order
                it[parentid] = request.parentid
                it[color] = request.color
            } get this.id
        }

        findOne(id.value)!!
    }

    suspend fun findOne(id: Int): Priority? = dbQuery(database) {
        with (Priorities) {
            selectAll().where(this.id eq id)
                .firstOrNull()?.let {
                    Priority(
                        id = it[this.id].value,
                        name = it[name],
                        order = it[order],
                        parentid = it[parentid].value,
                        color = it[color]
                    )
                }
        }
    }

    suspend fun findAll(parentid: Int): List<Priority> = dbQuery(database) {
        with (Priorities) {
            selectAll().where(this.parentid eq parentid)
                .map {
                    it[id]
                }.map {
                    findOne(it.value)!!
                }
        }

    }
    suspend fun updateOne(request: UpdatePriorityRequest): Priority = dbQuery(database) {
        mustExistIn(request.id, Priorities)

        with (Priorities) {
            update({ id eq request.id }) {
                if (request.name != null) {
                    it[name] = request.name
                }

                if (request.order != null) {
                    it[order] = request.order
                }

                if (request.color != null) {
                    it[color] = request.color
                }
            }
        }

        findOne(request.id)!!
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        with (Priorities) {
            deleteWhere {
                this.id eq id
            }
        }
    }

    suspend fun deleteAll(parentid: Int) = dbQuery(database) {
        with (Priorities) {
            deleteWhere {
                this.parentid eq parentid
            }
        }
    }

    suspend fun clear() = dbQuery(database) {
        Priorities.deleteAll()
        TaskPriority.deleteAll()
    }

    suspend fun findDefault(parentid: Int): Priority = dbQuery(database) {
        with (Priorities) {
            var priority: Priority? = selectAll().where(name eq `priority-default-name`)
                .firstOrNull()?.let {
                    Priority(
                        id = it[id].value,
                        name = it[name],
                        order = it[order],
                        parentid = it[this.parentid].value,
                        color = it[color]
                    )
                }

            if (priority == null) {
                val id = insert {
                    it[name] = `priority-default-name`
                    it[order] = 2
                    it[this.parentid] = parentid
                    it[color] = PriorityColor.Grey
                } get this.id

                priority = findOne(id.value)!!
            }

            priority
        }
    }
}