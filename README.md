# Appointment System API

A clean, focused Rails API for managing clients and appointments with PostgreSQL storage and periodic data synchronization.

## Table of Contents

- [Setup Instructions](#setup-instructions)
- [Technology Stack](#technology-stack)
- [Architecture Overview](#architecture-overview)
- [API Endpoints](#api-endpoints)
- [Design Decisions & Validation Assumptions](#design-decisions--validation-assumptions)
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

## Background Jobs

**Job:** `DataSyncJob`  
**Purpose:** Simulates periodic synchronization with external systems  
**Implementation:** Updates `updated_at` timestamps on all records  
**Frequency:** On-demand for demonstration

**Usage:**

```bash
# Test sync job
rails runner "DataSyncJob.perform_now"
```

## Time Investment

### Development Phases

- **Initial setup & models** - 2 hours
- **Controllers & routing** - 4 hours
- **Error handling & validation** - 1.5 hours
- **Background job implementation** - 1 hour
- **API testing & debugging** - 0.5 hour
- **Documentation & README** - 1 hours

**Total Time:** ~10 hours
