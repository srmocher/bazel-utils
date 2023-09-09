# bazel-utils

This repository contains some utility Bazel rules for various usecases. Currently, it has a utility repository rule to download external dependencies from private Github repositories.

## Getting Started

This repository doesn't support bzlmod yet. In the meantime, you can pull it in your repository using the `WORKSPACE` file

```
http_archive(
    name = "smocherla_bazel_utils",
    url = "https://github.com/smocherla-brex/bazel-utils/archive/refs/tags/v0.0.1-alpha.zip"
    strip_prefix = "bazel-utils-0.0.1-alpha",
    sha256 = "6911e9730f3da095c03f41f1b45728eb9edb7f727d732683f78631a2acf6883c",
)

load("@smocherla_bazel_utils//:repos.bzl", "bazel_utils_deps", "github_rule_deps")

bazel_utils_deps()

github_rule_deps()
```

## Rules

- [github_private_release_asset](https://github.com/smocherla-brex/bazel-utils/blob/v0.0.1-alpha/rules/repo_utils/github_doc.md#github_private_release_asset) - Repository rule to download private Github assets and expose build targets for archives/jars/plain files. Authentication is supported by providing a Github token as either an environment variable through `GH_TOKEN` or an entry in the `.netrc` file at `~/.netrc`.
