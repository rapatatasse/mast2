class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      @clients_count = current_user.clients.count
      @users_count = User.count
      @total_clients = Client.count
    end
  end
end
