class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :update, :destroy]

  # GET /appointments
  def index
    @appointments = Appointment.includes(:client).order(time: :asc)
    
    # Filter by client_id if provided
    @appointments = @appointments.where(client_id: params[:client_id]) if params[:client_id].present?
    
    render_success(@appointments.as_json)
  end

  # GET /appointments/1
  def show
    render_success(@appointment.as_json)
  end

  # POST /appointments
  def create
    @appointment = Appointment.new(appointment_params)

    if @appointment.save
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

  def appointment_params
    params.require(:appointment).permit(:client_id, :time)
  end
end