package com.steiner.workbench.app.plugin

import com.steiner.workbench.common.service.ImageItemService
import com.steiner.workbench.common.util.SimpleJWT
import com.steiner.workbench.todolist.service.*
import io.ktor.server.application.*
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.Database
import org.koin.dsl.module
import org.koin.ktor.plugin.Koin

fun Application.configureKoin() {
    install(Koin) {
        val backendModule = module {
            single {
                SimpleJWT("my-super-secret-for-jwt")
            }

            single {
                Database.connect(
                    "jdbc:postgresql://localhost/workbench",
                    user = "steiner",
                    password = "779151714",
                    driver = "org.postgresql.Driver"
                )
            }

            single {
                ImageItemService(get())
            }

            single {
                SubTaskService(get())
            }

            single {
                TagService(get())
            }

            single {
                PriorityService(get())
            }

            single {
                TaskService(
                    database = get()
                )
            }

            single {
                TaskGroupService(
                    database = get(),
                )
            }

            single {
                TaskProjectService(
                    database = get(),
                    taskGroupService = get(),
                    tagService = get()
                )
            }

            single {
                Json {
                    ignoreUnknownKeys = true
                    classDiscriminator = "type"
                }
            }
        }

        modules(backendModule)
    }
}