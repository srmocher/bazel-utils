_JAR_BUILD_FILE_CONTENT = """

java_import(
    name = "jar",
    jars = [
        "{downloaded_jar_path}"
    ],
    visibility = ["//visibility:public"],
)
"""

_ARCHIVE_BUILD_FILE_CONTENT = """

filegroup(
    name = "srcs",
    srcs = glob([
        "**/*",
    ]),
    visibility = ["//visibility:public"],
)
"""

_FILE_BUILD_FILE_CONTENT = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "file",
    srcs = ["{downloaded_file}"],
)

"""

def setup_build_file(ctx):
    """Helper function to populate build file content with default targets."""

    if ctx.attr.asset_type == "archive":
        ctx.file(
            "BUILD.bazel",
            content = _ARCHIVE_BUILD_FILE_CONTENT,
        )
    elif ctx.attr.asset_type == "jar":
        ctx.file(
            "BUILD.bazel",
            content = _JAR_BUILD_FILE_CONTENT.format(downloaded_jar_path = ctx.attr.asset_name),
        )
    elif ctx.attr.asset_type == "file":
        ctx.file(
            "BUILD.bazel",
            content = _FILE_BUILD_FILE_CONTENT.format(downloaded_file = ctx.attr.asset_name),
        )
