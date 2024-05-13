pipeline "decision" {
  title       = "Decision"
  description = "Allows for obtaining a decision from the provided notifier."
  
  param "seed" {
    type    = string
    default = uuid()
  }

  param "prompt" {
    type = string
  }

  param "options" {
    type = list(object({
      label = string
      value = string
      style = string
    }))
  }

  param "notifier" {
    type    = string
    default = "default"
  }

  // param "timeout" {
  //   type    = number
  //   default = 0
  // }

  step "input" "get_decision" {
    type     = "button"
    notifier = notifier[param.notifier]
    prompt   = param.prompt
    options  = param.options
    // timeout  = param.timeout
  }

  output "result" {
    value = step.input.get_decision.value
  }
}