# Real-Time Analytics Platform

> Real-Time Analytics Platform is a microservices-based system for collecting, processing, and visualizing real-time data
> using Apache Kafka, Spring Boot, Redis, and ClickHouse. It aggregates and stores data in real time, offering insights into user behavior,
> system performance, and key metrics with monitoring and alerting tools.

## Features
- **Event Collection**: Collects real-time events from web and mobile applications.
- **Real-Time Data Processing**: Uses Apache Kafka for real-time event streaming and processing.
- **Data Aggregation**: Aggregates data in real time and stores it in OLAP databases like ClickHouse.
- **Visualization**: Dashboards for data visualization using Grafana and Apache Superset.
- **Alerting**: Real-time alerts based on thresholds using Kafka and integrated notification services.
- **Scalable Architecture**: Built with microservices using Spring Boot, Docker, and Kubernetes for scalability.

## Technologies
- **Backend**: Java, Spring Boot, Kafka, Redis, PostgreSQL
- **Data Storage**: ClickHouse, AWS S3/MinIO
- **Real-Time Processing**: Apache Kafka, Kafka Streams
- **Frontend/Visualization**: Grafana, Apache Superset
- **Orchestration & Deployment**: Docker, Kubernetes, Terraform
- **CI/CD**: GitHub Actions, Jenkins
- **Notifications**: Telegram Bot API, JavaMail API

## Getting Started

### Prerequisites
Make sure you have the following installed:
- [Docker](https://www.docker.com/get-started)
- [Kubernetes](https://kubernetes.io/docs/setup/)
- [Java 11+](https://adoptopenjdk.net/)
- [Apache Kafka](https://kafka.apache.org/)
- [ClickHouse](https://clickhouse.com/)
- [Grafana](https://grafana.com/)
- [Apache Superset](https://superset.apache.org/)

### Setup
Clone the repository:

```bash
git clone https://github.com/mykola-yefremov/real-time-analytics-platform.git
cd real-time-analytics-platform
