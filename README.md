# sphinx-to-branch

GitHub action to automatically build and publish Sphinx documentation. Default configuration runs `sphinx-build` and pushes the resulting build artifacts to the `gh-pages` branch along with a `.nojekyll` file. The action can also be used to run an arbitrary tool on the contents of one branch and then push the results to another branch if desired, but it is intended for Sphinx deployments and other similar workflows. Additional actions based on the console output of the build process (or any other command run) can be performed using the [`expect`][man-expect] program.

Note that this action only pushes the build artifacts to the `gh-pages` (or any other) branch and **does not** trigger a GitHub Pages build. Ensure that GitHub Pages is enabled for your repository and that the desired branch is configured as the [publishing source][gh-docs-conf-pub-source]. This ensures that a push to the specified repository triggers a pages build.

This is a _composite_ action and hence must be run on a Linux-based runner like `ubuntu-latest` or similar.

Developed and maintained by Research Technology (RT), Tufts Technology Services (TTS), Tufts University.

## Inputs

- `source-branch`

  - Branch to build documentation from. Defaults to the triggering branch.
  - Default: `${{ github.ref_name }}`

- `source-directory`

  - Directory on source branch containing documentation source files. Defaults to repository root.
  - Default: `""`

- `destination-branch`

  - Branch to push built documentation to. Defaults to `gh-pages` branch.
  - Default: `gh-pages`

- `destination-directory`

  - Directory on destination branch to push the built documentation to. Defaults to repository root.
  - Default: `""`

- `clear-destination`

  - Whether to delete all files from the destination branch before building. Must be set to `"true"` for deletion to occur. Other values ignored.
  - Default: `"false"`

- `remove-items`

  - Newline-delimited list of glob patterns to delete from the destination branch before building. Ignored if destination branch set to be cleared.
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

- `use-expect`

  - Whether to use `expect` to perform actions based on build console output. Must be set to `"true"` for `expect` to be used. Other values ignored.
  - Default: `"false"`

- `expect-timeout`

  - Number of seconds `expect` will wait for the build to complete. Must be an integer. Defaults to `-1`, which disables the timeout. Exceeding the time limit causes the build to quit and exit with success. Use `expect-pattern-action` to configure an alternate timeout behavior.

  - Default: `-1`

- `expect-pattern-action`

  - Pattern-action pairs passed to `expect` when monitoring console output. See [`man expect`][man-expect] and action README for examples and syntax details. Any timeout action must be specified here using the `timeout` pattern. Variable `$EXPECT_TIMEOUT` (value of `expect-timeout`) available for use.
  - Default: `""`

## Usage Examples

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

This places the outputs in a designated directory (`dev`) on the destination branch and uses `github-actions[bot]` as the committer instead of the author of the last commit on the source branch.

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
          dry-run: "true"
```

Note how the destination directory is cleared to ensure a clean build and the command is run with extra arguments to ensure that even minor issues invoke failure. The resulting build artifacts are not pushed to any branch because the `dry-run` flag is set.

### Monitoring Console Output

```yaml
name: strict-build
on:
  push:
    branches:
      - main
jobs:
  strict-build:
    runs-on: ubuntu-latest
    steps:
    - uses: tuftsrt/sphinx-to-branch@v1
        with:
          source-directory: source
          use-expect: "true"
          expect-timeout: 300
          expect-pattern-action: |
            "trying URL" {
              puts stderr "EXPECT: intercepted R package installation attempt"
              exit 1
            }
            timeout {
              puts stderr "EXPECT: build timed out after $EXPECT_TIMEOUT seconds"
              exit 1
            }
```

Here `expect` is used to fail the build and output an appropriate error message when either a timeout of 300 seconds (5 minutes) is exceeded or the phrase "trying URL" is outputted to the console, indicating a possible attempt at an R package installation during the build process. (This can be used to ensure all required R packages are listed in `environment.yml` and hence preinstalled into the build environment.)

## Advanced Usage

The `sphinx-build` command can be replaced with any other command with a similar signature. The specified command is executed in the **root** of the destination repository as follows.

```bash
$BUILD_CMD $BUILD_ARGS "$SRC_BRANCH/$SRC_DIR" "$OUT_BRANCH/$OUT_DIR"
```

When using `expect`, the following build script is used instead.

```tcl
#!/usr/bin/expect
set timeout $EXPECT_TIMEOUT
spawn $BUILD_CMD $BUILD_ARGS "$SRC_BRANCH/$SRC_DIR" "$OUT_BRANCH/$OUT_DIR"
expect {
  $EXPECT_PATTERNS
}
exit [lindex [wait] 3]
```

The build script is generated via Bash with all `$` variables replaced with their corresponding action inputs. The result is a [Tcl](https://www.tcl-lang.org/) script that is executed via `expect` to run the build. For more information on `expect` and possible pattern-action pairs, see [`man expect`][man-expect] and the book _Exploring Expect_ (ISBN: 978-1565920903) by Don Libes.

[gh-docs-conf-pub-source]: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site
[man-expect]: https://www.tcl-lang.org/man/expect5.31/expect.1.html
