class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]

  # GET /clients or /clients.json
  def index
    @clients = Client.all.order(nom: :asc)
    @clients = @clients.search(params[:query]) if params[:query].present?
  end

  # GET /clients/1 or /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new(user_id: current_user.id)
    @users = User.all
  end

  # GET /clients/1/edit
  def edit
    @users = User.all
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params)
    
    if @client.save
      redirect_to clients_path
    else
      render :new
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    
    if @client.update(client_params)
      redirect_to clients_path
    else
      render :edit
    end
    
    
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_path, status: :see_other, notice: "Client was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:nom, :prenom, :description, :date_debut, :date_fin, :user_id)
    end
end
