class WebhooksController < ApplicationController
  def slack
    command = params["text"]
    if command == "help"
      render text: help_text, status: 200
    end
    # if (command =~ "login")
  end

  def help_text
    "Toggler usage: blabla"
  end
end
