# sphinx-to-branch

GitHub action to automatically build and publish Sphinx documentation. Default configuration runs `sphinx-build` and pushes the resulting build artifacts to the `gh-pages` branch along with a `.nojekyll` file. The action can also be used to run an arbitrary tool on the contents of one branch and then push the results to another branch if desired, but it is intended for Sphinx deployments and other similar workflows.

Note that this action only pushes the build artifacts to the `gh-pages` (or any other) branch and **does not** trigger a GitHub Pages build. Ensure that GitHub Pages is enabled for your repository and that the desired branch is configured as the [publishing source][gh-docs-conf-pug-source]. This ensures that a push to the specified repository triggers a pages build.

This is a _composite_ action and hence must be run on a Linux-based runner like `ubuntu-latest` or similar.

Developed and maintained by Research Technology (RT), Tufts Technology Services (TTS), Tufts University.

[gh-docs-conf-pug-source]: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site

## Inputs

- `source-branch`

  - Branch to build documentation from. Defaults to the triggering branch.
  - Default: `${{ github.ref_name }}`

- `destination-branch`

  - Branch to push built documentation to. Defaults to `gh-pages` branch.
  - Default: `gh-pages`

- `clear-destination`

  - Whether to delete all files from the destination branch before building. Must be set to `"true"` for deletion to occur. Other values ignored.
  - Default: `"false"`

- `remove-items`

  - Newline-delimited list of glob patterns to delete from the destination branch before building. Ignored if destination branch set to be cleared.
  - Default: `""`

- `source-directory`

  - Directory on source branch containing documentation source files. Defaults to repository root.
  - Default: `""`

- `destination-directory`

  - Directory on destination branch to push the built documentation to. Defaults to repository root.
  - Default: `""`

- `environment-file`

  - Conda environment YML file on source branch to install dependencies from. Must contain Sphinx and any other build dependencies. Defaults to `environment.yml` in repository root.
  - Default: `environment.yml`

- `build-command`

  - Command to build the documentation. Uses `sphinx-build` if omitted.
  - Default: `sphinx-build`

- `build-arguments`

  - Additional optional arguments to pass to the build command.
  - Default: `""`

- `add-nojekyll`

  - Whether to add a `.nojekyll` file to the root of the destination branch. Must be set to `"true"` for the file to be added. Other values ignored.
  - Default: `"true"`

- `commit-message`

  - Message to use when committing built documentation to destination branch. Defaults to the SHA of the triggering commit.
  - Default: `${{ github.sha }}`

- `use-bot`

  - Whether to use the `github-actions[bot]` account to commit and push changes. Must be set to `"true"` for the bot to be used. Other values ignored. (Author of the last commit on the source branch used by default.)
  - Default: `"false"`

- `dry-run`
  - Whether to run the action without pushing to the destination branch. Must be set to `"true"` for dry run to occur. Other values ignored. Can be used as a pull request status check confirming a successful build. (Destination branch will need to be cleared to ensure a clean build.)
  - Default: `"false"`

## Examples

### Basic Sphinx Build

```yaml
name: build-main
on:
  push:
    branches:
      - main
jobs:
  build-main:
    runs-on: ubuntu-latest
    steps:
    - uses: tuftsrt/sphinx-to-branch@v1
        with:
          source-directory: source
```

Note that `source-branch` and `destination-branch` do not need to be specified. The default behavior is to use the triggering branch (in this case `main`) as the source and `gh-pages` as the destination.

### Development Build

```yaml
name: build-develop
on:
  push:
    branches:
      - develop
jobs:
  build-develop:
    runs-on: ubuntu-latest
    steps:
    - uses: tuftsrt/sphinx-to-branch@v1
        with:
          source-directory: source
          destination-directory: dev
          use-bot: "true"
```

This places the outputs in a designated directory (`dev`) on the destination branch and uses the `github-actions[bot]` as the committer instead of the author of the last commit on the source branch.

### Pull Request Check for Successful Build

```yaml
name: test-build
on:
  pull_request:
    types:
      - opened
jobs:
  test-build:
    runs-on: ubuntu-latest
    steps:
    - uses: tuftsrt/sphinx-to-branch@v1
        with:
          source-directory: source
          clear-destination: "true"
          build-arguments: "--nitpicky --fail-on-warning"
```

Note how the destination directory is cleared to ensure a clean build and the command is run with extra arguments to ensure that even minor issues invoke failure.

## Advanced Usage

The `sphinx-build` command can be replaced with any other command with a similar signature. The specified command is executed in the **root** of the destination repository as follows.

```
[command] [arguments] [source-repo]/[source-dir] [destination-dir]
```
