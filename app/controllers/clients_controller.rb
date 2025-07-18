class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :update, :destroy]
  before_action :set_external_api_service

  # GET /clients
  def index
    local_clients = Client.all.order(created_at: :desc)
    external_clients = @external_api_service.fetch_clients
    
    # Merge local and external data, avoiding duplicates by email
    merged_clients = merge_clients_data(local_clients, external_clients)
    
    render_success(merged_clients)
  end

  # GET /clients/1
  def show
    render_success(@client.as_json)
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    if @client.save
      # Sync with mock server (non-blocking)
      sync_client_to_mock_server(@client)
      
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

  def set_external_api_service
    @external_api_service = ExternalApiService.new
  end

  def client_params
    params.require(:client).permit(:name, :email, :phone)
  end

  def merge_clients_data(local_clients, external_clients)
    # Convert to JSON for consistent data structure
    local_data = local_clients.as_json
    
    # Process external clients
    external_data = external_clients.map do |ext_client|
      {
        'id' => "ext_#{ext_client['id']}",
        'name' => ext_client['name'],
        'email' => ext_client['email'],
        'phone' => ext_client['phone'],
        'source' => 'external'
      }
    end
    
    # Add source identifier to local clients
    local_data.each { |client| client['source'] = 'local' }
    
    # Merge arrays, avoiding duplicates by email
    all_clients = local_data + external_data
    unique_clients = all_clients.uniq { |client| client['email'] }
    
    unique_clients
  end

  def sync_client_to_mock_server(client)
    # Non-blocking sync - log errors but don't fail the request
    client_data = {
      name: client.name,
      email: client.email,
      phone: client.phone
    }
    
    result = @external_api_service.create_client(client_data)
    
    unless result[:success]
      Rails.logger.warn "Failed to sync client to mock server: #{result[:error]}"
    end
  end
end