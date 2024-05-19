package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.todolist.model.SubTask
import com.steiner.workbench.todolist.request.PostSubTaskRequest
import com.steiner.workbench.todolist.request.ReorderRequest
import com.steiner.workbench.todolist.request.UpdateSubTaskRequest
import com.steiner.workbench.todolist.table.SubTasks
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.common.util.mustExistIn
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.plus
import org.jetbrains.exposed.sql.transactions.transaction

class SubTaskService(val database: Database) {
    init {
        transaction(database) {
            SchemaUtils.create(SubTasks)
        }
    }

    suspend fun insertOne(request: PostSubTaskRequest): SubTask = dbQuery(database) {
        mustExistIn(request.parentid, Tasks)

        val id = with (SubTasks) {
            val count = selectAll().where(parentid eq request.parentid).count().toInt()
            insert {
                it[index] = count
                it[parentid] = request.parentid
                it[name] = request.name
                it[isdone] = false
            } get this.id
        }

        findOne(id.value)!!
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        with (SubTasks) {
            deleteWhere {
                this.id eq id
            }
        }
    }

    suspend fun deleteAll(taskid: Int) = dbQuery(database) {
        with (SubTasks) {
            deleteWhere {
                parentid eq taskid
            }
        }
    }

    suspend fun updateOne(request: UpdateSubTaskRequest): SubTask = dbQuery(database) {
        mustExistIn(request.id, SubTasks)

        with (SubTasks) {
            update({ id eq request.id }) {
                if (request.name != null) {
                    it[name] = request.name
                }

                if (request.isdone != null) {
                    it[isdone] = request.isdone
                }
            }
        }

        findOne(request.id)!!
    }

    suspend fun reorder(request: ReorderRequest) = dbQuery(database) {
        mustExistIn(request.id, SubTasks)
        val subTask = findOne(request.id)!!

        if (subTask.index < request.reorderAfter) {
            with (SubTasks) {
                update({
                    (parentid eq subTask.parentid) and
                            (index lessEq request.reorderAfter) and
                            (index greater subTask.index)
                }) {
                    with (SqlExpressionBuilder) {
                        it.update(index, index - 1)
                    }
                }
            }
        } else if (subTask.index > request.reorderAfter) {
            with (SubTasks) {
                update({
                    (parentid eq subTask.parentid) and
                            (index greaterEq request.reorderAfter) and
                            (index less subTask.index)
                }) {
                    it.update(index, index + 1)
                }
            }
        } else {
            // nothing to do
        }

        with (SubTasks) {
            update({id eq request.id}) {
                it[index] = request.reorderAfter
            }
        }
    }

    suspend fun findOne(id: Int): SubTask? = dbQuery(database) {
        with (SubTasks) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    SubTask(
                        id = id,
                        name = it[name],
                        index = it[index],
                        isdone = it[isdone],
                        parentid = it[parentid].value
                    )
                }
        }
    }

    suspend fun findAll(parentid: Int): List<SubTask> = dbQuery(database) {
        with (SubTasks) {
            selectAll().where(this.parentid eq parentid)
                .orderBy(index)
                .map {
                    SubTask(
                        id = it[id].value,
                        name = it[name],
                        index = it[index],
                        isdone = it[isdone],
                        parentid = parentid
                    )
                }
        }
    }

    suspend fun clear() = dbQuery(database) {
        SubTasks.deleteAll()
    }
}