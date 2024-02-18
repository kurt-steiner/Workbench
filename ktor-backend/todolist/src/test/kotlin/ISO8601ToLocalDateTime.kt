import kotlinx.datetime.LocalDateTime
import org.junit.jupiter.api.Test

class ISO8601ToLocalDateTime {
    @Test
    fun testTransform() {
        val iso8601String = "2024-02-09T19:33:16.744083"
        println(LocalDateTime.parse(iso8601String))
    }
}