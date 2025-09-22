#!/bin/bash

# Setup script for Snowflake key-pair authentication
# This script helps generate RSA key pairs for secure Snowflake authentication

echo "🔐 Snowflake Key-Pair Authentication Setup"
echo "=========================================="

# Check if OpenSSL is available
if ! command -v openssl &> /dev/null; then
    echo "❌ OpenSSL is required but not installed."
    echo "   Install with: brew install openssl (macOS) or apt-get install openssl (Linux)"
    exit 1
fi

# Create keys directory
KEYS_DIR="./keys"
mkdir -p "$KEYS_DIR"

# Generate private key
PRIVATE_KEY_FILE="$KEYS_DIR/snowflake_rsa_key.p8"
PUBLIC_KEY_FILE="$KEYS_DIR/snowflake_rsa_key.pub"

echo "🔑 Generating RSA key pair..."

# Generate private key (2048-bit RSA)
openssl genrsa -out "$PRIVATE_KEY_FILE" 2048

if [ $? -eq 0 ]; then
    echo "✅ Private key generated: $PRIVATE_KEY_FILE"
else
    echo "❌ Failed to generate private key"
    exit 1
fi

# Generate public key
openssl rsa -in "$PRIVATE_KEY_FILE" -pubout -out "$PUBLIC_KEY_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Public key generated: $PUBLIC_KEY_FILE"
else
    echo "❌ Failed to generate public key"
    exit 1
fi

# Set secure permissions
chmod 600 "$PRIVATE_KEY_FILE"
chmod 644 "$PUBLIC_KEY_FILE"

echo ""
echo "🔐 Key pair generated successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Copy the public key content:"
echo "   cat $PUBLIC_KEY_FILE"
echo ""
echo "2. Add the public key to your Snowflake user profile:"
echo "   ALTER USER your_username SET RSA_PUBLIC_KEY='<PUBLIC_KEY_CONTENT>';"
echo ""
echo "3. Update your .env file with:"
echo "   SNOWFLAKE_PRIVATE_KEY_PATH=$(pwd)/$PRIVATE_KEY_FILE"
echo ""
echo "4. Test the connection:"
echo "   cd backend && python test_keypair.py"
echo ""

# Display public key content for easy copying
echo "📄 Public Key Content (copy this):"
echo "-----------------------------------"
# Remove the header and footer lines, join all lines
grep -v "BEGIN PUBLIC KEY" "$PUBLIC_KEY_FILE" | grep -v "END PUBLIC KEY" | tr -d '\n'
echo ""
echo "-----------------------------------"

echo ""
echo "⚠️  Security Notes:"
echo "• Keep your private key secure and never share it"
echo "• The private key file permissions are set to 600 (owner read/write only)"
echo "• Consider using a passphrase for additional security"
echo "• Regularly rotate your keys for enhanced security"
