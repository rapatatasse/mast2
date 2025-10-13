class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @clientsnb = current_user.clients.count
    @clients = current_user.clients.all
  end
end
