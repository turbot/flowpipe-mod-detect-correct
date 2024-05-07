pipeline "correction_handler" {
  title       = "Correction Handler"
  description = "Generic pipeline for handling correction actions for Detect/Correct mods."

  param "notifier" {
    type        = string
    description = "The name of the notifier to use for sending notification messages. Defaults to 'default'"
    default     = "default"
  }

  param "notification_level" {
    type        = string
    description = "The verbosity level of notification to send, valid values are 'verbose', 'info', 'error'. Defaults to 'info'."
    default     = "info"
  }
 
  param "approvers" {
    type        = list(string)
    description = "A list of notifiers to use for decisions/approvals on actions to undertake, if set to an empty list, the 'default_action' will be used as the outcome. Defaults to an empty list."
    default     = []
  }

  param "default_action" {
    type        = string
    description = "The key of the action to use if no approvers are set. Defaults to 'notify'."
    default     = "notify"
  }

  param "enabled_actions" {
    type        = list(string)
    description = "A list of action keys identifying which actions are available for approvers, this will define the ordering in the UI."
    default     = ["skip"]
  }

  param "detect_msg" {
    type        = string
    description = "The message to display to approvers when asking for a decision or when simply notifying of detections."
    default     = "Detected item requiring action." 
  }

  param "actions" {
    description = "A map of actions, if approvers are set these will be offered as options to select, else the one matching the default_action will be used."
    type = map(object({
      label         = string
      value         = string
      style         = string
      pipeline_ref  = any
      pipeline_args = any
      success_msg   = string
      error_msg     = string
    }))
    default = {
      "skip" = {
        label         = "Skip"
        value         = "skip"
        style         = "info"
        pipeline_ref  = pipeline.optional_message
        pipeline_args = {
          notifier = "default"
          send     = false
          text     = "Skipped item."
        }
        success_msg   = ""
        error_msg     = ""
      }
    }
  }

  step "transform" "require_input" {
    value = (length(param.approvers) > 0)
  }

  step "input" "acquire_input" {
    if       = step.transform.require_input.value
    type     = "button"
    notifier = notifier[param.approvers[0]]
    prompt   = param.detect_msg
    options  = tolist([ for key in param.enabled_actions : {
      label = param.actions[key].label
      value = param.actions[key].value
      style = param.actions[key].style
    }])

    error {
      ignore = true
    }
  }

  step "transform" "determine_action" {
    value = ((step.transform.require_input.value && !is_error(step.input.acquire_input)) ?
      step.input.acquire_input.value :
      param.default_action
    )
  }

  step "message" "notify" {
    if       = step.transform.determine_action.value == "notify"
    notifier = notifier[param.notifier]
    text     = param.detect_msg
  }

  step "pipeline" "action" {
    if       = step.transform.determine_action.value != "notify"
    pipeline = param.actions[step.transform.determine_action.value].pipeline_ref
    args     = param.actions[step.transform.determine_action.value].pipeline_args
  }

  step "message" "action_result" {
    if = (
      step.transform.determine_action.value != "notify" && 
      step.transform.determine_action.value != "skip" && 
      (is_error(step.pipeline.action) || param.notification_level != "error")
    )
    notifier = notifier[param.notifier]
    text     = (is_error(step.pipeline.action) ?
      "${param.actions[step.transform.determine_action.value].error_msg}: ${error_message(step.pipeline.action)}" :
      param.actions[step.transform.determine_action.value].success_msg)
  }
}