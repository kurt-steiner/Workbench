import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.junit.jupiter.api.Test

class EnumJsonTest {
    @Serializable
    enum class Color(val hex: String) {
        red("hello world")
    }

    @Serializable
    class Priority(
        val color: Color,
        val id: Int,
        val name: String
    )

    @Test
    fun testJson() {
        val priority = Priority(
            id = 1,
            name = "hello",
            color = Color.red
        )

        val pString = """
            {
            "id": 1,
            "name": "hello",
            "color": "red"
            }
        """.trimIndent()

        println(Json.decodeFromString<Priority>(pString))
    }
}