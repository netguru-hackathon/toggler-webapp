class WebhooksController < ApplicationController
  def slack
    @command_args = params["text"].split(" ")
    case @command_args.first
    when "login"
      return login
    when "default_project"
      return prompt_login unless current_user.present?
      return set_default_project
    when "default_billable"
      return prompt_login unless current_user.present?
      return set_default_billable
    when "start"
      return prompt_login unless current_user.present?
      start_time_entry
    when "stop"
      return prompt_login unless current_user.present?
      render text: TogglManager.new(current_user).stop_entry, status: 200
    when "list"
      return prompt_login unless current_user.present?
      render text: TogglManager.new(current_user).list_projects_with_tasks.join("\n"), status: 200
    when "current"
      return prompt_login unless current_user.present?
      render text: TogglManager.new(current_user).current_time_entry, status: 200
    else
      return render text: help_text, status: 200
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(slack_user_id: params[:user_id])
  end

  def help_text
    "Toggler usage: \n" \
    "First of all, link your Slack account with Toggl: `/toggl login TOGGL_API_KEY`\n" \
    "Secondly, set your default project: `/toggl default_project PROJECT_NAME`\n" \
    "You can also set if the entries should be billable by default: `/toggl default_billable true/false`\n" \
    "You can then start and stop your timer: `/toggl start` and `/toggl stop` - add '$' if the entry should be billable \n" \
    "If you work on multiple projects simply run `/toggl start PROJECT_NAME`\n" \
    "Optional arguments for `/toggl start` are: _PROJECT_NAME/TASK_NAME $ description_\n" \
    "Have fun with Toggler! :heart:"
  end

  def prompt_login
    render text: 'Please login with /toggl login TOGGL_API_KEY', status: 401
  end

  def login
    user = User.find_by(slack_user_id: slack_user_id)
    return register_user unless user
    return update_toggl_token
  end

  def set_default_project
    current_user.update(default_project_name: default_project)
    render plain: "Default project set to #{default_project}", status: 200
  end

  def set_default_billable
    current_user.update(default_billable: default_billable)
    render plain: "Default billable set to #{default_billable}", status: 200
  end

  def register_user
    User.create(slack_user_id: slack_user_id, toggl_api_token: toggl_api_token, default_workspace_name: "netguru", default_project_name: nil, default_billable: false)
    render text: 'Registered successfully', status: 200
  end

  def update_toggl_token
    current_user.update(toggl_api_token: toggl_api_token)
    render text: 'Update Toggl API token', status: 200
  end

  def slack_user_id
    params["user_id"]
  end

  def toggl_api_token
    @command_args.second
  end

  def default_project
    @command_args.second
  end

  def default_billable
    @command_args.second == "true"
  end

  def start_time_entry
    text = TogglManager.new(current_user).start_entry(description: @command_args[3],
                                                      project_name: @command_args[1]&.split("/")&.first,
                                                      task_name: @command_args[1]&.split("/")&.last,
                                                      billable: @command_args[2] == "$")
    render text: text, status: 200
  end
end
