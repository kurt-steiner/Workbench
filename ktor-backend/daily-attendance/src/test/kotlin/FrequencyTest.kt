import com.steiner.workbench.daily_attendance.model.Frequency
import com.steiner.workbench.daily_attendance.table.Tasks
import com.steiner.workbench.daily_attendance.iterate.*
import kotlinx.datetime.LocalDate
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import kotlin.test.Test
import kotlin.test.assertEquals

class FrequencyTest {
    @Test
    fun frequencyTest() {
        val database = Database.connect(
            "jdbc:postgresql://localhost/workbench",
            user = "steiner",
            password = "779151714",
            driver = "org.postgresql.Driver"
        )

        transaction(database) {
            val id = 17
            val localdate = LocalDate(2024, 2, 27)
            with (Tasks) {
                selectAll().where(this.id eq id)
                    .first().let {
                        val frequency = it[frequency] as Frequency.Interval
                        assertEquals(true, (it[startTime]..localdate step frequency.count).last() == localdate)
                    }
            }
        }
    }
}