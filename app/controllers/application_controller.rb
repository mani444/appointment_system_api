class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  before_action :set_default_response_format
  before_action :log_request_info

  # Comprehensive health check endpoint
  def health_check
    health_status = {
      database: check_database_health,
      external_api: check_external_api_health,
      timestamp: Time.current
    }
    
    overall_healthy = health_status[:database][:healthy] && 
                     (health_status[:external_api][:healthy] || !ENV['ENABLE_MOCK_SYNC'])
    
    status_code = overall_healthy ? :ok : :service_unavailable
    
    render json: {
      healthy: overall_healthy,
      services: health_status
    }, status: status_code
  end

  private

  def set_default_response_format
    request.format = :json
  end

  def log_request_info
    Rails.logger.info "API Request: #{request.method} #{request.path} from #{request.remote_ip}"
  end

  protected

  # Consistent JSON response format for all endpoints
  def render_success(data = {}, message = nil, status = :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end

  def render_error(errors, status = :unprocessable_entity)
    render json: {
      success: false,
      errors: format_errors(errors)
    }, status: status
  end

  private

  def record_not_found(exception)
    render_error([exception.message], :not_found)
  end

  def record_invalid(exception)
    render_error(exception.record.errors.full_messages, :unprocessable_entity)
  end

  def parameter_missing(exception)
    render_error([exception.message], :bad_request)
  end

  def format_errors(errors)
    case errors
    when String
      [errors]
    when Array
      errors
    when ActiveModel::Errors
      errors.full_messages
    else
      [errors.to_s]
    end
  end

  def check_database_health
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      { healthy: true, message: "Database connection successful" }
    rescue => e
      { healthy: false, message: "Database connection failed: #{e.message}" }
    end
  end

  def check_external_api_health
    sync_enabled = ENV['ENABLE_MOCK_SYNC'] == 'true'
    return { healthy: true, message: "External API sync disabled", sync_enabled: sync_enabled } unless sync_enabled
    
    begin
      external_api_service = ExternalApiService.new
      if external_api_service.healthy?
        { healthy: true, message: "External API connection successful", sync_enabled: sync_enabled }
      else
        { healthy: false, message: "External API connection failed", sync_enabled: sync_enabled }
      end
    rescue => e
      { healthy: false, message: "External API health check failed: #{e.message}", sync_enabled: sync_enabled }
    end
  end
end
