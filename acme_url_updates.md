# ACME.sh URL Updates Summary

## Version Update
- Updated version from 3.0.2 to 3.0.8

## Certificate Authority Updates

### Added New CAs:
1. **Google Trust Services**
   - Production: `https://dv.acme-v02.api.pki.goog/directory`
   - Testing: `https://dv.acme-v02.test-api.pki.goog/directory`

2. **Sectigo CA**
   - RSA: `https://acme.sectigo.com/v2/InCommonRSAOV`
   - ECC: `https://acme.sectigo.com/v2/InCommonECCOV`

### Updated CA Names List:
- Added Google.com,google
- Added Google.com_test,google_test,googletest  
- Added Sectigo.com,sectigo

### Updated CA Servers List:
- Added new CAs to the server list for automatic detection

## URL Updates

### Fixed Outdated URLs:
1. **Curl Error Documentation**
   - Old: `https://curl.haxx.se/libcurl/c/libcurl-errors.html`
   - New: `https://curl.se/libcurl/c/libcurl-errors.html`

2. **Cloudflare DNS over HTTPS**
   - Old: `https://cloudflare-dns.com/dns-query`
   - New: `https://1.1.1.1/dns-query`
   - Old: `https://cloudflare-dns.com/api/v1/purge`
   - New: `https://1.1.1.1/api/v1/purge`
   - Old: `https://cloudflare-dns.com` (availability check)
   - New: `https://1.1.1.1`

3. **Google DNS over HTTPS**
   - Old: `https://dns.google/resolve`
   - New: `https://8.8.8.8/resolve`

## Benefits of Updates

1. **More CA Options**: Users can now choose from Google Trust Services and Sectigo CAs
2. **Better Reliability**: Updated DNS endpoints are more stable and faster
3. **Current Documentation**: Error reference URLs now point to current documentation
4. **Enhanced Compatibility**: Support for newer ACME v2 endpoints

## Usage Examples

### Using Google Trust Services:
```bash
./acme.sh --issue -d example.com --server google
```

### Using Sectigo CA:
```bash  
./acme.sh --issue -d example.com --server sectigo
```

### List all available CAs:
```bash
./acme.sh --list-ca
```

All URLs have been updated to their latest versions for better reliability and security.
