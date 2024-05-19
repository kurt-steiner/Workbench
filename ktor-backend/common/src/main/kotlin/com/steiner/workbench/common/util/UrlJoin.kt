package com.steiner.workbench.common.util

import java.net.URI

fun String.urljoin(path: String): String {
    val url1 = if (this.endsWith("/")) {
        URI(this)
    } else {
        URI("$this/")
    }

    val url2 = URI(path)
    val url3 = url1.resolve(url2)
    return url3.toString()
}