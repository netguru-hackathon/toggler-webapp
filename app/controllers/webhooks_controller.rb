class WebhooksController < ApplicationController
  def slack
    @command_args = params["text"].split(" ")
    case @command_args.first
    when "help"
      return render text: help_text, status: 200
    when "login"
      login
    when "start"
      return prompt_login unless current_user.present?
    when "stop"
      return prompt_login unless current_user.present?
    when "list"
      return prompt_login unless current_user.present?
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(slack_user_id: params[:user_id])
  end

  def help_text
    "Toggler usage: blabla"
  end

  def prompt_login
    render text: 'Please login with /toggl login TOGGL_API_KEY', status: 401
  end

  def login
    user = User.find_by(slack_user_id: slack_user_id)
    return register_user unless user
    return update_toggl_token
  end

  private

  def register_user
    User.create(slack_user_id: slack_user_id, toggl_api_token: toggl_api_token)
  end

  def update_toggl_token
    current_user
  end

  def slack_user_id
    params["user_id"]
  end

  def toggl_api_token
    @command_args.second
  end
end
