load(":common.bzl", "setup_build_file")

def _get_s3_obj_metadata(ctx):
    cmd = [
        "aws",
        "s3api",
        "head-object",
        "--bucket",
        ctx.attr.bucket,
        "--key",
        ctx.attr.path,
        "--output",
        "json",
    ]

    s3_head_res = ctx.execute(cmd)
    if s3_head_res.return_code != 0:
        fail("Failed to retrieve metadata for bucket {} and path {}: {}".format(ctx.attr.bucket, ctx.attr.path, s3_head_res.stderr))

    return json.decode(s3_head_res.stdout)["Metadata"]

def _get_presigned_url(ctx):
    uri = "s3://{}/{}".format(ctx.attr.bucket, ctx.attr.path)
    cmd = ["aws", "s3", "presign", uri]

    s3_presign_res = ctx.execute(uri)
    if s3_presign_res.return_code != 0:
        fail("Failed to retrieve presigned URL from s3:{}".format(s3_presign_res.stderr))

    return s3_presign_res.stdout

def _s3_asset_impl(ctx):
    aws_cli = ctx.which("aws")
    if not aws_cli:
        fail("aws CLI not installed or unavailable!")

    sha256 = ""
    if ctx.attr.sha256:
        metadata = _get_s3_obj_metadata(ctx)
        if ctx.attr.metadata_sha256_key not in metadata:
            fail("Metadata key {} not found in object metadata".format(ctx.attr.metadata_sha256_key))
        sha256 = metadata[ctx.attr.metadata_sha256_key]

    s3_url = _get_presigned_url(ctx)
    if ctx.attr.asset_type == "archive":
        ctx.download_and_extract(
            url = s3_url,
            output = ctx.path(ctx.attr.path),
            sha256 = sha256,
            stripPrefix = ctx.attr.strip_prefix,
        )

    elif ctx.attr.asset_type == "file":
        ctx.download(
            url = s3_url,
            output = ctx.path(ctx.attr.path),
            sha256 = sha256,
            executable = ctx.attr.executable,
        )
    elif ctx.attr.asset_type == "jar":
        ctx.download(
            url = s3_url,
            output = ctx.path(ctx.attr.path),
            sha256 = sha256,
        )
    else:
        fail("Unknown asset type: {}, must be one of archive, file or jar".format(ctx.attr.asset_type))

    if ctx.attr.build_file_content:
        ctx.file(
            "BUILD.bazel",
            content = ctx.attr.build_file_content,
        )
    else:
        setup_build_files(ctx)

s3_asset = repository_rule(
    implementation = _s3_asset_impl,
    doc = """
s3_asset is a repository rule to download external dependencies from an AWS S3 bucket and exposes them
as build targets. It supports archives, jars or plain files.

This is non-hermetic (most repository rules are by their nature) as it depends on the aws CLI
being installed on the host system and a python interpreter for the same.

Example usage:
```
s3_asset(
    name = "foo_tgz",
    bucket = "bar-bucket",
    path = "files/foo.tar.gz",
    asset_type = "archive",
)

```
    """,
    attrs = {
        "bucket": attr.string(
            mandatory = True,
            doc = "Name of the S3 bucket where asset is located.",
        ),
        "path": attr.string(
            mandatory = True,
            doc = "Path to a file in a S3 bucket, should not be a prefix or wildcard.",
        ),
        "metadata_sha256_key": attr.string(
            doc = "If repository caching is desired, this attribute is required. It is to be set to the key in the S3 object metadata (https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingMetadata.html) which holds the sha256 of the content of the object. This must be set by the user on the object.",
        ),
        "sha256": attr.string(
            doc = "The sha256 checksum of the file to be downloaded, useful for repository caching. If set, then `metadata_sha256_key` must also be set.",
        ),
        "build_file_content": attr.string(
            doc = "The build file content for this repository.",
        ),
        "executable": attr.bool(
            default = False,
            doc = "If the asset type is a file and is desired to be an executable, this should be set to True.",
        ),
        "asset_type": attr.string(
            doc = "The type of asset(file/jar/archive)",
            default = "file",
        ),
        "strip_prefix": attr.string(
            doc = "If the asset is an archive, then this will strip the specified prefix after extraction",
        ),
    },
    environ = [
        "AWS_PROFILE",
        "AWS_ACCESS_KEY_ID",
        "AWS_SECRET_ACCESS_KEY",
        "AWS_DEFAULT_REGION",
    ],
)
