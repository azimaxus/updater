#!/bin/bash
# Comprehensive script to update all VPN/Proxy protocols and configurations
# Updated: 2024

set -e

echo "=========================================="
echo "  VPN/Proxy Server Protocol Updater"
echo "=========================================="

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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Update system packages
update_system() {
    log_info "Updating system packages..."
    if command -v apt >/dev/null 2>&1; then
        apt update && apt upgrade -y
    elif command -v yum >/dev/null 2>&1; then
        yum update -y
    elif command -v dnf >/dev/null 2>&1; then
        dnf update -y
    fi
    log_success "System packages updated"
}

# Update Xray
update_xray() {
    log_info "Updating Xray to latest version..."
    
    if [ -f "/usr/local/bin/xray" ]; then
        # Backup current config
        cp /etc/xray/config.json /etc/xray/config.json.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
    fi
    
    # Download and install latest Xray (updated URL)
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version latest
    
    # Copy our updated config
    if [ -f "xray_config.json" ]; then
        cp xray_config.json /etc/xray/config.json
        systemctl restart xray 2>/dev/null || true
    fi
    
    log_success "Xray updated successfully"
}

# Update Hysteria
update_hysteria() {
    log_info "Updating Hysteria server..."
    
    if [ -f "install_server.sh" ]; then
        chmod +x install_server.sh
        ./install_server.sh
        log_success "Hysteria updated successfully"
    else
        log_warning "Hysteria install script not found"
    fi
}

# Apply BBR optimizations
apply_bbr() {
    log_info "Applying BBR TCP optimizations..."
    
    if [ -f "bbr.sh" ]; then
        chmod +x bbr.sh
        ./bbr.sh
        log_success "BBR optimizations applied"
    else
        log_warning "BBR script not found"
    fi
}

# Update Nginx configuration
update_nginx() {
    log_info "Updating Nginx configuration..."
    
    if [ -f "nginx.conf" ]; then
        if command -v nginx >/dev/null 2>&1; then
            # Backup current config
            if [ -f "/etc/nginx/nginx.conf" ]; then
                cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)
                log_info "Nginx config backed up"
            fi
            
            # Test new configuration
            if nginx -t -c $(pwd)/nginx.conf >/dev/null 2>&1; then
                cp nginx.conf /etc/nginx/nginx.conf
                if systemctl reload nginx 2>/dev/null; then
                    log_success "Nginx configuration updated and reloaded"
                else
                    log_warning "Nginx config updated but reload failed"
                fi
            else
                log_error "Nginx configuration test failed"
                return 1
            fi
        else
            log_warning "Nginx not installed, skipping configuration update"
        fi
    else
        log_warning "nginx.conf file not found in current directory"
    fi
}

# Update Squid configuration
update_squid() {
    log_info "Updating Squid configuration..."
    
    if [ -f "squid.sh" ] && command -v squid >/dev/null 2>&1; then
        chmod +x squid.sh
        cp squid.sh /etc/init.d/squid
        chmod +x /etc/init.d/squid
        log_success "Squid startup script updated"
    else
        log_warning "Squid not installed or script not found"
    fi
}

# Update ACME.sh
update_acme() {
    log_info "Updating ACME.sh..."
    
    if [ -f "update_acme.sh" ]; then
        chmod +x update_acme.sh
        ./update_acme.sh
        log_success "ACME.sh updated"
    else
        log_warning "ACME update script not found"
    fi
}

# Update Python scripts
update_python_scripts() {
    log_info "Updating Python proxy scripts..."
    
    # Make sure Python 3 is available
    if ! command -v python3 >/dev/null 2>&1; then
        log_warning "Python 3 not found, installing..."
        if command -v apt >/dev/null 2>&1; then
            apt install -y python3 python3-pip
        elif command -v yum >/dev/null 2>&1; then
            yum install -y python3 python3-pip
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y python3 python3-pip
        else
            log_error "Cannot install Python 3 automatically. Please install manually."
            return 1
        fi
    fi
    
    # Test Python scripts syntax
    local error_count=0
    for script in socks*.py; do
        if [ -f "$script" ]; then
            # Update shebang
            sed -i '1s|.*|#!/usr/bin/env python3|' "$script"
            chmod +x "$script"
            
            # Test syntax
            if python3 -m py_compile "$script" 2>/dev/null; then
                log_success "✓ $script syntax OK"
            else
                log_error "✗ $script has syntax errors"
                ((error_count++))
            fi
        fi
    done
    
    if [ $error_count -eq 0 ]; then
        log_success "All Python scripts updated successfully"
    else
        log_warning "$error_count Python scripts have syntax errors"
    fi
}

# Validate all configurations
validate_configs() {
    log_info "Validating configurations..."
    local validation_errors=0
    
    # Check JSON files
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
    
    # Check shell scripts
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
    
    if [ $validation_errors -eq 0 ]; then
        log_success "All configurations validated successfully"
        return 0
    else
        log_error "$validation_errors configuration files have errors"
        return 1
    fi
}

# Main execution
main() {
    log_info "Starting comprehensive protocol update..."
    
    # Check prerequisites
    check_root
    
    # Validate configurations first
    if ! validate_configs; then
        log_error "Configuration validation failed. Please fix errors before proceeding."
        exit 1
    fi
    
    # Create backup directory
    BACKUP_DIR="/root/vpn_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    log_info "Backup directory created: $BACKUP_DIR"
    
    # Run updates with error tracking
    local update_errors=0
    
    update_system || ((update_errors++))
    update_python_scripts || ((update_errors++))
    apply_bbr || ((update_errors++))
    update_nginx || ((update_errors++))
    update_squid || ((update_errors++))
    update_xray || ((update_errors++))
    update_hysteria || ((update_errors++))
    update_acme || ((update_errors++))
    
    if [ $update_errors -eq 0 ]; then
        log_success "All protocol updates completed successfully!"
    else
        log_warning "$update_errors updates encountered errors"
    fi
    
    log_info "Please reboot the system to ensure all changes take effect"
    log_info "Backup files are stored in: $BACKUP_DIR"
    
    # Final system status
    log_info "=== Final System Status ==="
    command -v xray >/dev/null && log_info "Xray: $(xray version 2>/dev/null | head -1 || echo 'Installed')"
    command -v hysteria >/dev/null && log_info "Hysteria: $(hysteria version 2>/dev/null || echo 'Installed')"
    command -v nginx >/dev/null && log_info "Nginx: $(nginx -v 2>&1 | head -1 || echo 'Installed')"
    command -v squid >/dev/null && log_info "Squid: $(squid -v 2>&1 | head -1 || echo 'Installed')"
    command -v python3 >/dev/null && log_info "Python3: $(python3 --version 2>&1 || echo 'Installed')"
}

# Run main function
main "$@"
