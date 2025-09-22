# FinAI - Snowflake Cortex AI Financial Services iPhone App

A demonstration iPhone app showcasing Snowflake Cortex AI capabilities for financial services, including fraud detection, market analysis, risk assessment, and AI-powered financial assistance.

## 🏗️ Architecture

### Backend (Python Flask)
- REST API server that connects to Snowflake
- Uses Snowflake Cortex AI functions for ML/LLM capabilities
- Handles fraud detection, market sentiment, and risk assessment

### iOS App (SwiftUI)
- Native iPhone app with modern SwiftUI interface
- Real-time communication with backend API
- Financial services focused UI/UX

### Snowflake Cortex AI
- `SNOWFLAKE.CORTEX.COMPLETE()` - LLM for analysis and chat
- `SNOWFLAKE.CORTEX.SENTIMENT()` - Market sentiment analysis
- `SNOWFLAKE.CORTEX.SUMMARIZE()` - Document summarization
- Custom ML models for fraud and risk scoring

## 🚀 Features

### 📱 iPhone App Features
1. **Dashboard** - Key metrics and recent transactions
2. **Fraud Detection** - Real-time transaction analysis
3. **Market Analysis** - News sentiment and market insights
4. **Risk Assessment** - Credit scoring and risk evaluation
5. **AI Chat** - Financial assistant powered by Cortex AI

### 🧠 AI Capabilities
- **Fraud Detection**: Analyze transactions for suspicious patterns
- **Market Sentiment**: Process financial news for investment insights
- **Credit Risk**: Assess customer creditworthiness
- **Financial Chat**: AI assistant for financial questions
- **Document Analysis**: Process financial documents and reports

## 🛠️ Setup Instructions

### Prerequisites
- Snowflake account with Cortex AI enabled
- Xcode 15+ for iOS development
- Python 3.8+ for backend
- macOS for development

### 1. Snowflake Setup
```sql
-- Run the setup script
\i setup_snowflake.sql
```

### 2. Backend Setup
```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Set up authentication (see AUTHENTICATION.md for detailed guide)
# Option A: Key-pair authentication (recommended)
../setup_keypair_auth.sh
export SNOWFLAKE_PRIVATE_KEY_PATH=$(pwd)/../keys/snowflake_rsa_key.p8

# Option B: External browser authentication
export SNOWFLAKE_ACCOUNT=your-account.region.snowflakecomputing.com
export SNOWFLAKE_USER=your-username

# Test authentication
python test_keypair.py  # for key-pair auth
python test_app.py      # general app test

# Run the backend server
python app.py
```

### 3. iOS App Setup
```bash
# Open Xcode project
open ios/FinAI/FinAI.xcodeproj

# Update APIService baseURL if needed (default: localhost:5000)
# Build and run on iOS Simulator or device
```

## 🔐 Authentication

The backend uses **external browser authentication** for Snowflake:
- Set `SNOWFLAKE_ACCOUNT` and `SNOWFLAKE_USER` environment variables
- Browser will open for authentication when backend starts
- Supports SSO, MFA, and passkey authentication

## 📊 Sample Data

The app includes realistic sample data:
- **Transactions**: Various purchase types with fraud indicators
- **Customers**: Diverse customer profiles for risk assessment
- **Market News**: Financial news for sentiment analysis

## 🔗 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/api/fraud/analyze` | POST | Analyze transaction for fraud |
| `/api/market/sentiment` | POST | Analyze market sentiment |
| `/api/risk/assess` | POST | Assess credit risk |
| `/api/chat/financial` | POST | AI financial assistant |
| `/api/demo/sample-data` | GET | Get sample data for demo |

## 📱 iOS App Structure

```
FinAI/
├── FinAIApp.swift          # App entry point
├── ContentView.swift       # Main tab view
├── Models.swift            # Data models
├── APIService.swift        # Backend communication
└── Views/
    ├── DashboardView.swift
    ├── FraudDetectionView.swift
    ├── MarketAnalysisView.swift
    ├── RiskAssessmentView.swift
    └── ChatView.swift
```

## 🎯 Use Cases Demonstrated

### Financial Institution
- Monitor transactions in real-time
- Detect fraudulent activities
- Assess customer credit risk
- Analyze market conditions

### Investment Firm
- Process market news for sentiment
- Generate investment insights
- Risk assessment for portfolios
- Client advisory through AI chat

### Regulatory Compliance
- Document analysis for compliance
- Risk reporting and assessment
- Fraud pattern detection
- Audit trail analysis

## 🧪 Testing

### Backend Testing
```bash
# Test health endpoint
curl http://localhost:5000/api/health

# Test fraud detection
curl -X POST http://localhost:5000/api/fraud/analyze \
  -H "Content-Type: application/json" \
  -d '{"amount": 5000, "merchant": "Cash Advance", "location": "Unknown"}'
```

### iOS Testing
- Use iOS Simulator for development
- Test on physical device for full experience
- Mock data available for offline testing

## 🔮 Future Enhancements

- **Real-time Notifications**: Push notifications for fraud alerts
- **Biometric Security**: Face ID/Touch ID for app access
- **Offline Mode**: Cache data for offline analysis
- **Advanced Visualizations**: Interactive charts and graphs
- **Multi-language Support**: Localization for global markets
- **Apple Watch Integration**: Key metrics on Apple Watch

## 📄 License

MIT License - Feel free to use and modify for your projects.

## 🤝 Contributing

This is a demonstration app. Feel free to fork and enhance with additional Snowflake Cortex AI capabilities!
