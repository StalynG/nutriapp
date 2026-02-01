# NUT-31: Ingredient Scanning & User Authentication

## Overview

This document describes the implementation of user authentication and ingredient scanning features for the Nutrify application. These features enable users to:

- Register and authenticate with secure token-based authentication
- Scan food images to automatically detect ingredients
- Save and manage their scan history
- Access personalized features through user profiles

## Architecture

### Clean Architecture Layers

```
Domain Layer
├── Entities
│   ├── User (email, name, profile image, verification status)
│   └── IngredientScanResult (ingredients, confidence score, timestamp)
└── Repositories (abstract interfaces)
    ├── AuthenticationRepository
    └── IngredientScanRepository

Infrastructure Layer
├── Services
│   ├── AuthenticationService (token management, API calls)
│   └── IngredientScanService (image processing, API calls)
└── Repositories (concrete implementations)

Presentation Layer
├── Providers (State Management)
│   ├── AuthenticationProvider (auth state, user data)
│   └── IngredientScanProvider (scan history, saved scans)
└── Screens
    ├── AuthenticationScreen (login/register UI)
    └── IngredientScanScreen (scan/history/saved tabs)
```

## Components

### 1. Authentication System

#### User Entity (`lib/domain/entities/user.dart`)

```dart
class User {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isEmailVerified;
  
  // JSON serialization support
  factory User.fromJson(Map<String, dynamic> json)
  User toJson() => Map<String, dynamic>
}

class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType; // "Bearer"
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

#### Authentication Service (`lib/infrastructure/services/authentication_service.dart`)

Manages all authentication operations with token persistence:

**Features:**
- User registration and login
- Automatic token refresh
- Secure token storage in SharedPreferences
- Session management
- Password reset
- Profile updates

**Token Persistence Keys:**
- `auth_token`: Current access token
- `refresh_token`: Token for refreshing access
- `current_user`: Serialized user object

**API Endpoints:**
```
POST   /auth/register          - Create new account
POST   /auth/login             - Authenticate user
POST   /auth/logout            - End session
POST   /auth/refresh           - Get new access token
POST   /auth/reset-password    - Initiate password reset
PUT    /user/profile           - Update user information
GET    /user/profile           - Fetch current user data
```

#### Authentication Provider (`lib/providers/authentication_provider.dart`)

ChangeNotifier for authentication state management:

**States:**
- `unauthenticated` - No active session
- `loading` - Auth operation in progress
- `authenticated` - User logged in
- `error` - Authentication failed

**Key Methods:**
```dart
Future<void> register({
  required String name,
  required String email,
  required String password,
})

Future<void> login({
  required String email,
  required String password,
})

Future<void> logout()
Future<void> resetPassword(String email)
Future<void> updateProfile({String? name, File? profileImage})
```

**Getters:**
- `isAuthenticated` - Is user logged in?
- `isLoading` - Operation in progress?
- `currentUser` - Current User object
- `isEmailVerified` - Email verification status

### 2. Ingredient Scanning System

#### IngredientScan Entity (`lib/domain/entities/ingredient_scan.dart`)

```dart
class IngredientScanRequest {
  final File imageFile;
  final String userId;
  final String? description;
}

class IngredientScanResult {
  final String id;
  final String userId;
  final List<String> ingredients;
  final double confidenceScore; // 0.0 to 1.0
  final String? description;
  final DateTime scannedAt;
  final String? imageUrl;
}
```

#### Ingredient Scan Service (`lib/infrastructure/services/ingredient_scan_service.dart`)

Handles all ingredient scanning operations:

**Features:**
- Image encoding to Base64 for API transmission
- Timeout handling (120 seconds)
- Automatic authentication headers
- Scan history management
- Saved scans persistence

**API Endpoints:**
```
POST   /ingredients/scan       - Analyze image for ingredients
GET    /scans/history          - Get user's scan history
GET    /scans/{id}             - Get specific scan details
POST   /scans/{id}/save        - Save scan to library
GET    /scans/saved            - Get saved scans
DELETE /scans/{id}             - Delete a scan record
```

**Request Format:**
```json
{
  "image": "base64_encoded_image_data",
  "description": "optional_user_notes",
  "userId": "user_id"
}
```

**Response Format:**
```json
{
  "id": "scan_id",
  "userId": "user_id",
  "ingredients": ["apple", "banana", "yogurt"],
  "confidenceScore": 0.92,
  "description": "user_notes",
  "scannedAt": "2024-01-15T10:30:00Z",
  "imageUrl": "https://api.nutriapp.com/images/scan_id.jpg"
}
```

#### Ingredient Scan Provider (`lib/providers/ingredient_scan_provider.dart`)

ChangeNotifier for scan state management:

**States:**
- `idle` - No ongoing operation
- `scanning` - Image processing in progress
- `success` - Scan completed
- `error` - Scan failed

**Key Methods:**
```dart
Future<void> scanIngredients({
  required File imageFile,
  String? description,
})

Future<void> loadScanHistory()
Future<void> loadSavedScans()
Future<void> saveScan(String scanId)
Future<void> deleteScan(String scanId)
IngredientScanResult? getScanDetails(String scanId)
```

**State Properties:**
- `lastScan` - Most recent scan result
- `scanHistory` - List of all scans
- `savedScans` - User's bookmarked scans
- `isLoading` - Operation status

### 3. User Interface

#### Authentication Screen (`lib/src/screens/authentication_screen.dart`)

Tabbed interface with login and registration:

**Tab 1: Login**
- Email field with validation
- Password field with visibility toggle
- Error message display
- Loading indicator
- Link to password reset

**Tab 2: Register**
- Name field
- Email field with validation
- Password field (8+ characters, with visibility toggle)
- Confirm password field with match validation
- Error messages
- Loading indicator

#### Ingredient Scan Screen (`lib/src/screens/ingredient_scan_screen.dart`)

Three-tab scanning interface:

**Tab 1: Scan**
- Camera/Gallery picker buttons
- Image preview area
- Optional description field
- Scan button
- Loading state indicator
- Result cards showing detected ingredients with confidence scores

**Tab 2: History**
- List of all past scans
- Timestamps and confidence badges
- Ingredient chips display
- Delete option per scan
- Empty state messaging

**Tab 3: Saved**
- List of bookmarked scans
- Quick access to saved ingredients
- Remove from saved option
- Empty state messaging

### 4. Application Integration

#### Main App (`lib/main.dart`)

**Provider Setup:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthenticationService()),
    ChangeNotifierProvider(create: (_) => IngredientScanService()),
    ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ChangeNotifierProvider(create: (_) => IngredientScanProvider()),
    // ... other providers
  ],
)
```

**Authentication Wrapper:**
- Checks authentication status on app startup
- Displays login screen if not authenticated
- Shows home with 5-tab navigation if authenticated

**5-Tab Navigation:**
1. **Inicio** (Home) - Main dashboard with feature cards
2. **Chat IA** (AI Chat) - OpenAI-powered nutrition assistant
3. **Catálogo** (Nutrition Catalog) - Food database and search
4. **Escaneo** (Ingredient Scanning) - Image recognition scanner
5. **Perfil** (Profile) - User profile and settings

**Profile Tab Features:**
- User avatar with initials
- Display name and email
- Email verification status
- Logout button with confirmation

## Security Considerations

### Token Management
- Access tokens stored in SharedPreferences (development; use Keychain/Keystore in production)
- Refresh tokens used for session renewal
- Automatic token refresh before expiration
- Tokens cleared on logout

### API Security
- All requests include Authorization header with Bearer token
- HTTPS required for all API calls
- Credentials never logged or exposed
- Sensitive data encrypted in transit

### Image Handling
- Images encoded as Base64 before transmission
- Large images are compressed to reduce payload
- Original device files are not stored permanently
- Temporary files cleaned up after upload

## State Management Flow

```
User Action
    ↓
Provider Method Called
    ↓
Service Makes API Call
    ↓
Response Parsed
    ↓
State Updated
    ↓
Listeners Notified
    ↓
UI Rebuilds
```

## Error Handling

All services implement comprehensive error handling:

```dart
try {
  // API call
} catch (e) {
  if (e is SocketException) {
    // Network error
  } else if (e is TimeoutException) {
    // Timeout error
  } else if (e is FormatException) {
    // JSON parsing error
  } else {
    // Generic error
  }
}
```

## Configuration

### Environment Variables (`.env`)
```
NUTRIAPP_API_BASE_URL=https://api.nutriapp.com/v1
OPENAI_API_KEY=your_api_key_here
```

### Dependencies
```yaml
dependencies:
  shared_preferences: ^2.2.2
  image_picker: ^1.0.4
  http: ^0.13.6
  provider: ^6.0.0
```

## Testing

### Unit Tests
- Service layer: Mock HTTP responses
- Provider layer: Test state transitions
- Entity layer: JSON serialization/deserialization

### Integration Tests
- Authentication flow (register → login → logout)
- Scan history management
- Token refresh mechanism

### Widget Tests
- UI component rendering
- Form validation
- Error state display

## Future Enhancements

1. **Biometric Authentication** - Fingerprint/Face ID login
2. **Advanced Image Processing** - Confidence filtering, nutritional analysis
3. **Scan Analytics** - Historical trends, dietary recommendations
4. **Social Features** - Share scans with nutritionists
5. **Offline Mode** - Cache scan results and history
6. **Multi-language Support** - Ingredient names in different languages

## Deployment Notes

### Backend Requirements
- User management system
- Token generation and validation
- Image storage infrastructure
- ML model for ingredient detection
- Database for scan history persistence

### Mobile Permissions
- **iOS**: Camera and Photo Library access (Info.plist)
- **Android**: CAMERA and READ_EXTERNAL_STORAGE (AndroidManifest.xml)

### API Response Times
- Authentication endpoints: < 1000ms
- Ingredient scan: < 2000ms (due to ML processing)
- History retrieval: < 500ms

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Login fails | Check network connectivity, verify credentials |
| Token expired | App auto-refreshes; if fails, user must re-login |
| Scan times out | Reduce image size, increase timeout threshold |
| Camera not working | Check device permissions, restart app |
| Saved scans empty | Verify user is authenticated, check internet |

## Support

For issues or questions:
- Check logs in debug console
- Review error messages in UI
- Verify API endpoint configuration
- Ensure device permissions are granted
