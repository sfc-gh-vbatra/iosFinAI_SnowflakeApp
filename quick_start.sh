#!/bin/bash
# Quick start script for FinAI - Snowflake Cortex AI iPhone App

echo "🚀 FinAI Quick Start - Snowflake Cortex AI iPhone App"
echo "=" * 60

# Check if we're in the right directory
if [ ! -f "project_plan.md" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

echo "📋 Checking prerequisites..."

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    exit 1
fi
echo "✅ Python 3 found"

# Check if Xcode is available (for iOS development)
if ! command -v xcodebuild &> /dev/null; then
    echo "⚠️  Xcode not found - iOS development may not be available"
else
    echo "✅ Xcode found"
fi

echo ""
echo "🔧 Setting up backend..."

# Create backend .env file if it doesn't exist
if [ ! -f "backend/.env" ]; then
    echo "📝 Creating backend/.env file..."
    cp backend/.env.template backend/.env
    echo "⚠️  Please edit backend/.env with your Snowflake credentials"
fi

# Install Python dependencies
echo "📦 Installing Python dependencies..."
cd backend
pip install -r requirements.txt

echo ""
echo "❄️  Setting up Snowflake..."
echo "1. Make sure you have a Snowflake account with Cortex AI enabled"
echo "2. Update backend/.env with your Snowflake credentials"
echo "3. Run the Snowflake setup script:"
echo "   snowsql -f ../setup_snowflake.sql"
echo ""

echo "📱 iOS App Setup:"
echo "1. Open ios/FinAI/FinAI.xcodeproj in Xcode"
echo "2. Build and run on iOS Simulator or device"
echo ""

echo "🚀 To start the backend server:"
echo "   cd backend && python app.py"
echo ""

echo "🎯 Features to demonstrate:"
echo "   • Fraud Detection using Cortex AI ML"
echo "   • Market Sentiment Analysis"
echo "   • Credit Risk Assessment"
echo "   • AI Financial Assistant Chat"
echo ""

echo "📖 See README.md for detailed setup instructions"
echo ""
echo "✨ Happy coding with Snowflake Cortex AI!"
