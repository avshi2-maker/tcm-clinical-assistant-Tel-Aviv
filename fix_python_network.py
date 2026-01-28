#!/usr/bin/env python3
"""
Fix Python network access to Supabase
Tries multiple methods to establish connection
"""

import socket
import sys

print("=" * 60)
print("🔧 PYTHON NETWORK FIX TOOL")
print("=" * 60)
print()

supabase_host = "oaitwmdwuoionjbmgkws.supabase.co"

print("Testing different network methods...")
print()

# Method 1: Direct socket connection
print("Method 1: Direct Socket Connection")
print("-" * 60)
try:
    # Try to resolve DNS using system DNS
    ip = socket.gethostbyname(supabase_host)
    print(f"✅ DNS Resolution: {supabase_host} → {ip}")
    
    # Try to connect
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5)
    result = sock.connect_ex((ip, 443))
    sock.close()
    
    if result == 0:
        print(f"✅ Can connect to {ip}:443")
        print()
        print("🎉 SUCCESS! Your Python CAN access Supabase!")
        print()
        print("The previous error might have been temporary.")
        print("Try running the translation script again:")
        print("  python translate_dr_roni_optimized_v2.py")
        sys.exit(0)
    else:
        print(f"❌ Cannot connect to {ip}:443 (error: {result})")
        print("   Port 443 might be blocked by firewall")
        
except socket.gaierror as e:
    print(f"❌ DNS Resolution Failed: {e}")
    print()
    
except Exception as e:
    print(f"❌ Connection Failed: {e}")
    print()

# Method 2: Try with Google DNS
print("Method 2: Using Google DNS (8.8.8.8)")
print("-" * 60)
print("Unfortunately, Python's socket module uses system DNS.")
print("To fix DNS issues, you need to change Windows DNS settings.")
print()

# Method 3: Check if it's a Python-specific issue
print("Method 3: Testing with requests library")
print("-" * 60)
try:
    import requests
    response = requests.get(
        "https://oaitwmdwuoionjbmgkws.supabase.co/rest/v1/",
        headers={"apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9haXR3bWR3dW9pb25qYm1na3dzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY5MzA4NjcsImV4cCI6MjA1MjUwNjg2N30.qkNjQUtUQgY8qRQnb-rjBnqI-BH7XfGfLr52HQxTPcs"},
        timeout=10
    )
    print(f"✅ HTTP Request Successful! Status: {response.status_code}")
    print()
    print("🎉 SUCCESS! Your Python CAN access Supabase via HTTP!")
    print()
    print("The supabase-py library might be having issues.")
    print("Try running the translation script again:")
    print("  python translate_dr_roni_optimized_v2.py")
    sys.exit(0)
    
except ImportError:
    print("⚠️  requests library not installed")
    print("   Install with: pip install requests")
    print()
    
except Exception as e:
    print(f"❌ HTTP Request Failed: {e}")
    print()

# Diagnosis
print("=" * 60)
print("🔍 DIAGNOSIS")
print("=" * 60)
print()
print("❌ Python cannot access Supabase from your current network")
print()
print("📋 RECOMMENDED SOLUTIONS (in order):")
print()
print("1️⃣  USE BROWSER METHOD (EASIEST!):")
print("   - Open: export_browser.html")
print("   - Click 'Export Data'")
print("   - Download JSON file")
print("   - Run: python translate_offline.py")
print()
print("2️⃣  USE PHONE HOTSPOT:")
print("   - Enable hotspot on phone")
print("   - Connect computer to phone WiFi")
print("   - Run: python translate_dr_roni_optimized_v2.py")
print()
print("3️⃣  CHANGE WINDOWS DNS:")
print("   - Press Win+R, type: ncpa.cpl")
print("   - Right-click WiFi → Properties")
print("   - IPv4 → Properties")
print("   - Use: 8.8.8.8 and 8.8.4.4")
print("   - Test again")
print()
print("4️⃣  CHECK FIREWALL:")
print("   - Windows Security → Firewall")
print("   - Allow Python through firewall")
print()
