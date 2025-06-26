#!/bin/bash

set -e

echo "Setting up RTAP development environment..."

if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker first."
    exit 1
fi

echo "Creating directory structure..."
mkdir -p docker/{clickhouse/init,postgres/init,prometheus,grafana/provisioning/{dashboards,datasources}}

cat > docker/clickhouse/init/01-create-tables.sql << 'EOF'
CREATE DATABASE IF NOT EXISTS rtap_analytics;

USE rtap_analytics;

CREATE TABLE IF NOT EXISTS events_raw (
    event_id String,
    user_id String,
    session_id String,
    event_type String,
    event_data String,
    client_id String,
    timestamp DateTime64(3),
    received_at DateTime64(3) DEFAULT now64()
) ENGINE = MergeTree()
ORDER BY (event_type, timestamp, user_id)
PARTITION BY toYYYYMM(timestamp)
TTL timestamp + INTERVAL 2 YEAR;

CREATE TABLE IF NOT EXISTS events_aggregated (
    event_type String,
    client_id String,
    hour DateTime,
    event_count UInt64,
    unique_users UInt64
) ENGINE = SummingMergeTree(event_count, unique_users)
ORDER BY (event_type, client_id, hour)
PARTITION BY toYYYYMM(hour)
TTL hour + INTERVAL 1 YEAR;
EOF

cat > docker/postgres/init/01-init-schema.sql << 'EOF'
-- Create schemas
CREATE SCHEMA IF NOT EXISTS rtap_config;
CREATE SCHEMA IF NOT EXISTS rtap_users;

-- Create tables
CREATE TABLE IF NOT EXISTS rtap_config.clients (
    client_id VARCHAR(50) PRIMARY KEY,
    client_name VARCHAR(255) NOT NULL,
    api_key VARCHAR(255) NOT NULL UNIQUE,
    rate_limit_per_minute INTEGER DEFAULT 10000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS rtap_config.dashboards (
    dashboard_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id VARCHAR(50) REFERENCES rtap_config.clients(client_id),
    dashboard_name VARCHAR(255) NOT NULL,
    dashboard_config JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample client
INSERT INTO rtap_config.clients (client_id, client_name, api_key, rate_limit_per_minute)
VALUES ('test-client', 'Test Client', 'test-api-key-12345', 50000)
ON CONFLICT (client_id) DO NOTHING;
EOF

cat > docker/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'rtap-services'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['host.docker.internal:8081', 'host.docker.internal:8082', 'host.docker.internal:8083']
    scrape_interval: 5s
EOF

cat > docker/grafana/provisioning/datasources/datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true

  - name: ClickHouse
    type: clickhouse
    access: proxy
    url: http://clickhouse:8123
    database: rtap_analytics
    user: rtap_user
    secureJsonData:
      password: rtap_password
    editable: true
EOF

echo "Starting Docker containers..."
docker-compose -f docker/docker-compose.dev.yml up -d

echo "Waiting for services to start..."
sleep 30

echo "Checking service health..."

if docker exec rtap-kafka kafka-topics --bootstrap-server localhost:29092 --list > /dev/null 2>&1; then
    echo "Kafka is ready"
else
    echo "Kafka is not ready. Exiting setup."
    exit 1
fi

if docker exec rtap-kafka kafka-topics --bootstrap-server localhost:29092 --list > /dev/null 2>&1; then
    echo "Kafka is ready"
else
    echo "Kafka is not ready"
fi

if docker exec rtap-clickhouse clickhouse-client --query "SELECT 1" > /dev/null 2>&1; then
    echo "ClickHouse is ready"
else
    echo "ClickHouse is not ready"
fi

if docker exec rtap-redis redis-cli -a rtap_redis_password ping > /dev/null 2>&1; then
    echo "Redis is ready"
else
    echo "Redis is not ready"
fi

if docker exec rtap-postgres pg_isready -U rtap_user > /dev/null 2>&1; then
    echo "PostgreSQL is ready"
else
    echo "PostgreSQL is not ready"
fi

echo ""
echo "Development environment is ready!"
echo ""
echo "Services available at:"
echo "Grafana:    http://localhost:3000 (admin/rtap_admin_password)"
echo "Prometheus: http://localhost:9090"
echo "ClickHouse: http://localhost:8123 (rtap_user/rtap_password)"
echo "Redis:      localhost:6379 (password: rtap_redis_password)"
echo "PostgreSQL: localhost:5432 (rtap_user/rtap_postgres_password)"
echo "Kafka:      localhost:9092"
echo ""
echo "Next steps:"
echo "  1. cd services/event-collector"
echo "  2. ./mvnw spring-boot:run"
echo ""
EOF

chmod +x scripts/dev-setup.sh
