<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="github_private_release_asset"></a>

## github_private_release_asset

<pre>
github_private_release_asset(<a href="#github_private_release_asset-name">name</a>, <a href="#github_private_release_asset-asset_name">asset_name</a>, <a href="#github_private_release_asset-asset_type">asset_type</a>, <a href="#github_private_release_asset-build_file_content">build_file_content</a>, <a href="#github_private_release_asset-repo">repo</a>, <a href="#github_private_release_asset-repo_mapping">repo_mapping</a>,
                             <a href="#github_private_release_asset-sha256">sha256</a>, <a href="#github_private_release_asset-strip_prefix">strip_prefix</a>, <a href="#github_private_release_asset-tag">tag</a>)
</pre>

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

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="github_private_release_asset-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="github_private_release_asset-asset_name"></a>asset_name |  The name of the archive asset in the github release to be downloaded   | String | required |  |
| <a id="github_private_release_asset-asset_type"></a>asset_type |  The type of asset (archive/jar/file)   | String | optional |  `"file"`  |
| <a id="github_private_release_asset-build_file_content"></a>build_file_content |  The content of the build file for this repository.   | String | optional |  `""`  |
| <a id="github_private_release_asset-repo"></a>repo |  The github repo (HOST/owner/repo) from which the asset is to be downloaded   | String | required |  |
| <a id="github_private_release_asset-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<p>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="github_private_release_asset-sha256"></a>sha256 |  The sha256 checksum of the asset   | String | required |  |
| <a id="github_private_release_asset-strip_prefix"></a>strip_prefix |  If the asset is an archive, then this will strip the specified prefix after extraction   | String | optional |  `""`  |
| <a id="github_private_release_asset-tag"></a>tag |  The tag corresponding to the github release asset   | String | required |  |


