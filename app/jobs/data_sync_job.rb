class DataSyncJob < ApplicationJob
  queue_as :default

  def perform(sync_type = 'full')
    Rails.logger.info "Starting data sync: #{sync_type}"
    
    case sync_type
    when 'full'
      sync_all_data
    when 'appointments'
      sync_appointments
    when 'clients'
      sync_clients
    else
      Rails.logger.warn "Unknown sync type: #{sync_type}"
    end
    
    Rails.logger.info "Data sync completed: #{sync_type}"
  end

  private

  def sync_all_data
    sync_clients
    sync_appointments
    cleanup_old_data
  end

  def sync_clients
    # Simulate external API sync for clients
    Rails.logger.info "Syncing client data..."
    
    # Example: Update client data, validate emails, etc.
    Client.find_each do |client|
      # Simulate some sync operation
      client.touch(:updated_at)
    end
    
    Rails.logger.info "Client sync completed. Total clients: #{Client.count}"
  end

  def sync_appointments
    # Simulate external calendar sync for appointments
    Rails.logger.info "Syncing appointment data..."
    
    # Example: Sync with external calendar systems
    Appointment.find_each do |appointment|
      # Simulate some sync operation
      appointment.touch(:updated_at)
    end
    
    Rails.logger.info "Appointment sync completed. Total appointments: #{Appointment.count}"
  end

  def cleanup_old_data
    # Clean up old appointments (older than 30 days)
    old_appointments = Appointment.where("time < ?", 30.days.ago)
    count = old_appointments.count
    
    if count > 0
      old_appointments.destroy_all
      Rails.logger.info "Cleaned up #{count} old appointments"
    end
  end
end