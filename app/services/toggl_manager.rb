class TogglManager

  def initialize
    @config = YAML::load_file('config.yml')
    init_api
    load_defaults
  end

  def start_entry(description = nil,
                  task_name = nil,
                  project_name = default_project["name"],
                  billable = default_billable,
                  workspace_name = default_workspace["name"])
    new_entry_attributes = {
      "wid" => workspace_id(workspace_name),
      "pid" => project_id(workspace_name, project_name),
      "billable" => billable,
      "duration" => Time.now.to_i * -1,
      "start" => @api.iso8601((Time.now - 3600).to_datetime),
      "created_with" => "toggler",
    }
    new_entry_attributes["description"] = description if description
    new_entry_attributes["tid"] = task_id(workspace_name, project_name, task_name) if task_name

    return "time entry started" if api.create_time_entry(new_entry_attributes)
    "error adding time entry"
  end

  def stop_entry
    time_entry_id = api.get_current_time_entry&.[]("id")
    return "no running time entry" unless time_entry_id
    return "time entry stopped" if api.stop_time_entry(time_entry_id)
    "error stopping time entry"
  end

  def list_projects_with_tasks(workspace_name = default_workspace["name"])
    projects_with_tasks(workspace_id(workspace_name))
  end

  private

  attr_reader :api, :user, :workspaces, :default_billable, :default_project, :default_workspace

  def init_api
    @api_key = @config["toggl_api_key"]
    @api = TogglV8::API.new(@api_key)
    @user = api.me(true)
    @workspaces = api.my_workspaces(user)
  end

  def load_defaults
    @default_billable = @config["billable_by_default"];
    @default_workspace = {
      "id" => workspace_id(@config["default_workspace_name"]),
      "name" => @config["default_workspace_name"]
    }
    @default_project = {
      "id" => project_id(@default_workspace["name"], @config["default_project_name"]),
      "name" => @config["default_project_name"]
    }
  end

  def list_projects(workspace_name = default_workspace["name"])
    wid = workspace_id(workspace_name)
    api.projects(wid)
  end

  def projects_with_tasks(wid)
    projects = api.projects(wid)
    tasks = api.tasks(wid)
    project_with_tasks = projects.map do |project|
      project_name = project["name"]
      project_tasks = tasks.select{ |task| task["pid"] == project["id"] }.map{ |taks| taks["name"] }
      "#{project_name}: \n\t#{project_tasks.join(', ')}"
    end
  end

  def workspace_id(workspace_name)
    workspaces.find { |w| w["name"] == workspace_name }["id"]
  end

  def project_id(workspace_name, project_name)
    list_projects(workspace_name)
      .find { |p| p["name"] == project_name }["id"]
  end

  def task_id(workspace_name, project_name, task_name)
    wid = workspace_id(workspace_name)
    pid = project_id(workspace_name, project_name)
    api.tasks(wid)
      .find { |t| t["pid"] == pid && t["name"] == task_name }["id"]
  end
end
