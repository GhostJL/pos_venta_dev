allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    val fixNamespace = {
        if (project.name == "blue_thermal_printer") {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val getMethod = android.javaClass.getMethod("getNamespace")
                    if (getMethod.invoke(android) == null) {
                        val setMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                        setMethod.invoke(android, "id.kakzaki.blue_thermal_printer")
                    }
                } catch (e: Exception) {
                    println("Error setting namespace for blue_thermal_printer: $e")
                }
            }
        }
    }

    if (project.state.executed) {
        fixNamespace()
    } else {
        project.afterEvaluate {
            fixNamespace()
        }
    }
}
