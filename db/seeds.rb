# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data in development
if Rails.env.development?
  puts "Clearing existing data..."
  Appointment.destroy_all
  Client.destroy_all
  puts "Existing data cleared."
end

# Create sample clients (matching your mock data structure)
puts "Creating sample clients..."
clients = [
  {
    name: "John Doe",
    email: "john@example.com",
    phone: "1234567890"
  },
  {
    name: "Jane Smith",
    email: "jane@example.com",
    phone: "9876543210"
  },
  {
    name: "Bob Johnson",
    email: "bob@example.com",
    phone: "5555555555"
  },
  {
    name: "Alice Brown",
    email: "alice@example.com",
    phone: "1111111111"
  }
]

created_clients = clients.map do |client_data|
  Client.find_or_create_by!(email: client_data[:email]) do |client|
    client.name = client_data[:name]
    client.phone = client_data[:phone]
  end
end

puts "Created #{created_clients.length} clients."

# Create sample appointments (matching your mock data structure)
puts "Creating sample appointments..."
appointments = [
  {
    client: created_clients[0],
    time: "2025-07-17T10:00:00Z"
  },
  {
    client: created_clients[1],
    time: "2025-07-17T14:00:00Z"
  },
  {
    client: created_clients[0],
    time: "2025-07-18T09:00:00Z"
  },
  {
    client: created_clients[2],
    time: "2025-07-18T11:00:00Z"
  },
  {
    client: created_clients[3],
    time: "2025-07-19T13:00:00Z"
  }
]

created_appointments = appointments.map do |appointment_data|
  Appointment.find_or_create_by!(
    client: appointment_data[:client],
    time: appointment_data[:time]
  )
end

puts "Created #{created_appointments.length} appointments."

puts "Seed data created successfully!"
puts "Clients: #{Client.count}"
puts "Appointments: #{Appointment.count}"
