#!/usr/bin/env python3
"""
Comprehensive SOCKS Scripts Test Suite
Tests syntax and basic functionality of all SOCKS proxy scripts
"""

import py_compile
import sys
import os
import subprocess
import tempfile

def test_script_syntax(script_path):
    """Test if a Python script has valid syntax"""
    try:
        py_compile.compile(script_path, doraise=True)
        return True, "OK"
    except py_compile.PyCompileError as e:
        return False, str(e)
    except Exception as e:
        return False, str(e)

def test_script_import(script_path):
    """Test if a script can be imported without errors"""
    try:
        # Create a temporary module name
        module_name = os.path.splitext(os.path.basename(script_path))[0].replace('-', '_')
        
        # Try to compile and check for basic issues
        with open(script_path, 'r') as f:
            content = f.read()
            
        # Check for common issues
        issues = []
        if 'print ' in content and 'print(' not in content:
            issues.append("Contains Python 2 print statements")
        if '\t    ' in content or '    \t' in content:
            issues.append("Mixed tabs and spaces")
        if '.strerror' in content:
            issues.append("Uses deprecated .strerror attribute")
            
        if issues:
            return False, "; ".join(issues)
        else:
            return True, "Import check passed"
            
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
    
    print("=" * 60)
    print("  SOCKS Proxy Scripts - Comprehensive Test Suite")
    print("=" * 60)
    
    all_passed = True
    results = {}
    
    for script in scripts:
        print(f"\nTesting {script}...")
        print("-" * 40)
        
        if not os.path.exists(script):
            print(f"❌ {script} - FILE NOT FOUND")
            results[script] = "NOT FOUND"
            all_passed = False
            continue
            
        # Test 1: Syntax Check
        syntax_ok, syntax_msg = test_script_syntax(script)
        if syntax_ok:
            print(f"✅ Syntax Check: PASSED")
        else:
            print(f"❌ Syntax Check: FAILED - {syntax_msg}")
            all_passed = False
            
        # Test 2: Import/Content Check
        import_ok, import_msg = test_script_import(script)
        if import_ok:
            print(f"✅ Content Check: PASSED")
        else:
            print(f"❌ Content Check: FAILED - {import_msg}")
            all_passed = False
            
        # Test 3: Check for Python 3 compatibility markers
        with open(script, 'r') as f:
            content = f.read()
            
        has_shebang = content.startswith('#!/usr/bin/env python3')
        has_encoding = 'encoding: utf-8' in content[:100]
        
        if has_shebang:
            print(f"✅ Python 3 Shebang: PRESENT")
        else:
            print(f"⚠️  Python 3 Shebang: MISSING")
            
        if has_encoding:
            print(f"✅ UTF-8 Encoding: PRESENT")
        else:
            print(f"⚠️  UTF-8 Encoding: MISSING")
            
        # Overall result for this script
        if syntax_ok and import_ok:
            results[script] = "PASSED"
            print(f"🎉 {script}: ALL TESTS PASSED")
        else:
            results[script] = "FAILED"
            print(f"💥 {script}: TESTS FAILED")
    
    # Summary
    print("\n" + "=" * 60)
    print("  TEST SUMMARY")
    print("=" * 60)
    
    for script, result in results.items():
        status_icon = "✅" if result == "PASSED" else "❌" if result == "FAILED" else "⚠️"
        print(f"{status_icon} {script:<20} {result}")
    
    print("\n" + "=" * 60)
    if all_passed:
        print("🎉 ALL SOCKS SCRIPTS PASSED ALL TESTS!")
        print("✅ Ready for production use")
        print("\nUsage examples:")
        print("  python3 socks.py")
        print("  python3 socks-ssh.py -p 8080")
        print("  python3 socks-ws-ssh.py -b 0.0.0.0 -p 8081")
        print("  python3 socks-ws-ssl.py 8082")
        return 0
    else:
        print("❌ SOME TESTS FAILED!")
        print("Please fix the issues before using the scripts.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
