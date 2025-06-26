# RTAP

Real-time analytics platform for high-throughput event processing and visualization.

## Architecture Overview

This platform processes millions of events per day using:
- Event ingestion via REST/gRPC APIs
- Stream processing with Apache Kafka
- OLAP storage with ClickHouse
- Real-time dashboards with Grafana

# Services

- **event-collector:** High-throughput event ingestion service
- **event-processor:** Real-time stream processing with Kafka Streams
- **storage-service:** Data storage and query API
- **dashboard-service** Dashboard backend and analytics API
- **notification-service:** Alert and notification service

## Quick Start

```bash
# Start local development environment
./scripts/dev-setup.sh

# Run all services
docker-compose -f docker/docker-compose.dev.yml up -d