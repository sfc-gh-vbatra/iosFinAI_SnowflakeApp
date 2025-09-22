#!/bin/bash

# Setup script for Snowflake key-pair authentication
echo "🔐 Snowflake Key-Pair Authentication Setup"
echo "=========================================="

# Set the private key path
PRIVATE_KEY_PATH="$(pwd)/keys/snowflake_rsa_key.p8"

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    echo "❌ Private key not found at: $PRIVATE_KEY_PATH"
    echo "   Run ./setup_keypair_auth.sh first to generate keys"
    exit 1
fi

echo "✅ Found private key: $PRIVATE_KEY_PATH"

# Display public key for Snowflake
echo ""
echo "📄 Your public key content (copy this entire string):"
echo "======================================================"
grep -v "BEGIN PUBLIC KEY" keys/snowflake_rsa_key.pub | grep -v "END PUBLIC KEY" | tr -d '\n'
echo ""
echo "======================================================"
echo ""

# Prompt for Snowflake account details
read -p "Enter your Snowflake account (e.g., abc12345.us-east-1.snowflakecomputing.com): " SNOWFLAKE_ACCOUNT
read -p "Enter your Snowflake username: " SNOWFLAKE_USER

# Export environment variables
export SNOWFLAKE_ACCOUNT="$SNOWFLAKE_ACCOUNT"
export SNOWFLAKE_USER="$SNOWFLAKE_USER"
export SNOWFLAKE_PRIVATE_KEY_PATH="$PRIVATE_KEY_PATH"
export SNOWFLAKE_WAREHOUSE="COMPUTE_WH"
export SNOWFLAKE_DATABASE="FINAI_DB"
export SNOWFLAKE_SCHEMA="CORTEX_AI"

# Create .env file for Flask app
echo "💾 Creating backend/.env file..."
cat > backend/.env << EOF
# Snowflake Key-Pair Authentication
SNOWFLAKE_ACCOUNT=$SNOWFLAKE_ACCOUNT
SNOWFLAKE_USER=$SNOWFLAKE_USER
SNOWFLAKE_PRIVATE_KEY_PATH=$PRIVATE_KEY_PATH

# Database Settings
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=FINAI_DB
SNOWFLAKE_SCHEMA=CORTEX_AI
EOF

echo "✅ Environment variables configured!"
echo ""
echo "🚀 Next steps:"
echo "1. Add the public key above to your Snowflake user profile:"
echo "   ALTER USER $SNOWFLAKE_USER SET RSA_PUBLIC_KEY='<PUBLIC_KEY_CONTENT>';"
echo ""
echo "2. Execute the database setup in Snowflake:"
echo "   Run the contents of setup_snowflake.sql in your Snowflake console"
echo ""
echo "3. Test the connection:"
echo "   cd backend && python test_keypair.py"
echo ""
echo "4. Start Flask with Cortex AI:"
echo "   python app.py"

echo ""
echo "⚠️  Remember: Add the public key to your Snowflake user profile first!"
