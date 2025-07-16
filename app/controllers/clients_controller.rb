class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :update, :destroy]

  # GET /clients
  def index
    @clients = Client.all.order(created_at: :desc)
    render_success(@clients.as_json)
  end

  # GET /clients/1
  def show
    render_success(@client.as_json)
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    if @client.save
      render_success(@client.as_json, "Client created successfully", :created)
    else
      render_error(@client.errors)
    end
  end

  # PATCH/PUT /clients/1
  def update
    if @client.update(client_params)
      render_success(@client.as_json, "Client updated successfully")
    else
      render_error(@client.errors)
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy
    render_success({}, "Client deleted successfully")
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :phone)
  end
end