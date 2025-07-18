class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :update, :destroy]
  before_action :set_external_api_service

  # GET /appointments
  def index
    local_appointments = Appointment.includes(:client).order(time: :asc)
    
    # Filter by client_id if provided
    local_appointments = local_appointments.where(client_id: params[:client_id]) if params[:client_id].present?
    
    external_appointments = @external_api_service.fetch_appointments
    
    # Merge local and external data
    merged_appointments = merge_appointments_data(local_appointments, external_appointments)
    
    render_success(merged_appointments)
  end

  # GET /appointments/1
  def show
    render_success(@appointment.as_json)
  end

  # POST /appointments
  def create
    @appointment = Appointment.new(appointment_params)

    if @appointment.save
      # Sync with mock server (non-blocking)
      sync_appointment_to_mock_server(@appointment)
      
      render_success(@appointment.as_json, "Appointment created successfully", :created)
    else
      render_error(@appointment.errors)
    end
  end

  # PATCH/PUT /appointments/1
  def update
    if @appointment.update(appointment_params)
      render_success(@appointment.as_json, "Appointment updated successfully")
    else
      render_error(@appointment.errors)
    end
  end

  # DELETE /appointments/1
  def destroy
    @appointment.destroy
    render_success({}, "Appointment deleted successfully")
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def set_external_api_service
    @external_api_service = ExternalApiService.new
  end

  def appointment_params
    params.require(:appointment).permit(:client_id, :time)
  end

  def merge_appointments_data(local_appointments, external_appointments)
    # Convert to JSON for consistent data structure
    local_data = local_appointments.as_json
    
    # Process external appointments
    external_data = external_appointments.map do |ext_appointment|
      {
        'id' => "ext_#{ext_appointment['id']}",
        'client_id' => ext_appointment['client_id'],
        'time' => ext_appointment['time'],
        'source' => 'external'
      }
    end
    
    # Add source identifier to local appointments
    local_data.each { |appointment| appointment['source'] = 'local' }
    
    # Merge arrays and sort by time
    all_appointments = local_data + external_data
    all_appointments.sort_by { |appointment| appointment['time'] }
  end

  def sync_appointment_to_mock_server(appointment)
    # Non-blocking sync - log errors but don't fail the request
    appointment_data = {
      client_id: appointment.client_id,
      time: appointment.time
    }
    
    result = @external_api_service.create_appointment(appointment_data)
    
    unless result[:success]
      Rails.logger.warn "Failed to sync appointment to mock server: #{result[:error]}"
    end
  end
end