#!/usr/bin/env python3
"""
Test script for Snowflake key-pair authentication.
This script tests the key-pair authentication functionality.
"""

import os
import sys
import logging
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def test_keypair_auth():
    """Test key-pair authentication setup."""
    print("🔐 Testing Snowflake Key-Pair Authentication")
    print("=" * 45)
    
    # Check required environment variables
    required_vars = ['SNOWFLAKE_ACCOUNT', 'SNOWFLAKE_USER', 'SNOWFLAKE_PRIVATE_KEY_PATH']
    missing_vars = []
    
    print("\n📋 Checking environment variables:")
    for var in required_vars:
        value = os.getenv(var)
        if value:
            if var == 'SNOWFLAKE_PRIVATE_KEY_PATH':
                # Check if file exists
                if os.path.exists(value):
                    print(f"   ✅ {var}: {value}")
                else:
                    print(f"   ❌ {var}: File not found - {value}")
                    missing_vars.append(var)
            else:
                print(f"   ✅ {var}: {value}")
        else:
            print(f"   ❌ {var}: Not set")
            missing_vars.append(var)
    
    # Check optional passphrase
    passphrase = os.getenv('SNOWFLAKE_PRIVATE_KEY_PASSPHRASE')
    if passphrase:
        print(f"   ✅ SNOWFLAKE_PRIVATE_KEY_PASSPHRASE: ****** (set)")
    else:
        print(f"   ℹ️  SNOWFLAKE_PRIVATE_KEY_PASSPHRASE: Not set (key assumed unencrypted)")
    
    if missing_vars:
        print(f"\n❌ Missing required variables: {', '.join(missing_vars)}")
        print("\n💡 Setup instructions:")
        print("1. Run: ./setup_keypair_auth.sh")
        print("2. Add public key to Snowflake user profile")
        print("3. Update .env file with private key path")
        return False
    
    # Test the authentication
    print("\n🔌 Testing Snowflake connection...")
    try:
        from app import SnowflakeCortexAI
        
        cortex_ai = SnowflakeCortexAI()
        
        if cortex_ai.connect():
            print("✅ Key-pair authentication successful!")
            
            # Test a simple query
            try:
                cortex_ai.cursor.execute("SELECT CURRENT_USER() as user, CURRENT_WAREHOUSE() as warehouse")
                result = cortex_ai.cursor.fetchone()
                print(f"   Connected as: {result['USER']}")
                print(f"   Using warehouse: {result['WAREHOUSE']}")
                
                cortex_ai.connection.close()
                return True
                
            except Exception as e:
                print(f"❌ Query test failed: {e}")
                return False
        else:
            print("❌ Key-pair authentication failed")
            return False
            
    except ImportError as e:
        print(f"❌ Import error: {e}")
        print("   Make sure to install requirements: pip install -r requirements.txt")
        return False
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return False

def main():
    """Main test function."""
    print("Starting key-pair authentication test...\n")
    
    if test_keypair_auth():
        print("\n🎉 Key-pair authentication is working correctly!")
        print("\n🚀 Your Flask app is ready to use key-pair authentication.")
        print("   Start the server with: python app.py")
    else:
        print("\n❌ Key-pair authentication test failed.")
        print("\n🔧 Troubleshooting:")
        print("• Ensure the private key file exists and is readable")
        print("• Verify the public key is added to your Snowflake user")
        print("• Check that all environment variables are set correctly")
        print("• Make sure the Snowflake account and user are correct")
    
    return True

if __name__ == "__main__":
    main()
