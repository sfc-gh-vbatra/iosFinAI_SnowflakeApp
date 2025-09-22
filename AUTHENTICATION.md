# Snowflake Authentication Guide

This document explains how to set up different authentication methods for the FinAI backend.

## 🔐 Key-Pair Authentication (Recommended for Production)

Key-pair authentication uses RSA public/private key pairs for secure, passwordless authentication.

### Step 1: Generate RSA Key Pair

Run the provided setup script:
```bash
./setup_keypair_auth.sh
```

This creates:
- `keys/snowflake_rsa_key.p8` (private key)
- `keys/snowflake_rsa_key.pub` (public key)

### Step 2: Add Public Key to Snowflake

1. Copy the public key content (displayed by setup script)
2. Add to your Snowflake user profile:

```sql
ALTER USER your_username SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A...';
```

### Step 3: Configure Environment

```bash
export SNOWFLAKE_ACCOUNT=your-account.region.snowflakecomputing.com
export SNOWFLAKE_USER=your-username
export SNOWFLAKE_PRIVATE_KEY_PATH=/absolute/path/to/keys/snowflake_rsa_key.p8
```

### Step 4: Test Authentication

```bash
cd backend
python test_keypair.py
```

## 🔑 Password Authentication

Simple username/password authentication.

### Configuration

```bash
export SNOWFLAKE_ACCOUNT=your-account.region.snowflakecomputing.com
export SNOWFLAKE_USER=your-username
export SNOWFLAKE_PASSWORD=your-password
```

## 🌐 External Browser Authentication (Default)

Uses system browser for SSO/MFA authentication.

### Configuration

```bash
export SNOWFLAKE_ACCOUNT=your-account.region.snowflakecomputing.com
export SNOWFLAKE_USER=your-username
```

No additional configuration needed. The browser will open for authentication.

## Authentication Priority

The app automatically detects and uses authentication methods in this order:

1. **Key-Pair** (if `SNOWFLAKE_PRIVATE_KEY_PATH` exists)
2. **Password** (if `SNOWFLAKE_PASSWORD` is set)
3. **External Browser** (default fallback)

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `SNOWFLAKE_ACCOUNT` | ✅ | Snowflake account identifier |
| `SNOWFLAKE_USER` | ✅ | Snowflake username |
| `SNOWFLAKE_PRIVATE_KEY_PATH` | 🔐 | Path to RSA private key file |
| `SNOWFLAKE_PRIVATE_KEY_PASSPHRASE` | 🔐 | Private key passphrase (if encrypted) |
| `SNOWFLAKE_PASSWORD` | 🔑 | User password |
| `SNOWFLAKE_WAREHOUSE` | ⚙️ | Warehouse name (default: COMPUTE_WH) |
| `SNOWFLAKE_DATABASE` | ⚙️ | Database name (default: FINAI_DB) |
| `SNOWFLAKE_SCHEMA` | ⚙️ | Schema name (default: CORTEX_AI) |

## Troubleshooting

### Key-Pair Issues

**Error: "Private key file not found"**
- Verify the file path in `SNOWFLAKE_PRIVATE_KEY_PATH`
- Ensure the file has proper permissions (600)

**Error: "Failed to load private key"**
- Check if the key file is in PEM format
- Verify the passphrase if the key is encrypted
- Ensure the `cryptography` package is installed

**Error: "Authentication failed"**
- Verify the public key is added to your Snowflake user
- Check that the account and username are correct
- Ensure the private key corresponds to the uploaded public key

### General Issues

**Error: "Missing SNOWFLAKE_ACCOUNT or SNOWFLAKE_USER"**
- Set the required environment variables
- Use absolute paths for file references

**Error: "Database connection failed"**
- Check network connectivity to Snowflake
- Verify account identifier format
- Test with a simple connection tool first

## Security Best Practices

### Key-Pair Authentication
- Store private keys securely (file permissions 600)
- Use encrypted private keys in production
- Rotate keys regularly
- Never commit private keys to version control

### General
- Use key-pair authentication for production deployments
- Avoid hardcoding credentials in code
- Use environment variables or secure secret management
- Monitor authentication logs for suspicious activity

## Testing

Test your authentication setup:

```bash
# Test key-pair authentication
cd backend && python test_keypair.py

# Test general app functionality  
cd backend && python test_app.py

# Start the Flask server
python app.py
```
