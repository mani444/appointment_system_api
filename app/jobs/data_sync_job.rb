class DataSyncJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting periodic data sync simulation"
    
    # Simulate syncing client data
    sync_clients
    
    # Simulate syncing appointment data
    sync_appointments
    
    Rails.logger.info "Periodic data sync completed"
  end

  private

  def sync_clients
    Rails.logger.info "Syncing client data..."
    
    # Simulate external API sync by updating timestamps
    Client.find_each do |client|
      client.touch(:updated_at)
    end
    
    Rails.logger.info "Client sync completed. Total clients: #{Client.count}"
  end

  def sync_appointments
    Rails.logger.info "Syncing appointment data..."
    
    # Simulate external calendar sync by updating timestamps
    Appointment.find_each do |appointment|
      appointment.touch(:updated_at)
    end
    
    Rails.logger.info "Appointment sync completed. Total appointments: #{Appointment.count}"
  end
end