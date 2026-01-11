# GramPulse Citizen Features Testing Guide

## Overview
This document provides comprehensive testing instructions for the newly implemented citizen features in GramPulse, including GPS-enabled incident reporting, location tracking, and report management.

## Pre-requisites
1. Backend server running on port 5000
2. MongoDB Atlas connection established
3. Flutter app installed on Android device
4. Network connectivity working (ADB reverse tunnel if needed)

## Feature Testing Checklist

### 1. Authentication Flow
- [x] Phone number entry
- [x] OTP verification
- [x] JWT token generation
- [x] Profile setup
- [x] Role selection (Citizen)
- [x] Navigation to citizen dashboard

### 2. Citizen Dashboard Features
#### Statistics Display
- [ ] Total incidents count
- [ ] Recent reports summary
- [ ] Category statistics
- [ ] Connection status indicator

#### Quick Actions
- [ ] "Report Issue" button functionality
- [ ] "My Reports" button functionality
- [ ] "View Nearby" button functionality

#### Location Integration
- [ ] GPS permission request
- [ ] Current location detection
- [ ] Address resolution from coordinates

### 3. GPS-Enabled Issue Reporting
#### Location Services
- [ ] GPS permission granted
- [ ] Current location captured automatically
- [ ] Coordinate display (lat/long)
- [ ] Address resolution working
- [ ] Manual location refresh

#### Report Form
- [ ] Category selection dropdown (loaded from backend)
- [ ] Issue title input
- [ ] Description textarea
- [ ] Severity selection (Low/Medium/High)
- [ ] Anonymous reporting option
- [ ] Form validation

#### Submission Process
- [ ] Data validation before submit
- [ ] API call to backend successful
- [ ] Location coordinates stored correctly
- [ ] Success message displayed
- [ ] Navigation back to dashboard

### 4. My Reports Screen
#### Report Display
- [ ] List of user's incidents
- [ ] Status indicators with colors
- [ ] Date formatting
- [ ] Report titles and descriptions
- [ ] Priority/severity badges

#### Interaction Features
- [ ] Pull-to-refresh functionality
- [ ] Report detail view
- [ ] Status tracking
- [ ] Empty state when no reports

### 5. Backend Integration
#### API Endpoints
- [ ] GET /api/incidents/categories - Load categories
- [ ] POST /api/incidents - Create new incident
- [ ] GET /api/incidents/my - Get user's incidents
- [ ] GET /api/incidents/nearby - Get location-based incidents
- [ ] GET /api/incidents/statistics - Get dashboard stats

#### Data Storage
- [ ] Incidents stored in MongoDB with coordinates
- [ ] User association with JWT
- [ ] Category references working
- [ ] Location data properly formatted

### 6. Network Connectivity
- [ ] API calls working without timeout
- [ ] Error handling for network issues
- [ ] Offline state detection
- [ ] ADB reverse tunnel functioning (if applicable)

## Testing Commands

### Backend Status Check
```powershell
# Test backend API endpoints
$headers = @{
    'Authorization' = 'Bearer YOUR_JWT_TOKEN'
    'Content-Type' = 'application/json'
}

# Test categories endpoint
Invoke-RestMethod -Uri "http://localhost:5000/api/incidents/categories" -Headers $headers

# Test incident creation
$incidentData = @{
    title = "Test GPS Issue"
    description = "Testing GPS-enabled reporting"
    category = "CATEGORY_ID"
    severity = "medium"
    location = @{
        latitude = 12.9716
        longitude = 77.5946
        address = "Test Address"
    }
    isAnonymous = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/incidents" -Method POST -Headers $headers -Body $incidentData
```

### Database Verification
```javascript
// MongoDB query to check incident storage
db.incidents.find().pretty()
db.incidents.find({location: {$exists: true}}).count()
```

## Expected Results

### Successful GPS Report Creation
```json
{
  "_id": "ObjectId",
  "title": "Test Issue",
  "description": "Test Description",
  "category": "ObjectId",
  "severity": "medium",
  "status": "pending",
  "location": {
    "type": "Point",
    "coordinates": [longitude, latitude],
    "address": "Resolved Address"
  },
  "reportedBy": "ObjectId",
  "isAnonymous": false,
  "createdAt": "2024-XX-XX",
  "updatedAt": "2024-XX-XX"
}
```

### Dashboard Statistics Response
```json
{
  "totalIncidents": 5,
  "myIncidents": 2,
  "pendingIncidents": 3,
  "resolvedIncidents": 2,
  "categories": [
    {
      "_id": "ObjectId",
      "name": "Infrastructure",
      "count": 3
    }
  ]
}
```

## Troubleshooting

### Common Issues
1. **GPS not working**: Check location permissions in Android settings
2. **Network timeout**: Verify ADB reverse tunnel setup
3. **Categories not loading**: Check backend API and MongoDB connection
4. **Location address empty**: Verify geocoding service availability

### Debug Commands
```bash
# Check device logs
flutter logs

# Check network connectivity
adb shell ping 10.0.2.2

# Verify reverse tunnel
adb reverse --list
```

## Test Scenarios

### Complete Feature Flow Test
1. Open app and authenticate
2. Navigate to citizen dashboard
3. Verify statistics display
4. Tap "Report Issue"
5. Allow location permissions
6. Wait for GPS location
7. Select category from dropdown
8. Fill in title and description
9. Choose severity level
10. Submit report
11. Verify success message
12. Navigate to "My Reports"
13. Verify new report appears
14. Check backend database for stored data

### Location Accuracy Test
1. Report issue from different locations
2. Verify coordinates are accurate
3. Check address resolution quality
4. Test manual location refresh

### Error Handling Test
1. Report with no internet connection
2. Report with GPS disabled
3. Submit incomplete form
4. Test with invalid category

## Success Criteria
- All GPS features working accurately
- Real-time location capture and display
- Successful incident creation with coordinates
- Proper backend storage with location data
- Smooth navigation between screens
- Appropriate error handling and user feedback
- Category data loaded from backend
- Statistics accurately reflect database state

## Next Steps After Testing
1. Document any issues found
2. Performance optimization if needed
3. UI/UX improvements based on testing
4. Additional features implementation
5. Production deployment preparation
