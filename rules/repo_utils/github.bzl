load("@bazel_tools//tools/build_defs/repo:utils.bzl", "read_netrc")
load(":common.bzl", "setup_build_file")

def _get_token_from_netrc_file(repo_ctx, github_host):
    home = repo_ctx.os.environ.get("HOME")
    netrc_file = repo_ctx.path("{}/.netrc".format(home))
    if not netrc_file.exists:
        fail("GH_TOKEN not set and ~/.netrc doesn't exist, cannot authenticate")

    netrc_dict = read_netrc(repo_ctx, netrc_file)
    if github_host not in netrc_dict:
        fail("No entry for {} in ~/.netrc".format(github_host))

    return netrc_dict[github_host]["password"]

def _get_github_host(github_repo):
    split_repo = github_repo.split("/")
    if len(split_repo) != 3:
        fail("Invalid repo url {} - Must be of the form <github-host>/<github-org>/<repo-name>".format(github_repo))

    return split_repo[0]

def _download_from_github(ctx, gh_cli):
    gh_token = ctx.os.environ.get("GH_TOKEN")

    if not gh_token:
        github_host = _get_github_host(ctx.attr.repo)
        gh_token = _get_token_from_netrc_file(ctx, github_host)
    else:
        gh_token = ctx.os.environ["GH_TOKEN"]

    release_info_cmd = [
        gh_cli,
        "release",
        "view",
        ctx.attr.tag,
        "--repo",
        ctx.attr.repo,
        "--json",
        "assets",
    ]
    release_info_res = ctx.execute(release_info_cmd, environment = {
        "GH_TOKEN": gh_token,
    })

    if release_info_res.return_code != 0:
        fail("Failed to download asset from Github! {}".format(release_info_res.stderr))

    assets_info = json.decode(release_info_res.stdout.strip())
    if "assets" not in assets_info:
        fail("Release asset info could be not determined: {}".format(assets_info))

    assets = assets_info["assets"]
    found_asset = False
    for asset in assets:
        if asset["name"] == ctx.attr.asset_name:
            found_asset = True

    if not found_asset:
        fail("Asset {} doesn't exist in the specified release".format(ctx.attr.asset_name))

    ctx.report_progress("Downloading asset {} from github".format(ctx.attr.asset_name))
    download_cmd = [
        gh_cli,
        "release",
        "download",
        "-R",
        ctx.attr.repo,
        "-p",
        ctx.attr.asset_name,
        "--skip-existing",
        ctx.attr.tag,
        "--dir",
        ctx.path("."),
    ]

    download_res = ctx.execute(download_cmd, environment = {
        "GH_TOKEN": gh_token,
    })
    if download_res.return_code != 0:
        fail("Failed downloading asset {} from github!: {}".format(ctx.attr.asset_name, download_res.stderr))

    downloaded_asset_path = ctx.path("./{}".format(ctx.attr.asset_name))

    # We don't use the Bazel downloader to download and integrity checking
    # so we do checksum validation ourselves
    _validate_sha256(ctx)

    if ctx.attr.asset_type == "archive":
        ctx.extract(downloaded_asset_path, stripPrefix = ctx.attr.strip_prefix)
        ctx.delete(downloaded_asset_path)

    if ctx.attr.build_file_content:
        ctx.file(
            "BUILD.bazel",
            content = ctx.attr.build_file_content,
        )
    else:
        setup_build_file(ctx)

def _validate_sha256(ctx):
    if ctx.which("sha256sum"):
        sha_cmd = ["sha256sum", ctx.path("./{}".format(ctx.attr.asset_name))]
        sha_res = ctx.execute(sha_cmd)
        if sha_res.return_code != 0:
            fail("error computing sha256 for downloaded asset {}".format(ctx.attr.asset_name))

        actual_sha = sha_res.stdout.split(" ")[0].strip()
        if actual_sha != ctx.attr.sha256:
            fail("Downloaded asset has checksum {}, which is different from expected value: {}".format(actual_sha, ctx.attr.sha256))
    else:
        print("sha256sum command doesn't exist in PATH, so skipping integrity checks..")

def _github_private_release_asset_impl(ctx):
    if ctx.attr.asset_type not in ["file", "archive", "jar"]:
        fail("{} is not a supported asset type!".format(ctx.attr.asset_type))

    gh_cli = ctx.attr._gh_cli_linux_amd64
    arch = ctx.execute(["uname", "-m"]).stdout.strip()
    if ctx.os.name.lower().startswith("mac os"):
        if arch == "arm64" or arch == "aarch64":
            gh_cli = ctx.attr._gh_cli_darwin_arm64
        else:
            gh_cli = ctx.attr._gh_cli_darwin_amd64

    _download_from_github(ctx, ctx.path(gh_cli))

github_private_release_asset = repository_rule(
    implementation = _github_private_release_asset_impl,
    doc = """
A repository rule to expose assets from private Github releases, requiring authentication as external Bazel dependencies. Analogous to http_archive/http_file/http_jar but handles authentication for Github
workflows. This does not however use Bazel's downloader (yet) to download the assets, so does not benefit from repository caching.

Example usage:
In your workspace file, you can declare a private Github dependency as follows

```
load("@smocherla_bazel_utils//rules/repo_utils:github.bzl", "github_private_release_asset")

github_private_release_asset(
    name = "foo_zip_asset",
    asset_name = "foo.zip", # name of the release asset for that tag
    asset_type = "archive", # type of the asset - has to be archive/file/jar
    repo = "github.com/foo/foo", # the repository in which the release is hosted
    sha256 = "1527527ea52e58e86a4c7066a5acc974811a077a475bdd81552754bb1d2569db",
    tag = "v1.0.0", # the github tag corresponding to this release
)
```
    """,
    attrs = {
        "tag": attr.string(
            doc = "The tag corresponding to the github release asset",
            mandatory = True,
        ),
        "repo": attr.string(
            doc = "The github repo (HOST/owner/repo) from which the asset is to be downloaded",
            mandatory = True,
        ),
        "sha256": attr.string(
            doc = "The sha256 checksum of the asset",
            mandatory = True,
        ),
        "strip_prefix": attr.string(
            doc = "If the asset is an archive, then this will strip the specified prefix after extraction",
        ),
        "asset_name": attr.string(
            doc = "The name of the archive asset in the github release to be downloaded",
            mandatory = True,
        ),
        "asset_type": attr.string(
            doc = "The type of asset (archive/jar/file)",
            default = "file",
        ),
        "build_file_content": attr.string(
            doc = "The content of the build file for this repository.",
        ),
        "_gh_cli_linux_amd64": attr.label(
            default = Label("@gh_cli_linux_amd64//:bin/gh"),
            executable = True,
            cfg = "exec",
        ),
        "_gh_cli_darwin_amd64": attr.label(
            default = Label("@gh_cli_darwin_amd64//:bin/gh"),
            executable = True,
            cfg = "exec",
        ),
        "_gh_cli_darwin_arm64": attr.label(
            default = Label("@gh_cli_darwin_arm64//:bin/gh"),
            executable = True,
            cfg = "exec",
        ),
    },
    environ = [
        "GH_TOKEN",
    ],
)
