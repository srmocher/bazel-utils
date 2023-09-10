<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="s3_asset"></a>

## s3_asset

<pre>
s3_asset(<a href="#s3_asset-name">name</a>, <a href="#s3_asset-asset_type">asset_type</a>, <a href="#s3_asset-bucket">bucket</a>, <a href="#s3_asset-build_file_content">build_file_content</a>, <a href="#s3_asset-executable">executable</a>, <a href="#s3_asset-metadata_sha256_key">metadata_sha256_key</a>, <a href="#s3_asset-path">path</a>,
         <a href="#s3_asset-repo_mapping">repo_mapping</a>, <a href="#s3_asset-sha256">sha256</a>, <a href="#s3_asset-strip_prefix">strip_prefix</a>)
</pre>

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

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="s3_asset-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="s3_asset-asset_type"></a>asset_type |  The type of asset(file/jar/archive)   | String | optional |  `"file"`  |
| <a id="s3_asset-bucket"></a>bucket |  Name of the S3 bucket where asset is located.   | String | required |  |
| <a id="s3_asset-build_file_content"></a>build_file_content |  The build file content for this repository.   | String | optional |  `""`  |
| <a id="s3_asset-executable"></a>executable |  If the asset type is a file and is desired to be an executable, this should be set to True.   | Boolean | optional |  `False`  |
| <a id="s3_asset-metadata_sha256_key"></a>metadata_sha256_key |  If repository caching is desired, this attribute is required. It is to be set to the key in the S3 object metadata (https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingMetadata.html) which holds the sha256 of the content of the object. This must be set by the user on the object.   | String | optional |  `""`  |
| <a id="s3_asset-path"></a>path |  Path to a file in a S3 bucket, should not be a prefix or wildcard.   | String | required |  |
| <a id="s3_asset-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<p>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="s3_asset-sha256"></a>sha256 |  The sha256 checksum of the file to be downloaded, useful for repository caching. If set, then `metadata_sha256_key` must also be set.   | String | optional |  `""`  |
| <a id="s3_asset-strip_prefix"></a>strip_prefix |  If the asset is an archive, then this will strip the specified prefix after extraction   | String | optional |  `""`  |


