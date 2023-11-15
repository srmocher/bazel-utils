load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

_GH_BUILD_FILE_CONTENT = """
filegroup(
    name = "gh_cli",
    srcs = ["bin/gh"],
)

"""

def github_rule_deps():
    """Dependencies for the github repository rule."""

    http_archive(
        name = "gh_cli_linux_amd64",
        url = "https://github.com/cli/cli/releases/download/v2.36.0/gh_2.36.0_linux_amd64.tar.gz",
        sha256 = "29ed6c04931e6ac8a5f5f383411d7828902fed22f08b0daf9c8ddb97a89d97ce",
        build_file_content = _GH_BUILD_FILE_CONTENT,
        strip_prefix = "gh_2.36.0_linux_amd64",
    )

    http_archive(
        name = "gh_cli_linux_arm64",
        url = "https://github.com/cli/cli/releases/download/v2.36.0/gh_2.36.0_linux_arm64.tar.gz",
        sha256 = "3cdbbe813c59fc61c84dc17e78efb93135231beb08e8cb0f2345de8d615a1660",
        build_file_content = _GH_BUILD_FILE_CONTENT,
        strip_prefix = "gh_2.36.0_linux_arm64",
    )

    http_archive(
        name = "gh_cli_darwin_amd64",
        url = "https://github.com/cli/cli/releases/download/v2.34.0/gh_2.34.0_macOS_amd64.zip",
        sha256 = "9d6cd7c3952bb9a1cdaeaf04c456c558f8510ffbdc93bb4b40a85013c638bfca",
        build_file_content = _GH_BUILD_FILE_CONTENT,
        strip_prefix = "gh_2.34.0_macOS_amd64",
    )

    http_archive(
        name = "gh_cli_darwin_arm64",
        url = "https://github.com/cli/cli/releases/download/v2.36.0/gh_2.36.0_macOS_arm64.zip",
        sha256 = "d4e53e8b2127f2ad3f5356e81ef27b50f1cc2e202ea18db4f69b4e9f77fd895f",
        build_file_content = _GH_BUILD_FILE_CONTENT,
        strip_prefix = "gh_2.36.0_macOS_arm64",
    )

def bazel_utils_deps():
    """External dependencies for the bazel-utils repository."""

    http_file(
        name = "buildifier_linux_amd64",
        url = "https://github.com/bazelbuild/buildtools/releases/download/v6.3.3/buildifier-linux-amd64",
        sha256 = "42f798ec532c58e34401985043e660cb19d5ae994e108d19298c7d229547ffca",
        executable = True,
    )

    http_file(
        name = "buildifier_linux_arm64",
        url = "https://github.com/bazelbuild/buildtools/releases/download/v6.3.3/buildifier-linux-arm64",
        sha256 = "6a03a1cf525045cb686fc67cd5d64cface5092ebefca3c4c93fb6e97c64e07db",
        executable = True,
    )

    http_file(
        name = "buildifier_darwin_amd64",
        url = "https://github.com/bazelbuild/buildtools/releases/download/v6.3.3/buildifier-darwin-amd64",
        sha256 = "3c36a3217bd793815a907a8e5bf81c291e2d35d73c6073914640a5f42e65f73f",
        executable = True,
    )

    http_file(
        name = "buildifier_darwin_arm64",
        url = "https://github.com/bazelbuild/buildtools/releases/download/v6.4.0/buildifier-darwin-arm64",
        sha256 = "fa07ba0d20165917ca4cc7609f9b19a8a4392898148b7babdf6bb2a7dd963f05",
        executable = True,
    )

    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "62bd2e60216b7a6fec3ac79341aa201e0956477e7c8f6ccc286f279ad1d96432",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.6.2/stardoc-0.6.2.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.6.2/stardoc-0.6.2.tar.gz",
        ],
    )
