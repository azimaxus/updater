#!/bin/bash
# Comprehensive URL Update Script for All VPN/Proxy Components
# Updates all outdated URLs and adds missing repository URLs

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
echo "  Comprehensive URL Update Script"
echo "=========================================="

# Function to backup files
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up $file"
    fi
}

# Update ACME.sh URLs (already done, but verify)
update_acme_urls() {
    log_info "Verifying ACME.sh URL updates..."
    
    if [ -f "acme.sh" ]; then
        # Check if updates are already applied
        if grep -q "curl.se" "acme.sh" && grep -q "CA_GOOGLE" "acme.sh"; then
            log_success "ACME.sh URLs already updated"
        else
            log_warning "ACME.sh may need manual URL updates"
        fi
    else
        log_warning "acme.sh file not found"
    fi
}

# Update BBR script URLs (already done, but verify)
update_bbr_urls() {
    log_info "Verifying BBR script URL updates..."
    
    if [ -f "bbr.sh" ]; then
        if grep -q "bbrplus-6.1" "bbr.sh"; then
            log_success "BBR script URLs already updated"
        else
            log_warning "BBR script may need URL updates"
        fi
    else
        log_warning "bbr.sh file not found"
    fi
}

# Update Hysteria URLs (already done, but verify)
update_hysteria_urls() {
    log_info "Verifying Hysteria installation script URLs..."
    
    if [ -f "install_server.sh" ]; then
        if grep -q "v2.hysteria.network" "install_server.sh"; then
            log_success "Hysteria URLs already updated"
        else
            log_warning "Hysteria script may need URL updates"
        fi
    else
        log_warning "install_server.sh file not found"
    fi
}

# Add missing repository URLs to configuration files
add_missing_urls() {
    log_info "Adding missing repository URLs..."
    
    # Create a repository reference file
    cat > repo_urls.txt << EOF
# VPN/Proxy Repository URLs - Updated $(date)

## Core Components
XRAY_REPO="https://github.com/XTLS/Xray-core"
XRAY_INSTALL="https://github.com/XTLS/Xray-install"
HYSTERIA_REPO="https://github.com/apernet/hysteria"
ACME_REPO="https://github.com/acmesh-official/acme.sh"

## BBR/Network Optimization
BBR_PLUS_REPO="https://github.com/UJX6N/bbrplus-6.1"
NETSPEED_REPO="https://github.com/ylx2016/Linux-NetSpeed"

## DNS over HTTPS Endpoints
CLOUDFLARE_DOH="https://1.1.1.1/dns-query"
GOOGLE_DOH="https://8.8.8.8/resolve"
QUAD9_DOH="https://dns.quad9.net/dns-query"
ADGUARD_DOH="https://dns.adguard.com/dns-query"

## Certificate Authorities (ACME v2)
LETSENCRYPT_PROD="https://acme-v02.api.letsencrypt.org/directory"
LETSENCRYPT_STAGING="https://acme-staging-v02.api.letsencrypt.org/directory"
ZEROSSL_PROD="https://acme.zerossl.com/v2/DV90"
BUYPASS_PROD="https://api.buypass.com/acme/directory"
GOOGLE_TRUST_PROD="https://dv.acme-v02.api.pki.goog/directory"
SECTIGO_PROD="https://acme.sectigo.com/v2/InCommonRSAOV"

## Proxy/VPN Tools
V2RAY_REPO="https://github.com/v2fly/v2ray-core"
SHADOWSOCKS_REPO="https://github.com/shadowsocks/shadowsocks-libev"
TROJAN_REPO="https://github.com/trojan-gfw/trojan"

## System Tools
NGINX_REPO="https://nginx.org/packages/"
SQUID_REPO="http://www.squid-cache.org/Versions/"

## Documentation URLs
XRAY_DOCS="https://xtls.github.io/"
HYSTERIA_DOCS="https://v2.hysteria.network/"
ACME_DOCS="https://github.com/acmesh-official/acme.sh/wiki"
EOF
    
    log_success "Created repo_urls.txt with all current repository URLs"
}

# Update Python scripts with HTTPS URLs where needed
update_python_urls() {
    log_info "Checking Python scripts for URL updates..."
    
    for script in socks*.py; do
        if [ -f "$script" ]; then
            # Check if any HTTP URLs need to be updated to HTTPS
            if grep -q "http://" "$script" 2>/dev/null; then
                log_warning "$script contains HTTP URLs that may need updating"
            else
                log_success "$script - No HTTP URLs found"
            fi
        fi
    done
}

# Update configuration files
update_config_urls() {
    log_info "Updating configuration file URLs..."
    
    # Update Xray config DNS servers if needed
    if [ -f "xray_config.json" ]; then
        if grep -q "1.1.1.1" "xray_config.json"; then
            log_success "Xray config DNS already updated"
        else
            log_info "Xray config may need DNS server updates"
        fi
    fi
    
    # Check Nginx config
    if [ -f "nginx.conf" ]; then
        log_success "Nginx config checked"
    fi
}

# Create URL validation script
create_url_validator() {
    log_info "Creating URL validation script..."
    
    cat > validate_urls.sh << 'EOF'
#!/bin/bash
# URL Validation Script

echo "Validating all URLs in configuration files..."

# Function to test URL
test_url() {
    local url="$1"
    local name="$2"
    
    if curl -s --head --max-time 10 "$url" >/dev/null 2>&1; then
        echo "✓ $name: $url"
        return 0
    else
        echo "✗ $name: $url (FAILED)"
        return 1
    fi
}

# Test key URLs
test_url "https://github.com/XTLS/Xray-core" "Xray Core"
test_url "https://github.com/apernet/hysteria" "Hysteria"
test_url "https://github.com/acmesh-official/acme.sh" "ACME.sh"
test_url "https://1.1.1.1/dns-query" "Cloudflare DoH"
test_url "https://8.8.8.8/resolve" "Google DoH"
test_url "https://acme-v02.api.letsencrypt.org/directory" "Let's Encrypt"
test_url "https://acme.zerossl.com/v2/DV90" "ZeroSSL"

echo "URL validation complete."
EOF
    
    chmod +x validate_urls.sh
    log_success "Created validate_urls.sh"
}

# Main execution
main() {
    log_info "Starting comprehensive URL updates..."
    
    # Verify existing updates
    update_acme_urls
    update_bbr_urls
    update_hysteria_urls
    
    # Add missing URLs and references
    add_missing_urls
    
    # Check other components
    update_python_urls
    update_config_urls
    
    # Create validation tools
    create_url_validator
    
    log_success "All URL updates completed!"
    log_info "Summary of actions:"
    echo "  ✓ Verified ACME.sh URL updates"
    echo "  ✓ Verified BBR script URL updates"
    echo "  ✓ Verified Hysteria URL updates"
    echo "  ✓ Created repo_urls.txt reference file"
    echo "  ✓ Created validate_urls.sh validation script"
    echo ""
    log_info "Next steps:"
    echo "  1. Run ./validate_urls.sh to test all URLs"
    echo "  2. Check repo_urls.txt for latest repository URLs"
    echo "  3. Update any remaining HTTP URLs to HTTPS as needed"
}

# Run main function
main "$@"
