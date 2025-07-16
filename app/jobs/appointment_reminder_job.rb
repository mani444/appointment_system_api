class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(reminder_type = 'daily')
    Rails.logger.info "Starting appointment reminders: #{reminder_type}"
    
    case reminder_type
    when 'daily'
      send_daily_reminders
    when 'hourly'
      send_hourly_reminders
    else
      Rails.logger.warn "Unknown reminder type: #{reminder_type}"
    end
    
    Rails.logger.info "Appointment reminders completed: #{reminder_type}"
  end

  private

  def send_daily_reminders
    # Find appointments for tomorrow
    tomorrow_appointments = Appointment.includes(:client)
                                     .where(time: Date.tomorrow.all_day)
                                     .order(:time)
    
    Rails.logger.info "Found #{tomorrow_appointments.count} appointments for tomorrow"
    
    tomorrow_appointments.each do |appointment|
      # In a real app, you'd send email/SMS here
      Rails.logger.info "Reminder: #{appointment.client.name} has appointment at #{appointment.time}"
    end
  end

  def send_hourly_reminders
    # Find appointments in the next hour
    next_hour_appointments = Appointment.includes(:client)
                                      .where(time: Time.current..1.hour.from_now)
                                      .order(:time)
    
    Rails.logger.info "Found #{next_hour_appointments.count} appointments in the next hour"
    
    next_hour_appointments.each do |appointment|
      # In a real app, you'd send urgent reminders here
      Rails.logger.info "Urgent reminder: #{appointment.client.name} has appointment at #{appointment.time}"
    end
  end
end