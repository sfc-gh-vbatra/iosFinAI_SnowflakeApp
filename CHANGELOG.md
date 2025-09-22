# FinAI Changelog

## [1.0.1] - 2024-01-16

### Fixed
- **Flask Compatibility**: Fixed `AttributeError: 'Flask' object has no attribute 'before_first_request'`
  - Removed deprecated `@app.before_first_request` decorator (removed in Flask 2.2+)
  - Moved Snowflake connection initialization to main startup function
  - Added connection health checking for all API endpoints
  - Added automatic reconnection logic

### Added
- Connection health monitoring for API endpoints
- Automatic Snowflake connection recovery
- Backend test suite for validating Flask app functionality

### Technical Details
The `@app.before_first_request` decorator was deprecated and removed in Flask 2.2+. The fix includes:

1. **Initialization**: Moved to `initialize_snowflake()` function called at startup
2. **Health Checking**: Added `ensure_connection()` method to verify connection before each API call
3. **Auto-Recovery**: Automatic reconnection if the Snowflake session expires
4. **Better Logging**: Enhanced logging for connection status and errors

### How to Update
If you're running an older version:
1. Pull the latest code
2. Ensure you have Flask 2.2+ installed: `pip install --upgrade flask`
3. Test the backend: `cd backend && python test_app.py`
4. Start the server: `python app.py`

## [1.0.0] - 2024-01-15

### Initial Release
- iPhone app with SwiftUI interface
- Python Flask backend with Snowflake Cortex AI integration
- Fraud detection using Cortex AI ML functions
- Market sentiment analysis
- Credit risk assessment
- AI-powered financial assistant chat
- Sample financial data for demonstration
