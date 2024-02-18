import com.steiner.workbench.common.rgbHexColorPattern
import org.junit.jupiter.api.Test

class ColorPatternTest {
    @Test
    fun testColor() {
        val colorString = "#0028a95a";
        assert(rgbHexColorPattern.matches(colorString))
    }
}