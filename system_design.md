# CleanCircle -- System Design (Scalable Architecture)

## Goal

Scale platform to support 1M households across multiple cities.

------------------------------------------------------------------------

# High Level Architecture

Clients: - Web App (Households) - Mobile App (Agents) - Admin Dashboard

Backend: - API Gateway - Microservices

Services: - User Service - Wallet Service - Pickup Service -
Notification Service - Analytics Service

------------------------------------------------------------------------

# Infrastructure

Cloud: AWS

Components:

API Layer - AWS ALB - Rails API servers

Data Layer - PostgreSQL (primary DB) - Redis (cache)

Async Processing - Sidekiq workers - Kafka (future scale)

Storage - S3 for images and logs

------------------------------------------------------------------------

# Service Responsibilities

User Service - authentication - profile management

Wallet Service - wallet balance - payment processing

Pickup Service - pickup confirmation - route tracking

Notification Service - SMS - push notifications

Analytics Service - waste analytics - dashboard metrics

------------------------------------------------------------------------

# Scaling Strategy

## Horizontal Scaling

Multiple API servers behind load balancer.

## Database Scaling

-   read replicas
-   partitioning by city

## Caching

Redis used for: - user session - route data - wallet balance quick
lookup

## Async Jobs

Sidekiq workers handle: - reward calculations - notifications -
analytics aggregation

------------------------------------------------------------------------

# Data Partition Strategy

Partition pickups table by: - city - month

This prevents huge table scans.

------------------------------------------------------------------------

# Reliability

Retry mechanisms for: - payment confirmation - pickup confirmation

Circuit breakers for third-party APIs.

------------------------------------------------------------------------

# Observability

Tools: - Prometheus - Grafana - AppSignal

Metrics: - API latency - pickup events - wallet transactions

------------------------------------------------------------------------

# Security

-   HTTPS everywhere
-   encrypted payment tokens
-   RBAC admin roles

------------------------------------------------------------------------

# Future Architecture

-   Move to event-driven architecture
-   Introduce data lake for waste analytics
-   AI prediction models
