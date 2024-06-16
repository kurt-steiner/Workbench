package com.steiner.workbench.clipboard.service

import com.steiner.workbench.clipboard.model.Text
import com.steiner.workbench.clipboard.request.PostTextRequest
import com.steiner.workbench.clipboard.table.Texts
import com.steiner.workbench.common.util.Page
import com.steiner.workbench.common.util.dbQuery
import com.steiner.workbench.common.util.now
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction
import kotlin.math.ceil

class TextService(val database: Database) {
    init {
        transaction(database) {
            SchemaUtils.create(Texts)
        }
    }

    suspend fun insertOne(request: PostTextRequest): Text = dbQuery(database) {
        val id = Texts.insert {
            it[text] = request.text
            it[createTime] = now()
        } get Texts.id

        findOne(id.value)!!
    }

    suspend fun deleteOne(id: Int) = dbQuery(database) {
        Texts.deleteWhere {
            this.id eq id
        }
    }

    suspend fun findAll(page: Int, size: Int): Page<Text> = dbQuery(database) {
        val content = with (Texts) {
            selectAll()
                .orderBy(this.id, order = SortOrder.DESC)
                .limit(size, offset = page * size.toLong())
                .map {
                    Text(
                        id = it[id].value,
                        text = it[text],
                        createTime = it[createTime]
                    )
                }
        }

        val totalPages = ceil(Texts.selectAll().count() / size.toDouble()).toInt()

        Page(content, totalPages)
    }

    suspend fun findOne(id: Int): Text? = dbQuery(database) {
        with (Texts) {
            selectAll().where(this.id eq id)
                .firstOrNull()
                ?.let {
                    Text(
                        id = it[this.id].value,
                        text = it[text],
                        createTime = it[createTime]
                    )
                }
        }
    }
}