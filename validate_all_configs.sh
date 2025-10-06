#!/bin/bash
# Configuration validation script for VPN/Proxy server setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "=========================================="
echo "  VPN/Proxy Configuration Validator"
echo "=========================================="

validation_errors=0

# Check Python scripts
log_info "Validating Python scripts..."
for script in socks*.py; do
    if [ -f "$script" ]; then
        if python3 -m py_compile "$script" 2>/dev/null; then
            log_success "✓ $script syntax OK"
        else
            log_error "✗ $script has syntax errors"
            ((validation_errors++))
        fi
    fi
done

# Check shell scripts
log_info "Validating shell scripts..."
for script in *.sh; do
    if [ -f "$script" ] && [ "$script" != "$(basename "$0")" ]; then
        if bash -n "$script" 2>/dev/null; then
            log_success "✓ $script syntax OK"
        else
            log_error "✗ $script has syntax errors"
            ((validation_errors++))
        fi
    fi
done

# Check JSON files
log_info "Validating JSON configurations..."
for json_file in *.json; do
    if [ -f "$json_file" ]; then
        if python3 -m json.tool "$json_file" >/dev/null 2>&1; then
            log_success "✓ $json_file is valid JSON"
        else
            log_error "✗ $json_file has JSON syntax errors"
            ((validation_errors++))
        fi
    fi
done

# Check configuration files
log_info "Checking configuration files..."

# Check if key files exist
required_files=(
    "xray_config.json"
    "nginx.conf"
    "install_server.sh"
    "bbr.sh"
    "socks.py"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        log_success "✓ $file exists"
    else
        log_warning "⚠ $file not found"
    fi
done

# Check Nginx configuration if nginx is available
if command -v nginx >/dev/null 2>&1 && [ -f "nginx.conf" ]; then
    if nginx -t -c "$(pwd)/nginx.conf" >/dev/null 2>&1; then
        log_success "✓ nginx.conf syntax is valid"
    else
        log_error "✗ nginx.conf has syntax errors"
        ((validation_errors++))
    fi
fi

# Summary
echo ""
echo "=========================================="
if [ $validation_errors -eq 0 ]; then
    log_success "All configurations validated successfully!"
    echo "Your VPN/Proxy server setup is ready for deployment."
    exit 0
else
    log_error "$validation_errors configuration files have errors"
    echo "Please fix the errors before deploying."
    exit 1
fi
