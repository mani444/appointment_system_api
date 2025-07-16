# Appointment System API Testing Guide

## Quick Start

1. **Start the server:**
   ```bash
   rails server
   ```
   Server runs on: `http://localhost:3000`

2. **Load sample data:**
   ```bash
   rails db:seed
   ```

3. **Start background jobs (optional):**
   ```bash
   bin/jobs
   ```

## API Endpoints

### Base URL: `http://localhost:3000`

## Clients API

### GET /clients
Get all clients

```bash
curl -X GET http://localhost:3000/clients
```

**Response:**
```json
{
  "success": true,
  "message": null,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "1234567890"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com",
      "phone": "9876543210"
    }
  ]
}
```

### GET /clients/:id
Get specific client

```bash
curl -X GET http://localhost:3000/clients/1
```

**Response:**
```json
{
  "success": true,
  "message": null,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890"
  }
}
```

### POST /clients
Create new client

```bash
curl -X POST http://localhost:3000/clients \
  -H "Content-Type: application/json" \
  -d '{
    "client": {
      "name": "New Client",
      "email": "new@example.com",
      "phone": "5555555555"
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Client created successfully",
  "data": {
    "id": 3,
    "name": "New Client",
    "email": "new@example.com",
    "phone": "5555555555"
  }
}
```

### PUT /clients/:id
Update client

```bash
curl -X PUT http://localhost:3000/clients/1 \
  -H "Content-Type: application/json" \
  -d '{
    "client": {
      "name": "Updated Name",
      "email": "john@example.com",
      "phone": "1234567890"
    }
  }'
```

### DELETE /clients/:id
Delete client

```bash
curl -X DELETE http://localhost:3000/clients/1
```

## Appointments API

### GET /appointments
Get all appointments

```bash
curl -X GET http://localhost:3000/appointments
```

**Response:**
```json
{
  "success": true,
  "message": null,
  "data": [
    {
      "id": 1,
      "client_id": 1,
      "time": "2025-07-17T10:00:00.000Z"
    },
    {
      "id": 2,
      "client_id": 2,
      "time": "2025-07-17T14:00:00.000Z"
    }
  ]
}
```

### GET /appointments?client_id=1
Filter appointments by client

```bash
curl -X GET "http://localhost:3000/appointments?client_id=1"
```

### GET /appointments/:id
Get specific appointment

```bash
curl -X GET http://localhost:3000/appointments/1
```

### POST /appointments
Create new appointment

```bash
curl -X POST http://localhost:3000/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "appointment": {
      "client_id": 1,
      "time": "2025-07-20T15:00:00Z"
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Appointment created successfully",
  "data": {
    "id": 3,
    "client_id": 1,
    "time": "2025-07-20T15:00:00.000Z"
  }
}
```

### PUT /appointments/:id
Update appointment

```bash
curl -X PUT http://localhost:3000/appointments/1 \
  -H "Content-Type: application/json" \
  -d '{
    "appointment": {
      "client_id": 1,
      "time": "2025-07-17T11:00:00Z"
    }
  }'
```

### DELETE /appointments/:id
Delete appointment

```bash
curl -X DELETE http://localhost:3000/appointments/1
```

## Error Handling

### Validation Errors
```json
{
  "success": false,
  "errors": [
    "Name can't be blank",
    "Email has already been taken"
  ]
}
```

### Not Found Errors
```json
{
  "success": false,
  "errors": [
    "Couldn't find Client with 'id'=999"
  ]
}
```

## Frontend Integration Notes

### CORS
- CORS is enabled for all origins in development
- All standard HTTP methods are supported
- No authentication required for basic operations

### Data Format
- All requests should send JSON with `Content-Type: application/json`
- All responses are in JSON format
- Dates are in ISO 8601 format (e.g., "2025-07-17T10:00:00.000Z")

### Sample Frontend Code

#### JavaScript/Fetch
```javascript
// Get all clients
fetch('http://localhost:3000/clients')
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      console.log('Clients:', data.data);
    } else {
      console.error('Errors:', data.errors);
    }
  });

// Create appointment
fetch('http://localhost:3000/appointments', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    appointment: {
      client_id: 1,
      time: '2025-07-20T15:00:00Z'
    }
  })
})
.then(response => response.json())
.then(data => {
  if (data.success) {
    console.log('Appointment created:', data.data);
  } else {
    console.error('Errors:', data.errors);
  }
});
```

## Background Jobs

The system includes background jobs for:
- **Data Sync**: Runs every 6 hours (development) / 4 hours (production)
- **Daily Reminders**: Runs at 9am every day
- **Hourly Reminders**: Runs every hour

### Manual Job Testing
```bash
# Test data sync job
rails runner "DataSyncJob.perform_now('full')"

# Test reminder job
rails runner "AppointmentReminderJob.perform_now('daily')"
```

## Database Reset

To reset the database with fresh seed data:
```bash
rails db:drop db:create db:migrate db:seed
```

## Health Check

```bash
curl -X GET http://localhost:3000/up
```

This endpoint returns 200 if the application is running properly.