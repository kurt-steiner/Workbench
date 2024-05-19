import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalDateTime
import kotlin.test.Test

class Iso8601ToLocalDate {
    @Test
    fun testTransform() {
        val iso8601String = "2024-02-09"
        // println(LocalDate.parse(iso8601String))
        println(LocalDate.parse(iso8601String))
    }
}