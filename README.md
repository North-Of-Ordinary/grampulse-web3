# GramPulse Backend API

Node.js/Express RESTful API server for the GramPulse Rural Grievance Management System. Provides secure authentication, incident management, and role-based access control.

## Overview

The GramPulse Backend is a scalable API service that handles user authentication, incident reporting, category management, and role-based workflows for citizens, volunteers, officers, and administrators. Built with Express.js and MongoDB, it provides a robust foundation for the mobile application.

## Features

### Authentication
- Phone number-based OTP authentication
- JWT token-based session management
- Secure password hashing with bcryptjs
- Role-based authorization middleware
- Token refresh and expiration handling

### Incident Management
- Create incidents with GPS coordinates
- Category-based classification
- Severity level assignment (Low, Medium, High, Critical)
- Status tracking (Pending, In Progress, Resolved, Closed)
- File attachment support
- Location-based nearby incident queries
- Anonymous reporting option

### User Management
- Multi-role user system (Citizen, Volunteer, Officer, Administrator)
- Profile management
- User statistics and activity tracking
- Role-specific data access

### Additional Features
- Pre-seeded category database
- File upload with validation
- Rate limiting for API protection
- CORS configuration for cross-origin requests
- Comprehensive error handling
- Request/response logging

## Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Runtime | Node.js | 18+ |
| Framework | Express.js | 5.1.0 |
| Database | MongoDB | Atlas |
| ODM | Mongoose | 8.18.0 |
| Authentication | JWT | 9.0.2 |
| Password Hash | bcryptjs | 2.4.3 |
| File Upload | Multer | 1.4.5 |
| Security | Helmet | 7.1.0 |
| Rate Limiting | express-rate-limit | 7.1.5 |

## Prerequisites

- Node.js 18.x or higher
- MongoDB Atlas account or local MongoDB instance
- npm or yarn package manager
- Git

## Installation

### 1. Clone Repository
```bash
git clone https://github.com/naveen-astra/grampulse-icsrf.git
cd GP-Backend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Environment Configuration

Create a `.env` file in the root directory:

```env
# Database Configuration
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/grampulse?retryWrites=true&w=majority

# Authentication
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRE=30d

# Server Configuration
PORT=3000
NODE_ENV=development

# Rate Limiting
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100

# File Upload
MAX_FILE_SIZE=5242880
UPLOAD_DIR=uploads/
```

### 4. Database Setup

Seed the database with initial categories:
```bash
npm run seed
```

### 5. Start Server

**Development:**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

Server will start on `http://localhost:3000` (or configured PORT)

## Project Structure

```
GP-Backend/
├── server.js                    # Application entry point
├── package.json                 # Dependencies and scripts
├── .env                         # Environment variables
├── .gitignore                   # Git ignore rules
│
├── src/
│   ├── config/
│   │   └── database.js          # MongoDB connection
│   │
│   ├── models/
│   │   ├── User.js              # User schema
│   │   ├── Incident.js          # Incident schema
│   │   ├── Category.js          # Category schema
│   │   └── SHG.js               # Self-Help Group schema
│   │
│   ├── controllers/
│   │   └── authController.js    # Authentication logic
│   │
│   ├── middleware/
│   │   └── auth.js              # JWT verification middleware
│   │
│   └── routes/
│       ├── authRoutes.js        # Authentication endpoints
│       ├── incidents.js         # Incident endpoints
│       ├── profile.js           # User profile endpoints
│       └── shgRoutes.js         # Self-Help Group endpoints
│
├── tests/
│   ├── seedCategories.js        # Database seeding
│   ├── testAPI.js               # API testing
│   └── statusCheck.js           # Health check
│
├── uploads/                     # File upload directory
│   └── .gitkeep
│
└── backup/                      # Backup configurations
    └── src_backup/
```

## API Endpoints

### Authentication

#### Register/Login
```http
POST /api/auth/register
POST /api/auth/login
POST /api/auth/verify-otp
```

**Request Body (Register):**
```json
{
  "phoneNumber": "+919876543210",
  "name": "User Name",
  "role": "citizen"
}
```

**Response:**
```json
{
  "success": true,
  "token": "jwt-token-here",
  "user": {
    "id": "user-id",
    "name": "User Name",
    "phoneNumber": "+919876543210",
    "role": "citizen"
  }
}
```

### Incidents

#### Create Incident
```http
POST /api/incidents
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "title": "Water Supply Issue",
  "description": "No water supply for 3 days",
  "category": "Water Supply",
  "severity": "High",
  "location": {
    "type": "Point",
    "coordinates": [77.5946, 12.9716]
  },
  "address": "123 Main Street, Village Name"
}
```

#### Get All Incidents
```http
GET /api/incidents
Authorization: Bearer {token}
```

#### Get Nearby Incidents
```http
GET /api/incidents/nearby?latitude=12.9716&longitude=77.5946&radius=5000
Authorization: Bearer {token}
```

#### Get Incident by ID
```http
GET /api/incidents/:id
Authorization: Bearer {token}
```

#### Update Incident Status
```http
PATCH /api/incidents/:id/status
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "status": "In Progress",
  "remarks": "Officer assigned"
}
```

### User Profile

#### Get Profile
```http
GET /api/profile
Authorization: Bearer {token}
```

#### Update Profile
```http
PUT /api/profile
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "Updated Name",
  "email": "user@example.com"
}
```

### Categories

#### Get All Categories
```http
GET /api/categories
```

## Database Schema

### User Model
```javascript
{
  name: String (required),
  phoneNumber: String (required, unique),
  email: String,
  password: String,
  role: Enum ['citizen', 'volunteer', 'officer', 'admin'],
  isVerified: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Incident Model
```javascript
{
  title: String (required),
  description: String (required),
  category: ObjectId (ref: Category),
  severity: Enum ['Low', 'Medium', 'High', 'Critical'],
  status: Enum ['Pending', 'In Progress', 'Resolved', 'Closed'],
  location: {
    type: String,
    coordinates: [Number] // [longitude, latitude]
  },
  address: String,
  reporter: ObjectId (ref: User),
  assignedTo: ObjectId (ref: User),
  images: [String],
  isAnonymous: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### Category Model
```javascript
{
  name: String (required, unique),
  description: String,
  icon: String,
  isActive: Boolean,
  createdAt: Date
}
```

## Authentication Flow

1. User sends phone number for registration/login
2. Server generates OTP (6-digit code)
3. User verifies OTP
4. Server issues JWT token
5. Client includes token in Authorization header for protected routes
6. Server validates token using middleware

## Security Features

### Implemented
- JWT token authentication
- Password hashing with bcryptjs
- Rate limiting (100 requests per 15 minutes)
- CORS configuration
- Helmet security headers
- Input validation
- SQL injection prevention (NoSQL)
- XSS protection

### Best Practices
- Environment variables for sensitive data
- Token expiration handling
- Role-based access control
- Secure file upload validation

## Error Handling

All API responses follow a consistent format:

**Success Response:**
```json
{
  "success": true,
  "data": {},
  "message": "Operation successful"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Error message",
  "statusCode": 400
}
```

### HTTP Status Codes
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error

## Testing

### Run Tests
```bash
# API endpoint testing
npm test

# Database connection check
node check-database.js

# Category seeding verification
node check-categories-db.js
```

### Manual Testing with cURL

**Register User:**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "+919876543210",
    "name": "Test User",
    "role": "citizen"
  }'
```

**Create Incident:**
```bash
curl -X POST http://localhost:3000/api/incidents \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "Test Incident",
    "description": "Test Description",
    "category": "CATEGORY_ID",
    "severity": "Medium",
    "location": {
      "type": "Point",
      "coordinates": [77.5946, 12.9716]
    }
  }'
```

## Development

### Development Server
```bash
npm run dev
```
Uses nodemon for automatic restart on file changes.

### Code Standards
- Use ES6+ syntax
- Follow async/await pattern
- Implement proper error handling
- Add comments for complex logic
- Maintain consistent naming conventions

### Adding New Routes
1. Create route file in `src/routes/`
2. Define controller in `src/controllers/`
3. Add middleware if needed in `src/middleware/`
4. Register route in `server.js`

## Deployment

### Environment Setup
1. Set NODE_ENV to 'production'
2. Use strong JWT_SECRET
3. Configure production MongoDB URI
4. Set appropriate rate limits
5. Enable HTTPS

### Platform-Specific Guides

**Heroku:**
```bash
heroku create grampulse-api
heroku config:set MONGODB_URI=your-mongodb-uri
heroku config:set JWT_SECRET=your-secret
git push heroku GP-Backend:main
```

**Railway:**
```bash
railway login
railway init
railway add
railway up
```

**AWS EC2:**
- Set up Node.js environment
- Configure reverse proxy (nginx)
- Set up SSL certificate
- Configure environment variables
- Use PM2 for process management

## Monitoring

### Health Check
```http
GET /api/health
```

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-22T10:30:00.000Z",
  "uptime": 3600,
  "database": "connected"
}
```

## Troubleshooting

### Common Issues

**MongoDB Connection Failed:**
- Verify MONGODB_URI in .env
- Check network access in MongoDB Atlas
- Ensure IP address is whitelisted

**JWT Token Invalid:**
- Verify JWT_SECRET matches
- Check token expiration
- Ensure proper Authorization header format

**File Upload Errors:**
- Check UPLOAD_DIR permissions
- Verify MAX_FILE_SIZE setting
- Ensure multer configuration is correct

**Rate Limit Exceeded:**
- Adjust RATE_LIMIT_MAX_REQUESTS
- Implement user-specific rate limiting
- Use Redis for distributed rate limiting

## Performance Optimization

- Database indexing on frequently queried fields
- Pagination for large datasets
- Caching with Redis (optional)
- Connection pooling for MongoDB
- Compression middleware
- Query optimization

## Contributing

Please refer to CONTRIBUTING.md for development guidelines and submission process.

### Commit Message Format
```
<type>(<scope>): <description>

Examples:
feat(auth): Add password reset functionality
fix(incidents): Resolve nearby query distance calculation
docs: Update API endpoint documentation
```

## License

This project is proprietary and confidential.

## Support

For issues, questions, or feature requests, please open an issue in the repository.

## Changelog

See CHANGELOG.md for version history and release notes.

---

**Current Version:** 1.0.0  
**Last Updated:** December 2024  
**Status:** Production Ready
