class WebhooksController < ApplicationController
  def slack
    @command_args = params["text"].split(" ")
    case @command_args.first
    when "help"
      return render text: help_text, status: 200
    when "login"
      # login
    when "start"
      # start
    when "stop"
      # stop
    when "list"
      # list
    end
  end

  private

  def help_text
    "Toggler usage: blabla"
  end
end
