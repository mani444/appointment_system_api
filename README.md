# Appointment System API

A clean, focused Rails API for managing clients and appointments with PostgreSQL storage and periodic data synchronization.

## Table of Contents

- [Setup Instructions](#setup-instructions)
- [Technology Stack](#technology-stack)
- [Architecture Overview](#architecture-overview)
- [API Endpoints](#api-endpoints)
- [Design Decisions & Validation Assumptions](#design-decisions--validation-assumptions)
- [Mock Server Integration](#mock-server-integration)
- [Error Handling](#error-handling)
- [Background Jobs](#background-jobs)
- [Time Investment](#time-investment)

## Setup Instructions

### Prerequisites

- Ruby 3.2+ (check with `ruby -v`)
- Rails 8.0.2
- PostgreSQL 13+ (check with `psql --version`)
- Git

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/mani444/appointment_system_api.git
   cd appointment_system_api
   ```

2. **Install dependencies**

   ```bash
   bundle install
   ```

3. **Environment setup**

   ```bash
   # Copy environment template
   cp .env.example .env

   # Edit .env with your database credentials if needed
   # Default values should work for local development
   ```

4. **Database setup**

   ```bash
   # Create and migrate database
   rails db:create
   rails db:migrate

   # Load sample data (optional)
   rails db:seed
   ```

5. **Start the server**

   ```bash
   rails server
   ```

   The API will be available at `http://localhost:3000`

6. **Verify setup**

   ```bash
   curl http://localhost:3000/up
   # Should return: HTML page with green background

   curl http://localhost:3000/clients
   # Should return: JSON with clients array
   ```

## Technology Stack

### Core Technologies

- **Ruby on Rails 8.0.2** - Web framework with API configuration
- **PostgreSQL** - Primary database for data persistence
- **Puma** - Web server for handling HTTP requests

### Supporting Libraries

- **bootsnap** - Boot time optimization
- **rack-cors** - Cross-origin resource sharing support
- **debug** - Development debugging tools

### Infrastructure

- **Git** - Version control
- **Bundler** - Dependency management

## Architecture Overview

### Data Model

```
Client (1) ──── (many) Appointment
├── id (primary key)     ├── id (primary key)
├── name                 ├── client_id (foreign key)
├── email (unique)       ├── time
├── phone                ├── created_at
├── created_at           └── updated_at
└── updated_at
```

### Request Flow

1. **Request** → Rails Router → Controller
2. **Controller** → Model validation → Database
3. **Response** → Structured JSON via helper methods

## API Endpoints

### Core Endpoints (Required)

#### Clients

- `GET /clients` - Fetch list of all clients
- `POST /clients` - Create new client

#### Appointments

- `GET /appointments` - Fetch list of all appointments
- `GET /appointments?client_id=1` - Filter appointments by client
- `POST /appointments` - Create new appointment

### Bonus Endpoints (Full CRUD)

#### Extended Client Operations

- `GET /clients/:id` - Get specific client
- `PUT /clients/:id` - Update client
- `DELETE /clients/:id` - Delete client

#### Extended Appointment Operations

- `GET /appointments/:id` - Get specific appointment
- `PUT /appointments/:id` - Update appointment
- `DELETE /appointments/:id` - Delete appointment

All endpoints return JSON in this format:

**Success Response:**

```json
{
  "success": true,
  "message": "Optional message",
  "data": {
    /* actual data */
  }
}
```

**Error Response:**

```json
{
  "success": false,
  "errors": ["Error message 1", "Error message 2"]
}
```

## Design Decisions & Validation Assumptions

- **Client validation** - Name (2-100 chars), unique email, phone required
- **Appointment validation** - Time required, must be future date
- **Database constraints** - Foreign keys, unique indexes for data integrity
- **Email uniqueness** - Each client must have a unique email address
- **Development environment** - CORS allows all origins

## Error Handling

- **Database errors** - Caught and returned as user-friendly messages
- **Missing records** - Clear 404 responses with specific error messages
- **Validation failures** - Detailed field-level error information

## Mock Server Integration

This API integrates with a **Postman mock server** to demonstrate multi-data-source architecture patterns commonly used in enterprise applications.

### Configuration

The mock server integration is configured via environment variables:

```bash
# Mock Server Configuration
MOCK_SERVER_URL=https://a0563492-369f-49d5-9f4f-647b5b994c95.mock.pstmn.io
ENABLE_MOCK_SYNC=true
```

### How It Works

1. **Dual Data Sources**: The API serves as an integration layer between:

   - **Local PostgreSQL database** (primary storage)
   - **External mock server** (simulates CRM/legacy systems)

2. **Data Merging**: API endpoints automatically merge data from both sources:

   - Local data tagged with `"source": "local"`
   - External data tagged with `"source": "external"`
   - Duplicate prevention via email uniqueness for clients

3. **Bidirectional Sync**: Background jobs sync data between systems

### API Behavior

- **GET /clients**: Returns merged client data from both local DB and mock server
- **GET /appointments**: Returns merged appointment data from both sources
- **POST /clients**: Creates locally + syncs to mock server (non-blocking)
- **POST /appointments**: Creates locally + syncs to mock server (non-blocking)

### Health Monitoring

```bash
# Check overall system health including external API
curl http://localhost:3000/health

# Response includes:
# - Database connection status
# - Mock server connectivity
# - Sync enablement status
```

## Background Jobs

**Job:** `DataSyncJob`  
**Purpose:** Bidirectional data synchronization with external mock server  
**Implementation:**

- Fetches clients/appointments from mock server
- Creates/updates local records based on external data
- Handles conflicts and validation errors gracefully
- Logs sync operations and statistics

**Usage:**

```bash
# Manual sync execution
rails runner "DataSyncJob.perform_now"

# Monitor sync results in logs
tail -f log/development.log
```

### Setting Up Your Own Mock Server

To set up your own Postman mock server:

1. **Import Collection**: Import your API collection into Postman
2. **Create Mock Server**:
   - Select "Mock servers" in Postman sidebar
   - Click "Create mock server"
   - Choose your collection
   - Configure server settings (public/private)
3. **Get Mock URL**: Copy the generated mock server URL
4. **Update Environment**: Replace `MOCK_SERVER_URL` in `.env` with your mock URL
5. **Add Response Examples**: Add example responses to your collection requests
6. **Test Integration**: Verify the health check endpoint shows external API as healthy


## Time Investment

### Development Phases

- **Initial setup & models** - 2 hours
- **Controllers & routing** - 4 hours
- **Error handling & validation** - 1.5 hours
- **Background job implementation** - 1 hour
- **API testing & debugging** - 0.5 hour
- **Mock server integration** - 3 hours
- **Multi-data-source architecture** - 2 hours
- **Documentation & README** - 1 hours

**Total Time:** ~15 hours
