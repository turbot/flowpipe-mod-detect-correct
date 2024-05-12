# Detect Correct Mod for Flowpipe

Detect/Correct pipeline library for [Flowpipe](https://flowpipe.io), enabling writing of standardized detect and correct control flows.

## Getting Started

### Installation

Download and install Flowpipe (https://flowpipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install flowpipe
```

### Usage

[Initialize a mod](https://flowpipe.io/docs/build/index#initializing-a-mod):

```sh
mkdir my_mod
cd my_mod
flowpipe mod init
```

[Install the Detect/Correct mod](https://flowpipe.io/docs/build/mod-dependencies#mod-dependencies) as a dependency:

```sh
flowpipe mod install github.com/turbot/flowpipe-mod-detect-correct
```

[Use the dependency](https://flowpipe.io/docs/build/write-pipelines/index) in a pipeline step:

```sh
vi my_pipeline.fp
```

```hcl
pipeline "my_pipeline" {

  step "pipeline" "resolve_bad_item" {
    pipeline = detect_correct.pipeline.correction_handler
    args = {
      detect_msg      = "Detected an issue on item ${param.item_id}."
      default_action  = "delete_item"
      enabled_actions = ["skip", "delete_item"]
      actions = {
        "skip" = {
          label        = "Skip"
          value        = "skip"
          style        = "info"
          pipeline_ref = detect_correct.pipeline.optional_message
          pipeline_args = {
            notifier = "default"
            send     = false
            text     = "Skipped resolving item ${param.item_id}."
          }
          success_msg = ""
          error_msg   = ""
        },
        "delete_item" = {
          label        = "Delete Item"
          value        = "delete_item"
          style        = "alert"
          pipeline_ref = pipeline.delete_item
          pipeline_args = {
            item_id = param.item_id
          }
          success_msg = "Deleted ${param.item_id}."
          error_msg   = "Error deleting ${param.item_id}"
        }
      }
    }
  }
}
```

[Run the pipeline](https://flowpipe.io/docs/run/pipelines):

```sh
flowpipe pipeline run my_pipeline
```

## Open Source & Contributing

This repository is published under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). We look forward to collaborating with you!

[Flowpipe](https://flowpipe.io) is a product produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). It is distributed under our commercial terms. Others are allowed to make their own distribution of the software, but cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).

## Get Involved

**[Join #flowpipe on Slack →](https://flowpipe.io/community/join)**

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Flowpipe](https://github.com/turbot/flowpipe/labels/help%20wanted)
- [Detect/Correct Mod](https://github.com/turbot/flowpipe-mod-detect-correct/labels/help%20wanted)