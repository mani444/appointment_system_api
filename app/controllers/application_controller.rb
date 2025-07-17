class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  before_action :set_default_response_format
  before_action :log_request_info

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
end
