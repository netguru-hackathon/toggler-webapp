class WebhooksController < ApplicationController
  def slack
    @command_args = params["text"].split(" ")
    case @command_args.first
    when "login"
      return login
    when "start"
      return prompt_login unless current_user.present?
    when "stop"
      return prompt_login unless current_user.present?
    when "list"
      return prompt_login unless current_user.present?
    end
    return render text: help_text, status: 200
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

  def register_user
    User.create(slack_user_id: slack_user_id, toggl_api_token: toggl_api_token, default_workspace_name: "Dajvido's workspace", default_project_name: default_project, default_billable: false)
    render text: 'Registered successfully', status: 200
  end

  def update_toggl_token
    current_user.update(slack_user_id: slack_user_id, toggl_api_token: toggl_api_token, default_workspace_name: "Dajvido's workspace", default_project_name: default_project, default_billable: false)
    render text: 'Update Toggl API token', status: 200
  end

  def slack_user_id
    params["user_id"]
  end

  def toggl_api_token
    @command_args.second
  end

  def default_project
    @command_args.third
  end
end
