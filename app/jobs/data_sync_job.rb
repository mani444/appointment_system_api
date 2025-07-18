class DataSyncJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting bidirectional data sync with mock server"
    
    @external_api_service = ExternalApiService.new
    
    # Check if external API is available
    unless @external_api_service.healthy?
      Rails.logger.warn "Mock server not available, skipping sync"
      return
    end
    
    sync_clients_bidirectional
    sync_appointments_bidirectional
    
    Rails.logger.info "Bidirectional data sync completed"
  end

  private

  def sync_clients_bidirectional
    Rails.logger.info "Syncing client data bidirectionally..."
    
    # Fetch external clients
    external_clients = @external_api_service.fetch_clients
    created_count = 0
    updated_count = 0
    
    external_clients.each do |ext_client|
      # Try to find existing client by email
      existing_client = Client.find_by(email: ext_client['email'])
      
      if existing_client
        # Update existing client if external data is newer
        if should_update_client?(existing_client, ext_client)
          existing_client.update(
            name: ext_client['name'],
            phone: ext_client['phone']
          )
          updated_count += 1
          Rails.logger.debug "Updated client: #{existing_client.email}"
        end
      else
        # Create new client from external data
        new_client = Client.create(
          name: ext_client['name'],
          email: ext_client['email'],
          phone: ext_client['phone']
        )
        
        if new_client.persisted?
          created_count += 1
          Rails.logger.debug "Created new client: #{new_client.email}"
        else
          Rails.logger.error "Failed to create client: #{new_client.errors.full_messages}"
        end
      end
    end
    
    Rails.logger.info "Client sync completed. Created: #{created_count}, Updated: #{updated_count}, Total local: #{Client.count}"
  end

  def sync_appointments_bidirectional
    Rails.logger.info "Syncing appointment data bidirectionally..."
    
    # Fetch external appointments
    external_appointments = @external_api_service.fetch_appointments
    created_count = 0
    
    external_appointments.each do |ext_appointment|
      # Check if appointment already exists (by client_id and time)
      existing_appointment = Appointment.find_by(
        client_id: ext_appointment['client_id'],
        time: ext_appointment['time']
      )
      
      unless existing_appointment
        # Create new appointment from external data
        new_appointment = Appointment.create(
          client_id: ext_appointment['client_id'],
          time: ext_appointment['time']
        )
        
        if new_appointment.persisted?
          created_count += 1
          Rails.logger.debug "Created new appointment: #{new_appointment.time}"
        else
          Rails.logger.error "Failed to create appointment: #{new_appointment.errors.full_messages}"
        end
      end
    end
    
    Rails.logger.info "Appointment sync completed. Created: #{created_count}, Total local: #{Appointment.count}"
  end

  def should_update_client?(local_client, external_client)
    # Simple logic: always update if external data is different
    local_client.name != external_client['name'] || 
    local_client.phone != external_client['phone']
  end
end