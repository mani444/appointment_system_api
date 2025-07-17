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

## API Endpoints

### Base URL: `http://localhost:3000`

## Clients API

### GET /clients
Get all clients

```bash
curl -X GET http://localhost:3000/clients
```

### GET /clients/:id
Get specific client

```bash
curl -X GET http://localhost:3000/clients/1
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

## Response Format

All API responses follow this structure:

**Success Response:**
```json
{
  "success": true,
  "message": "Optional message",
  "data": { /* actual data */ }
}
```

**Error Response:**
```json
{
  "success": false,
  "errors": ["Error message 1", "Error message 2"]
}
```

## Background Jobs

The system includes a simple background job for periodic data sync:

```bash
# Test data sync job
rails runner "DataSyncJob.perform_now"
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