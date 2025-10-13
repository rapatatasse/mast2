class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]

  # GET /clients or /clients.json
  def index
    @clients = current_user.clients.all.order(nom: :asc)
    
  end

  # GET /clients/1 or /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
    @users = User.all
  end

  # GET /clients/1/edit
  def edit
    @users = User.all
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params)
   
    
    @client.save
    redirect_to clients_path
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    
    @client.update(client_params)
    @client.nom = @client.nom.upcase
    @client.save!

    redirect_to clients_path
    
     
    
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
      params.require(:client).permit(:nom, :prenom, :description, :date_debut, :date_fin)
    end
end
