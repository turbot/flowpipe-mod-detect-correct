pipeline "optional_message" {
  title       = "Optional Message"
  description = "Sends a message using a notifier if the send parameter is true."
  
  param "notifier" {
    type        = string
    description = "The notifier to use for sending message"
  }

  param "send" {
    type = bool
    description = "Boolean to indicate if the message should be sent."
  }

  param "text" {
    type        = string
    description = "The text of the message."
  }

  step "message" "send" {
    if       = param.send
    notifier = notifier[param.notifier]
    text     = param.text
  }
}