# Included after every project() in the plugins' native CMake builds
# (CMAKE_PROJECT_INCLUDE, set in build.gradle.kts). The default build ID is a
# hash that includes build paths, so the same code built on the GitHub runner
# and on F-Droid's build server would differ only in this ID.
add_link_options("LINKER:--build-id=none")
