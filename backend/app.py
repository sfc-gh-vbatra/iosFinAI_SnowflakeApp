#!/usr/bin/env python3
"""
FinAI Backend - Snowflake Cortex AI Financial Services API
Flask backend that connects to Snowflake and provides AI-powered financial services.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import logging
from datetime import datetime, timedelta
import json

# Snowflake imports
try:
    import snowflake.connector
    from snowflake.connector import DictCursor
except ImportError:
    print("❌ Install snowflake-connector-python: pip install snowflake-connector-python")
    exit(1)

# Cryptography imports for key-pair authentication
try:
    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric import rsa
    from cryptography.hazmat.backends import default_backend
except ImportError:
    print("❌ Install cryptography for key-pair auth: pip install cryptography")
    print("   Note: Key-pair authentication will be disabled without this package")
    serialization = None

app = Flask(__name__)
CORS(app)  # Enable CORS for iOS app

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SnowflakeCortexAI:
    """Handles Snowflake Cortex AI operations for financial services."""
    
    def __init__(self):
        self.connection = None
        self.cursor = None
    
    def _load_private_key(self, private_key_path, passphrase=None):
        """Load and return private key from file."""
        try:
            if not serialization:
                logger.error("Cryptography package not available for key-pair authentication")
                return None
                
            with open(private_key_path, 'rb') as key_file:
                private_key = serialization.load_pem_private_key(
                    key_file.read(),
                    password=passphrase.encode() if passphrase else None,
                    backend=default_backend()
                )
                
            # Convert to DER format for Snowflake
            private_key_der = private_key.private_bytes(
                encoding=serialization.Encoding.DER,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption()
            )
            
            logger.info(f"Successfully loaded private key from {private_key_path}")
            return private_key_der
            
        except FileNotFoundError:
            logger.error(f"Private key file not found: {private_key_path}")
            return None
        except Exception as e:
            logger.error(f"Failed to load private key: {e}")
            return None
    
    def _get_auth_method(self):
        """Determine authentication method based on available environment variables."""
        # Check for key-pair authentication
        private_key_path = os.getenv('SNOWFLAKE_PRIVATE_KEY_PATH')
        if private_key_path and os.path.exists(private_key_path):
            return 'keypair'
        
        # Check for password authentication
        password = os.getenv('SNOWFLAKE_PASSWORD')
        if password:
            return 'password'
        
        # Default to external browser authentication
        return 'externalbrowser'
    
    def connect(self):
        """Connect to Snowflake using the best available authentication method."""
        try:
            # Base connection parameters
            connection_params = {
                'account': os.getenv('SNOWFLAKE_ACCOUNT'),
                'user': os.getenv('SNOWFLAKE_USER'),
                'warehouse': os.getenv('SNOWFLAKE_WAREHOUSE', 'COMPUTE_WH'),
                'database': os.getenv('SNOWFLAKE_DATABASE', 'FINAI_DB'),
                'schema': os.getenv('SNOWFLAKE_SCHEMA', 'CORTEX_AI'),
            }
            
            if not connection_params['account'] or not connection_params['user']:
                logger.error("Missing SNOWFLAKE_ACCOUNT or SNOWFLAKE_USER environment variables")
                return False
            
            # Determine and configure authentication method
            auth_method = self._get_auth_method()
            
            if auth_method == 'keypair':
                logger.info("Using key-pair authentication")
                private_key_path = os.getenv('SNOWFLAKE_PRIVATE_KEY_PATH')
                private_key_passphrase = os.getenv('SNOWFLAKE_PRIVATE_KEY_PASSPHRASE')
                
                private_key_der = self._load_private_key(private_key_path, private_key_passphrase)
                if not private_key_der:
                    logger.error("Failed to load private key, falling back to external browser")
                    connection_params['authenticator'] = 'externalbrowser'
                else:
                    connection_params['private_key'] = private_key_der
                    
            elif auth_method == 'password':
                logger.info("Using password authentication")
                connection_params['password'] = os.getenv('SNOWFLAKE_PASSWORD')
                
            else:
                logger.info("Using external browser authentication")
                connection_params['authenticator'] = 'externalbrowser'
            
            self.connection = snowflake.connector.connect(**connection_params)
            self.cursor = self.connection.cursor(DictCursor)
            logger.info(f"Connected to Snowflake successfully using {auth_method} authentication")
            return True
            
        except Exception as e:
            logger.error(f"Failed to connect to Snowflake: {e}")
            return False
    
    def analyze_fraud(self, transaction_data):
        """Use Cortex AI to analyze transaction for fraud indicators."""
        try:
            # Prepare transaction context for AI analysis
            transaction_context = f"""
            Transaction Details:
            Amount: ${transaction_data.get('amount', 0)}
            Merchant: {transaction_data.get('merchant', 'Unknown')}
            Location: {transaction_data.get('location', 'Unknown')}
            Time: {transaction_data.get('timestamp', 'Unknown')}
            Card Type: {transaction_data.get('card_type', 'Unknown')}
            Customer ID: {transaction_data.get('customer_id', 'Unknown')}
            """
            
            # Use Cortex AI LLM for fraud analysis
            query = """
            SELECT SNOWFLAKE.CORTEX.COMPLETE(
                'llama2-70b-chat',
                CONCAT(
                    'As a fraud detection expert, analyze this transaction and provide a risk score (0-100) and explanation. ',
                    'Consider factors like amount, merchant type, location, and timing patterns. ',
                    'Respond in JSON format with "risk_score", "risk_level", and "explanation" fields.\n\n',
                    %s
                )
            ) as fraud_analysis
            """
            
            self.cursor.execute(query, (transaction_context,))
            result = self.cursor.fetchone()
            
            if result and result['FRAUD_ANALYSIS']:
                # Try to parse JSON response
                try:
                    analysis = json.loads(result['FRAUD_ANALYSIS'])
                except json.JSONDecodeError:
                    # Fallback if not valid JSON
                    analysis = {
                        'risk_score': 50,
                        'risk_level': 'Medium',
                        'explanation': result['FRAUD_ANALYSIS']
                    }
                
                return analysis
            
            return {'error': 'Failed to analyze transaction'}
            
        except Exception as e:
            logger.error(f"Fraud analysis error: {e}")
            return {'error': str(e)}
    
    def analyze_market_sentiment(self, news_text):
        """Analyze market sentiment using Cortex AI."""
        try:
            # Use Cortex sentiment analysis
            query = """
            SELECT 
                SNOWFLAKE.CORTEX.SENTIMENT(%s) as sentiment_score,
                SNOWFLAKE.CORTEX.COMPLETE(
                    'llama2-70b-chat',
                    CONCAT(
                        'Analyze this financial news for market impact. Provide investment implications in JSON format with ',
                        '"sentiment", "market_impact", "sectors_affected", and "investment_recommendation" fields.\n\n',
                        %s
                    )
                ) as market_analysis
            """
            
            self.cursor.execute(query, (news_text, news_text))
            result = self.cursor.fetchone()
            
            if result:
                analysis = {
                    'sentiment_score': result['SENTIMENT_SCORE'],
                    'market_analysis': result['MARKET_ANALYSIS']
                }
                
                # Try to parse market analysis JSON
                try:
                    market_data = json.loads(result['MARKET_ANALYSIS'])
                    analysis['market_analysis'] = market_data
                except json.JSONDecodeError:
                    pass
                
                return analysis
            
            return {'error': 'Failed to analyze market sentiment'}
            
        except Exception as e:
            logger.error(f"Market sentiment analysis error: {e}")
            return {'error': str(e)}
    
    def assess_credit_risk(self, customer_data):
        """Assess credit risk using customer financial data."""
        try:
            customer_context = f"""
            Customer Profile:
            Income: ${customer_data.get('income', 0)}
            Credit History: {customer_data.get('credit_history', 'Unknown')} years
            Debt-to-Income Ratio: {customer_data.get('debt_ratio', 0)}%
            Employment Status: {customer_data.get('employment', 'Unknown')}
            Previous Defaults: {customer_data.get('defaults', 0)}
            Credit Utilization: {customer_data.get('utilization', 0)}%
            """
            
            query = """
            SELECT SNOWFLAKE.CORTEX.COMPLETE(
                'llama2-70b-chat',
                CONCAT(
                    'As a credit risk analyst, evaluate this customer profile and provide a credit score (300-850), ',
                    'risk category (Low/Medium/High), and detailed analysis. ',
                    'Respond in JSON format with "credit_score", "risk_category", "approval_recommendation", and "analysis" fields.\n\n',
                    %s
                )
            ) as risk_assessment
            """
            
            self.cursor.execute(query, (customer_context,))
            result = self.cursor.fetchone()
            
            if result and result['RISK_ASSESSMENT']:
                try:
                    assessment = json.loads(result['RISK_ASSESSMENT'])
                except json.JSONDecodeError:
                    assessment = {
                        'credit_score': 650,
                        'risk_category': 'Medium',
                        'analysis': result['RISK_ASSESSMENT']
                    }
                
                return assessment
            
            return {'error': 'Failed to assess credit risk'}
            
        except Exception as e:
            logger.error(f"Credit risk assessment error: {e}")
            return {'error': str(e)}
    
    def financial_chat(self, user_question, context=None):
        """AI-powered financial assistant chat."""
        try:
            system_prompt = """
            You are a professional financial advisor AI assistant. Provide helpful, accurate financial advice 
            while being clear about limitations and encouraging users to consult with licensed professionals 
            for personalized advice. Keep responses concise and actionable.
            """
            
            full_prompt = f"{system_prompt}\n\nUser Question: {user_question}"
            if context:
                full_prompt += f"\n\nContext: {context}"
            
            query = """
            SELECT SNOWFLAKE.CORTEX.COMPLETE(
                'llama2-70b-chat',
                %s
            ) as chat_response
            """
            
            self.cursor.execute(query, (full_prompt,))
            result = self.cursor.fetchone()
            
            if result and result['CHAT_RESPONSE']:
                return {'response': result['CHAT_RESPONSE']}
            
            return {'error': 'Failed to generate response'}
            
        except Exception as e:
            logger.error(f"Financial chat error: {e}")
            return {'error': str(e)}
    
    def ensure_connection(self):
        """Ensure Snowflake connection is active."""
        if not self.connection or not self.cursor:
            logger.warning("Connection lost, attempting to reconnect...")
            return self.connect()
        
        try:
            # Test the connection with a simple query
            self.cursor.execute("SELECT 1")
            return True
        except Exception as e:
            logger.warning(f"Connection test failed: {e}, attempting to reconnect...")
            return self.connect()

# Initialize Cortex AI handler
cortex_ai = SnowflakeCortexAI()

def initialize_snowflake():
    """Initialize Snowflake connection on startup."""
    logger.info("Initializing Snowflake connection...")
    if not cortex_ai.connect():
        logger.error("Failed to initialize Snowflake connection")
        return False
    logger.info("Snowflake connection initialized successfully")
    return True

# API Routes

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint."""
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

@app.route('/api/fraud/analyze', methods=['POST'])
def analyze_fraud():
    """Analyze transaction for fraud indicators."""
    try:
        if not cortex_ai.ensure_connection():
            return jsonify({'error': 'Database connection failed'}), 500
        
        transaction_data = request.get_json()
        result = cortex_ai.analyze_fraud(transaction_data)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/market/sentiment', methods=['POST'])
def market_sentiment():
    """Analyze market sentiment from news."""
    try:
        if not cortex_ai.ensure_connection():
            return jsonify({'error': 'Database connection failed'}), 500
        
        data = request.get_json()
        news_text = data.get('text', '')
        result = cortex_ai.analyze_market_sentiment(news_text)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/risk/assess', methods=['POST'])
def assess_risk():
    """Assess customer credit risk."""
    try:
        if not cortex_ai.ensure_connection():
            return jsonify({'error': 'Database connection failed'}), 500
        
        customer_data = request.get_json()
        result = cortex_ai.assess_credit_risk(customer_data)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/chat/financial', methods=['POST'])
def financial_chat():
    """AI-powered financial assistant."""
    try:
        if not cortex_ai.ensure_connection():
            return jsonify({'error': 'Database connection failed'}), 500
        
        data = request.get_json()
        question = data.get('question', '')
        context = data.get('context', '')
        result = cortex_ai.financial_chat(question, context)
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/demo/sample-data', methods=['GET'])
def get_sample_data():
    """Get sample data for demo purposes."""
    sample_data = {
        'transactions': [
            {
                'id': 'TXN001',
                'amount': 1250.00,
                'merchant': 'Electronics Store',
                'location': 'New York, NY',
                'timestamp': '2024-01-15T14:30:00Z',
                'card_type': 'Credit',
                'customer_id': 'CUST001'
            },
            {
                'id': 'TXN002',
                'amount': 5000.00,
                'merchant': 'Cash Advance',
                'location': 'Miami, FL',
                'timestamp': '2024-01-15T23:45:00Z',
                'card_type': 'Credit',
                'customer_id': 'CUST002'
            }
        ],
        'customers': [
            {
                'customer_id': 'CUST001',
                'income': 75000,
                'credit_history': 5,
                'debt_ratio': 25,
                'employment': 'Full-time',
                'defaults': 0,
                'utilization': 15
            }
        ],
        'news': [
            {
                'headline': 'Tech Stocks Rally on Strong Earnings',
                'content': 'Major technology companies reported better-than-expected earnings, driving significant gains in the NASDAQ index...'
            }
        ]
    }
    return jsonify(sample_data)

if __name__ == '__main__':
    # Initialize Snowflake connection before starting the app
    logger.info("Starting FinAI Backend Server...")
    
    if initialize_snowflake():
        logger.info("🚀 Starting Flask server on http://localhost:5000")
        app.run(debug=True, host='0.0.0.0', port=5000)
    else:
        logger.error("❌ Failed to initialize Snowflake connection. Please check your credentials.")
        logger.error("Make sure to set SNOWFLAKE_ACCOUNT and SNOWFLAKE_USER environment variables")
        exit(1)
