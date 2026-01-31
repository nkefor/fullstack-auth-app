# ARCHITECTURE.md

This document describes the architecture of the application inside and out.

---

## Overview

The project consists of three main components:

```
┌─────────────────────────────────────────────────────────────────┐
│                        INFRASTRUCTURE                           │
│                         (Terraform)                             │
│  ┌─────────────────────┐    ┌─────────────────────────────┐    │
│  │   S3 Secure Bucket  │    │   S3 Evidence Store         │    │
│  │   (Development)     │    │   (Compliance/Immutable)    │    │
│  └─────────────────────┘    └─────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────┐       ┌─────────────────────────────────┐
│    FRONTEND         │       │           BACKEND               │
│   (new-project)     │       │     (node-auth-tutorial)        │
│                     │       │                                 │
│  React 18 + Router  │ ───── │  Express + Passport.js          │
│                     │       │                                 │
└─────────────────────┘       └─────────────────────────────────┘
```

---

## 1. Frontend (new-project)

### Purpose
Single-page React application with client-side routing.

### Architecture

```
src/
├── index.js          # Entry point - renders App into DOM
├── App.js            # Main component with routing
├── App.css           # Application styles
└── reportWebVitals.js
```

### Component Structure

```
App (Router)
├── Navigation
│   ├── Link → /        (Home)
│   └── Link → /about   (About)
└── Routes
    ├── Route /       → Home component
    └── Route /about  → About component
```

### Data Flow

```
User clicks Link → React Router intercepts → Updates URL → Renders matching Route
```

### Key Files

| File | Purpose |
|------|---------|
| `src/index.js` | Mounts React app to `#root` DOM element |
| `src/App.js` | Defines routes and navigation structure |

---

## 2. Backend (node-auth-tutorial)

### Purpose
Express.js server with Passport.js authentication using local strategy.

### Architecture

```
node-auth-tutorial/
├── bin/www           # HTTP server bootstrap
├── app.js            # Express app configuration
├── routes/
│   ├── index.js      # Auth routes (/, /login, /register, /logout)
│   └── users.js      # User resource routes
└── views/            # Jade templates
    ├── layout.jade
    ├── index.jade
    ├── login.jade
    ├── register.jade
    └── error.jade
```

### Request Flow

```
HTTP Request
     │
     ▼
┌─────────────┐
│   Morgan    │  ← Logging middleware
└─────────────┘
     │
     ▼
┌─────────────┐
│   Express   │  ← Body parsing (JSON, URL-encoded)
│   Parsers   │
└─────────────┘
     │
     ▼
┌─────────────┐
│   Session   │  ← express-session (in-memory)
└─────────────┘
     │
     ▼
┌─────────────┐
│  Passport   │  ← Authentication middleware
└─────────────┘
     │
     ▼
┌─────────────┐
│   Router    │  ← Route handlers
└─────────────┘
     │
     ▼
┌─────────────┐
│    Jade     │  ← Template rendering
└─────────────┘
     │
     ▼
HTTP Response
```

### Authentication Flow

```
REGISTRATION:
POST /register
     │
     ▼
┌─────────────────────┐
│  bcrypt.hash()      │  ← Hash password (10 rounds)
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  users.push()       │  ← Store in memory array
└─────────────────────┘
     │
     ▼
Redirect → /login


LOGIN:
POST /login
     │
     ▼
┌─────────────────────┐
│  passport.authenticate()  │
│  (LocalStrategy)          │
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  Find user by       │
│  username           │
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  bcrypt.compare()   │  ← Verify password
└─────────────────────┘
     │
     ├── Success → serializeUser() → Session → Redirect /
     └── Failure → Redirect /login


LOGOUT:
GET /logout
     │
     ▼
┌─────────────────────┐
│  req.logout()       │  ← Destroy session
└─────────────────────┘
     │
     ▼
Redirect → /
```

### Data Storage

**Current:** In-memory array (non-persistent)

```javascript
const users = [];  // { id, username, password (hashed) }
```

**Note:** Data is lost on server restart. For production, integrate a database.

### Routes

| Method | Path | Auth Required | Description |
|--------|------|---------------|-------------|
| GET | `/` | No | Home page (shows user if logged in) |
| GET | `/login` | No | Login form |
| POST | `/login` | No | Authenticate user |
| GET | `/register` | No | Registration form |
| POST | `/register` | No | Create new user |
| GET | `/logout` | Yes | End session |
| GET | `/users` | No | User resource placeholder |

---

## 3. Infrastructure (Terraform)

### Purpose
AWS infrastructure provisioning for S3 storage with security best practices.

### Components

#### Root S3 Bucket (`s3_bucket.tf`)

General-purpose secure S3 bucket for application data.

```
┌─────────────────────────────────────┐
│     my-secure-app-bucket-{suffix}   │
├─────────────────────────────────────┤
│  Versioning: Enabled                │
│  Encryption: AES256 (SSE-S3)        │
│  Region: us-east-1                  │
└─────────────────────────────────────┘
```

#### Evidence Store (`terraform/s3_evidence_store/`)

Immutable audit evidence bucket with compliance controls.

```
┌─────────────────────────────────────┐
│        evidence-store bucket        │
├─────────────────────────────────────┤
│  Versioning: Enabled                │
│  Encryption: AES256                 │
│  Public Access: Blocked             │
│  Delete: Denied (immutable)         │
│  Write: CI/CD Role Only             │
└─────────────────────────────────────┘
```

### Security Controls

| Control | Root Bucket | Evidence Store |
|---------|-------------|----------------|
| Versioning | Yes | Yes |
| Encryption | AES256 | AES256 |
| Block Public Access | No | Yes |
| Delete Prevention | No | Yes (policy) |
| Write Restriction | No | CI/CD role only |

### Resource Dependencies

```
terraform/s3_evidence_store/
├── main.tf       # Bucket + policies
├── variables.tf  # Input: bucket_name, cicd_pipeline_role_arn
└── outputs.tf    # Output: bucket ARN, name
```

---

## Security Considerations

### Backend
- Passwords hashed with bcrypt (10 salt rounds)
- Session secret should be moved to environment variable
- In-memory storage not suitable for production
- No HTTPS configured (add in production)

### Infrastructure
- S3 buckets use server-side encryption
- Evidence store blocks all public access
- Evidence store prevents object deletion
- IAM role-based access for CI/CD

---

## Future Improvements

1. **Database Integration** - Replace in-memory user store with MongoDB/PostgreSQL
2. **Frontend-Backend Integration** - Connect React app to Express API
3. **Environment Variables** - Move secrets to `.env` files
4. **HTTPS** - Add TLS certificates
5. **Testing** - Add unit and integration tests
