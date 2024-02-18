
plugins {
    kotlin("jvm") version "1.9.22"
    id("io.ktor.plugin") version "2.3.7"
    id("org.jetbrains.kotlin.plugin.serialization") version "1.9.22"
}

group = "com.steiner.workbench"
version = "0.0.1"

application {
    // mainClass.set("io.ktor.server.cio.EngineMain")
    mainClass = "com.steiner.workbench.app.MainKt"

    val isDevelopment: Boolean = project.ext.has("development")
    applicationDefaultJvmArgs = listOf("-Dio.ktor.development=$isDevelopment")
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(project(":app"))
}

subprojects {
    repositories {
        mavenCentral()
    }

    apply {
        plugin("org.jetbrains.kotlin.jvm")
        plugin("io.ktor.plugin")
        plugin("org.jetbrains.kotlin.plugin.serialization")
    }

    dependencies {
        testImplementation("org.jetbrains.kotlin:kotlin-test:+")
    }

    tasks.withType<Test> {
        useJUnitPlatform()
    }
}