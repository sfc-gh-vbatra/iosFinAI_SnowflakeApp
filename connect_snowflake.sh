#!/bin/bash

# Quick Snowflake connection setup for FinAI
echo "🔗 Snowflake Connection Setup"
echo "=============================="

# Check if user has Snowflake credentials
echo ""
echo "Please provide your Snowflake connection details:"
echo ""

# Prompt for Snowflake account
if [ -z "$SNOWFLAKE_ACCOUNT" ]; then
    read -p "Snowflake Account (e.g., abc12345.us-east-1.snowflakecomputing.com): " SNOWFLAKE_ACCOUNT
    export SNOWFLAKE_ACCOUNT
fi

# Prompt for username
if [ -z "$SNOWFLAKE_USER" ]; then
    read -p "Snowflake Username: " SNOWFLAKE_USER
    export SNOWFLAKE_USER
fi

echo ""
echo "✅ Environment variables set:"
echo "SNOWFLAKE_ACCOUNT=$SNOWFLAKE_ACCOUNT"
echo "SNOWFLAKE_USER=$SNOWFLAKE_USER"

echo ""
echo "🗄️  Next steps:"
echo "1. Execute the setup script in Snowflake:"
echo "   - Log into your Snowflake web console"
echo "   - Run the contents of setup_snowflake.sql"
echo ""
echo "2. Test the connection:"
echo "   cd backend && python test_keypair.py"
echo ""
echo "3. Restart your Flask app to use Snowflake:"
echo "   python app.py"

# Save environment variables to .env file
echo ""
echo "💾 Saving to backend/.env file..."
cat > backend/.env << EOF
# Snowflake Connection
SNOWFLAKE_ACCOUNT=$SNOWFLAKE_ACCOUNT
SNOWFLAKE_USER=$SNOWFLAKE_USER

# Database Settings
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=FINAI_DB
SNOWFLAKE_SCHEMA=CORTEX_AI

# Authentication: External browser (default)
# For key-pair auth, add: SNOWFLAKE_PRIVATE_KEY_PATH=/path/to/key
# For password auth, add: SNOWFLAKE_PASSWORD=your-password
EOF

echo "✅ Environment file created: backend/.env"
echo ""
echo "🚀 Ready to connect! Run these commands:"
echo "1. Set up database: Execute setup_snowflake.sql in Snowflake console"
echo "2. Test connection: cd backend && python test_keypair.py"
echo "3. Start Flask with Snowflake: python app.py"
