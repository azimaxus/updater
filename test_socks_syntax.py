#!/usr/bin/env python3
"""
Test script to validate Python SOCKS proxy scripts syntax
"""

import py_compile
import sys
import os

def test_script_syntax(script_path):
    """Test if a Python script has valid syntax"""
    try:
        py_compile.compile(script_path, doraise=True)
        return True, "OK"
    except py_compile.PyCompileError as e:
        return False, str(e)
    except Exception as e:
        return False, str(e)

def main():
    """Test all SOCKS scripts"""
    scripts = [
        'socks.py',
        'socks-ssh.py', 
        'socks-ws-ssh.py',
        'socks-ws-ssl.py'
    ]
    
    print("Testing SOCKS proxy scripts syntax...")
    print("=" * 50)
    
    all_passed = True
    
    for script in scripts:
        if os.path.exists(script):
            passed, message = test_script_syntax(script)
            status = "✓ PASS" if passed else "✗ FAIL"
            print(f"{script:<20} {status}")
            if not passed:
                print(f"  Error: {message}")
                all_passed = False
        else:
            print(f"{script:<20} ⚠ NOT FOUND")
    
    print("=" * 50)
    if all_passed:
        print("✓ All SOCKS scripts have valid syntax!")
        return 0
    else:
        print("✗ Some scripts have syntax errors!")
        return 1

if __name__ == "__main__":
    sys.exit(main())
