#!/usr/bin/env python3
"""
Network Diagnostic Tool
Tests connection to Supabase and Gemini
"""

import socket
import urllib.request
import sys

print("=" * 60)
print("🔍 NETWORK DIAGNOSTIC TOOL")
print("=" * 60)
print()

# Test 1: Basic Internet
print("Test 1: Basic Internet Connection")
print("-" * 60)
try:
    socket.create_connection(("8.8.8.8", 53), timeout=5)
    print("✅ Internet connection: OK")
except Exception as e:
    print(f"❌ Internet connection: FAILED")
    print(f"   Error: {e}")
    print()
    print("💡 SOLUTION: Check your WiFi/Ethernet connection")
    sys.exit(1)

print()

# Test 2: DNS Resolution
print("Test 2: DNS Resolution")
print("-" * 60)
try:
    socket.gethostbyname("google.com")
    print("✅ DNS resolution: OK")
except Exception as e:
    print(f"❌ DNS resolution: FAILED")
    print(f"   Error: {e}")
    print()
    print("💡 SOLUTION: Your DNS is not working. Try:")
    print("   1. Restart your router")
    print("   2. Change DNS to 8.8.8.8 (Google DNS)")
    sys.exit(1)

print()

# Test 3: Supabase Connection
print("Test 3: Supabase Database Connection")
print("-" * 60)
supabase_url = "oaitwmdwuoionjbmgkws.supabase.co"
try:
    socket.gethostbyname(supabase_url)
    print(f"✅ Can resolve: {supabase_url}")
except Exception as e:
    print(f"❌ Cannot resolve: {supabase_url}")
    print(f"   Error: {e}")
    print()
    print("💡 SOLUTION: Supabase is blocked or down. Try:")
    print("   1. Disable VPN if you have one")
    print("   2. Check firewall settings")
    print("   3. Try a different network")
    sys.exit(1)

try:
    response = urllib.request.urlopen(f"https://{supabase_url}", timeout=10)
    print(f"✅ Can connect to Supabase: OK")
except Exception as e:
    print(f"⚠️  Warning: HTTP connection issue")
    print(f"   Error: {e}")
    print("   (This might be OK - Supabase may not allow direct access)")

print()

# Test 4: Gemini API
print("Test 4: Gemini API Connection")
print("-" * 60)
gemini_host = "generativelanguage.googleapis.com"
try:
    socket.gethostbyname(gemini_host)
    print(f"✅ Can resolve: {gemini_host}")
except Exception as e:
    print(f"❌ Cannot resolve: {gemini_host}")
    print(f"   Error: {e}")
    sys.exit(1)

print()

# Test 5: Python packages
print("Test 5: Required Python Packages")
print("-" * 60)

try:
    from supabase import create_client
    print("✅ supabase package: OK")
except ImportError:
    print("❌ supabase package: MISSING")
    print("   Run: pip install supabase")

try:
    import google.generativeai as genai
    print("⚠️  google.generativeai: DEPRECATED (but will work)")
except ImportError:
    print("❌ google.generativeai: MISSING")
    print("   Run: pip install google-generativeai")

print()
print("=" * 60)
print("🎯 DIAGNOSIS COMPLETE")
print("=" * 60)
print()
print("If all tests passed, the translation script should work!")
print()
