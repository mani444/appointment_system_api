# Deployment Guide

## Environment Variables

For production deployment, set these environment variables:

```bash
# Database
DATABASE_URL=postgresql://username:password@localhost/appointment_system_api_production

# CORS - Frontend domains that can access the API
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Rails
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Secret key (generate with: rails secret)
SECRET_KEY_BASE=your_secret_key_here
```

## Production Setup Commands

1. **Install dependencies:**
   ```bash
   bundle install --without development test
   ```

2. **Setup database:**
   ```bash
   RAILS_ENV=production rails db:create db:migrate
   ```

3. **Load seed data (optional):**
   ```bash
   RAILS_ENV=production rails db:seed
   ```

4. **Precompile assets (if needed):**
   ```bash
   RAILS_ENV=production rails assets:precompile
   ```

5. **Start the application:**
   ```bash
   RAILS_ENV=production rails server
   ```

6. **Start background jobs:**
   ```bash
   RAILS_ENV=production bin/jobs
   ```

## Docker Deployment

The project includes a Dockerfile for containerized deployment:

```bash
# Build image
docker build -t appointment-api .

# Run container
docker run -p 3000:3000 \
  -e DATABASE_URL=postgresql://... \
  -e ALLOWED_ORIGINS=https://yourdomain.com \
  -e SECRET_KEY_BASE=your_secret_key \
  appointment-api
```

## Kamal Deployment

The project is configured for Kamal deployment:

```bash
# Deploy to production
kamal deploy
```

## Health Check

Your deployment should respond to:
- `GET /up` - Application health check
- `GET /clients` - API functionality check

## Monitoring

- Check logs: `tail -f log/production.log`
- Monitor background jobs: Check Solid Queue dashboard
- Database performance: Monitor PostgreSQL logs

## Security Notes

- CORS is restricted to specific domains in production
- All API requests are logged
- Database connections are pooled
- Background jobs are processed securely

## Scaling

- **Horizontal scaling**: Run multiple app instances behind a load balancer
- **Background jobs**: Scale job workers independently
- **Database**: Use connection pooling and read replicas if needed