package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.todolist.model.Priority
import com.steiner.workbench.todolist.request.PostPriorityRequest
import com.steiner.workbench.todolist.request.UpdatePriorityRequest
import com.steiner.workbench.todolist.table.Priorities
import com.steiner.workbench.todolist.table.Priorities.select
import com.steiner.workbench.todolist.table.TaskPriority
import com.steiner.workbench.todolist.util.mustExistIn
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
                        parentid = it[parentid].value
                    )
                }
        }
    }

    suspend fun findAll(taskid: Int): List<Priority> = dbQuery(database) {
        with (TaskPriority) {
            selectAll().where(this.taskid eq taskid)
                .map {
                    it[priorityid]
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
}