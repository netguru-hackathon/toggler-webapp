class WebhooksController < ApplicationController
  def slack
    @command_args = params["text"].split(" ")
    case @command_args.first
    when "help"
      return render text: help_text, status: 200
    when "login"
      # login
    when "start"
      return login unless current_user.present?
    when "stop"
      return login unless current_user.present?
    when "list"
      return login unless current_user.present?
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(slack_user_id: params[:user_id])
  end

  def help_text
    "Toggler usage: blabla"
  end

  def login
    render text: "Please login", status: 401
  end
end
