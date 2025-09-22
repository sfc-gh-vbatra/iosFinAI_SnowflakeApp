#!/usr/bin/env python3
"""
Test script for FinAI Flask backend.
Tests that the app can start without the deprecated Flask decorator.
"""

import os
import sys
import logging

# Set up basic logging
logging.basicConfig(level=logging.INFO)

def test_import():
    """Test that the app can be imported without errors."""
    try:
        from app import app, cortex_ai
        print("✅ App imported successfully")
        return True
    except Exception as e:
        print(f"❌ Import failed: {e}")
        return False

def test_routes():
    """Test that routes are properly defined."""
    try:
        from app import app
        
        # Get all registered routes
        routes = []
        for rule in app.url_map.iter_rules():
            routes.append(f"{rule.methods} {rule.rule}")
        
        print("✅ Registered routes:")
        for route in sorted(routes):
            print(f"   {route}")
        
        return True
    except Exception as e:
        print(f"❌ Route test failed: {e}")
        return False

def test_health_endpoint():
    """Test the health endpoint."""
    try:
        from app import app
        
        with app.test_client() as client:
            response = client.get('/api/health')
            
            if response.status_code == 200:
                print("✅ Health endpoint working")
                print(f"   Response: {response.get_json()}")
                return True
            else:
                print(f"❌ Health endpoint failed: {response.status_code}")
                return False
                
    except Exception as e:
        print(f"❌ Health endpoint test failed: {e}")
        return False

def main():
    """Run all tests."""
    print("🧪 Testing FinAI Flask Backend")
    print("=" * 35)
    
    tests = [
        ("Import Test", test_import),
        ("Routes Test", test_routes),
        ("Health Endpoint Test", test_health_endpoint)
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n🔍 {test_name}:")
        if test_func():
            passed += 1
        else:
            print("   Test failed!")
    
    print(f"\n📊 Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Flask app is ready to run.")
        print("\n🚀 To start the server:")
        print("   python app.py")
    else:
        print("❌ Some tests failed. Please check the errors above.")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
