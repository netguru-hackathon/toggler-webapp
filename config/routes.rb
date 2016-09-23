Rails.application.routes.draw do
  get 'webhooks/slack'

  post "/slack_webhook" => "webhooks#slack"
end
