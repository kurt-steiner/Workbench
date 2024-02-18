package com.steiner.workbench.todolist.service

import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.common.util.now
import com.steiner.workbench.todolist.model.TaskGroup
import com.steiner.workbench.todolist.request.PostTaskGroupRequest
import com.steiner.workbench.todolist.request.ReorderRequest
import com.steiner.workbench.todolist.request.UpdateTaskGroupRequest
import com.steiner.workbench.todolist.table.TaskGroups
import com.steiner.workbench.todolist.table.TaskProjects
import com.steiner.workbench.todolist.table.Tasks
import com.steiner.workbench.todolist.util.mustExistIn
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.inList
import org.jetbrains.exposed.sql.SqlExpressionBuilder.plus
import org.jetbrains.exposed.sql.transactions.transaction
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class TaskGroupService(val database: Database): KoinComponent {
    init {
        transaction(database) {
            SchemaUtils.create(TaskGroups)
        }
    }

    val taskService: TaskService by inject<TaskService>()

    suspend fun insertOne(request: PostTaskGroupRequest): TaskGroup = dbQuery(database) {
        mustExistIn(request.parentid, TaskProjects)
        with (TaskGroups) {
            val nowLocalDateTime = now()
            val count = selectAll().count().toInt()
            val id = insert {
                it[parentid] = request.parentid
                it[index] = count
                it[name] = request.name
                it[createTime] = nowLocalDateTime
                it[updateTime] = nowLocalDateTime
            } get this.id

            findOne(id.value)!!
        }
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        mustExistIn(id, TaskGroups)

        Tasks.deleteWhere {
            parentid eq id
        }

        val index = with (TaskGroups) {
            selectAll().where(this.id eq id)
                .first()
                .let {
                    it[index]
                }
        }

        with (TaskGroups) {
            deleteWhere {
                this.id eq id
            }

            update({ this@with.index greater index }) {
                with (SqlExpressionBuilder) {
                    it.update(this@update.index, this@update.index - 1)
                }
            }
        }
    }

    suspend fun deleteAll(parentid: Int) = dbQuery(database) {
        val groupids = with (TaskGroups) {
            selectAll().where(this.parentid eq parentid)
                .map {
                    it[id]
                }
        }

        groupids.forEach {
            taskService.deleteAll(it.value)
        }

        with (TaskGroups) {
            deleteWhere {
                id.inList(groupids)
            }
        }
    }

    suspend fun updateOne(request: UpdateTaskGroupRequest): TaskGroup = dbQuery(database) {
        mustExistIn(request.id, TaskGroups)

        with (TaskGroups) {
            update({ id eq request.id}) {
                it[name] = request.name
                it[updateTime] = now()
            }
        }

        findOne(request.id)!!
    }

    suspend fun reorder(request: ReorderRequest) = dbQuery(database) {
        mustExistIn(request.id, TaskGroups)

        val taskGroup = findOne(request.id)!!
        if (taskGroup.index < request.reorderAfter) {
            with (TaskGroups) {
                update({
                    (parentid eq taskGroup.parentid) and
                            (index lessEq request.reorderAfter) and
                            (index greater taskGroup.index)}) {
                    with (SqlExpressionBuilder) {
                        it.update(index, index - 1)
                    }
                }
            }
        } else if (taskGroup.index > request.reorderAfter) {
            with (TaskGroups) {
                update({
                    (parentid eq taskGroup.parentid) and
                            (index greaterEq request.reorderAfter) and
                            (index less taskGroup.index)
                }) {
                    it.update(index, index + 1)
                }
            }
        } else {
            // nothing to do
        }

        with (TaskGroups) {
            update({id eq request.id}) {
                it[updateTime] = now()
                it[index] = request.reorderAfter
            }
        }
    }

    suspend fun findOne(id: Int): TaskGroup? = dbQuery(database) {
        with (TaskGroups) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    val tasks = taskService.findAll(id)

                    TaskGroup(
                        id = id,
                        name = it[name],
                        index = it[index],
                        tasks = tasks,
                        createTime = it[createTime],
                        updateTime = it[updateTime],
                        parentid = it[parentid].value
                    )
                }
        }
    }

    suspend fun findAll(parentid: Int): List<TaskGroup> = dbQuery(database) {
        with (TaskGroups) {
            selectAll().where(this.parentid eq parentid)
                .orderBy(index)
                .map {
                    val id = it[id].value

                    TaskGroup(
                        id = id,
                        name = it[name],
                        index = it[index],
                        tasks = taskService.findAll(id),
                        createTime = it[createTime],
                        updateTime = it[updateTime],
                        parentid = it[this.parentid].value
                    )
                }
        }
    }

    suspend fun clear() = dbQuery(database) {
        TaskGroups.deleteAll()
    }
}