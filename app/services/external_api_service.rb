class ExternalApiService
  require 'faraday'
  require 'json'

  def initialize
    @base_url = ENV['MOCK_SERVER_URL']
    @enabled = ENV['ENABLE_MOCK_SYNC'] == 'true'
    Rails.logger.debug "ExternalApiService initialized: base_url=#{@base_url}, enabled=#{@enabled}, env_value=#{ENV['ENABLE_MOCK_SYNC']}"
    @client = Faraday.new(@base_url) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def fetch_clients
    return [] unless mock_sync_enabled?

    begin
      response = @client.get('/clients')
      
      if response.success?
        clients_data = parse_response(response.body)
        Rails.logger.info "Fetched #{clients_data.length} clients from mock server"
        clients_data
      else
        Rails.logger.error "Failed to fetch clients from mock server: #{response.status}"
        []
      end
    rescue StandardError => e
      Rails.logger.error "Error fetching clients from mock server: #{e.message}"
      []
    end
  end

  def fetch_appointments
    return [] unless mock_sync_enabled?

    begin
      response = @client.get('/appointments')
      
      if response.success?
        appointments_data = parse_response(response.body)
        Rails.logger.info "Fetched #{appointments_data.length} appointments from mock server"
        appointments_data
      else
        Rails.logger.error "Failed to fetch appointments from mock server: #{response.status}"
        []
      end
    rescue StandardError => e
      Rails.logger.error "Error fetching appointments from mock server: #{e.message}"
      []
    end
  end

  def create_appointment(appointment_data)
    return { success: false, error: 'Mock sync disabled' } unless mock_sync_enabled?

    begin
      response = @client.post('/appointments') do |req|
        req.body = { appointment: appointment_data }
      end
      
      if response.success?
        result = parse_response(response.body)
        Rails.logger.info "Created appointment in mock server: #{result.inspect}"
        { success: true, data: result }
      else
        Rails.logger.error "Failed to create appointment in mock server: #{response.status}"
        { success: false, error: "Mock server error: #{response.status}" }
      end
    rescue StandardError => e
      Rails.logger.error "Error creating appointment in mock server: #{e.message}"
      { success: false, error: e.message }
    end
  end

  def create_client(client_data)
    return { success: false, error: 'Mock sync disabled' } unless mock_sync_enabled?

    begin
      response = @client.post('/clients') do |req|
        req.body = { client: client_data }
      end
      
      if response.success?
        result = parse_response(response.body)
        Rails.logger.info "Created client in mock server: #{result.inspect}"
        { success: true, data: result }
      else
        Rails.logger.error "Failed to create client in mock server: #{response.status}"
        { success: false, error: "Mock server error: #{response.status}" }
      end
    rescue StandardError => e
      Rails.logger.error "Error creating client in mock server: #{e.message}"
      { success: false, error: e.message }
    end
  end

  def healthy?
    return false unless mock_sync_enabled?

    begin
      response = @client.get('/clients')
      response.success?
    rescue StandardError => e
      Rails.logger.error "Mock server health check failed: #{e.message}"
      false
    end
  end

  private

  def mock_sync_enabled?
    @enabled && @base_url.present?
  end

  def parse_response(response_body)
    # Handle different response formats
    case response_body
    when Hash
      if response_body['data']
        response_body['data']
      elsif response_body['success'] && response_body['data']
        response_body['data']
      else
        response_body
      end
    when Array
      response_body
    when String
      begin
        parsed = JSON.parse(response_body)
        parse_response(parsed)
      rescue JSON::ParserError
        Rails.logger.error "Failed to parse JSON response: #{response_body}"
        []
      end
    else
      Rails.logger.warn "Unexpected response format: #{response_body.class}"
      []
    end
  end
end