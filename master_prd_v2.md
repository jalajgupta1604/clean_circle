# CleanCircle -- Master PRD v2

## 1. Product Overview

CleanCircle is a prepaid subscription-based waste collection SaaS
platform designed for urban cities in India. It enables households to
subscribe to bucket-based waste collection plans, track waste
generation, and incentivizes waste reduction through rewards and
analytics.

## 2. Objectives

-   Digitize door-to-door waste collection
-   Encourage waste reduction behavior
-   Provide operational tools for waste collectors
-   Enable data-driven waste management for cities

------------------------------------------------------------------------

# 3. User Personas

## Household User

Urban residents subscribing to waste collection services.

Goals: - Reliable waste pickup - Fair pricing - Track waste output -
Earn rewards

Pain Points: - Irregular collection - No transparency - Flat pricing

## Waste Collector Agent

Workers responsible for collecting waste from households.

Goals: - Efficient route - Easy pickup confirmation

## Operations Admin

Organization managing the service.

Goals: - Monitor pickups - Manage agents - Track revenue - Analyze waste
trends

------------------------------------------------------------------------

# 4. Core User Flows

## User Onboarding Flow

1.  User visits web app
2.  Login with Google OAuth
3.  Verify phone via OTP
4.  Add address
5.  Select bucket plan
6.  Add wallet balance
7.  Activate subscription

## Waste Pickup Flow

1.  Agent opens route in app
2.  Reaches household
3.  Scans QR code
4.  Confirms pickup
5.  GPS + timestamp stored
6.  Wallet deduction triggered
7.  Notification sent to user

## Wallet Recharge Flow

1.  User opens wallet
2.  Select recharge amount
3.  Pay via UPI/card
4.  Payment webhook confirms
5.  Wallet balance updated

## Reward Flow

1.  System calculates monthly waste reduction
2.  Reward eligibility checked
3.  Cashback credited to wallet

------------------------------------------------------------------------

# 5. API Design

## Auth APIs

POST /api/auth/google POST /api/auth/otp POST /api/auth/verify

## User APIs

GET /api/users/profile PATCH /api/users/profile

## Wallet APIs

POST /api/wallet/recharge GET /api/wallet/transactions

## Pickup APIs

POST /api/pickups/confirm GET /api/pickups/history

## Agent APIs

GET /api/agent/routes POST /api/agent/pickup-confirmation

## Admin APIs

GET /api/admin/dashboard POST /api/admin/create-agent

------------------------------------------------------------------------

# 6. Database Schema

## users

id name email phone address bucket_size wallet_balance

## agents

id name phone assigned_route

## pickups

id user_id agent_id bucket_size timestamp gps_coordinates status

## wallet_transactions

id user_id amount type source created_at

## subscriptions

id user_id plan_type bucket_size status

------------------------------------------------------------------------

# 7. Edge Cases

## Failed Payment

Wallet recharge fails → transaction rollback.

## Agent Offline

Pickup stored locally → synced when internet returns.

## Missed Pickup

Agent marks missed → user notified.

## Low Wallet Balance

Pickup blocked until recharge.

## Duplicate Pickup

Prevent double QR scan within defined time window.

------------------------------------------------------------------------

# 8. Security

-   OAuth authentication
-   JWT tokens
-   Payment webhook verification
-   Role-based access control

------------------------------------------------------------------------

# 9. Analytics

Metrics: - waste per household - pickup success rate - route
efficiency - agent productivity

------------------------------------------------------------------------

# 10. Future Integrations

-   IoT smart bins
-   RFID tagging
-   Smart weighing trucks
-   Carbon credit APIs
