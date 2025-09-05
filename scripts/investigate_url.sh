#!/bin/bash
# URL Investigation Script
# Usage: ./investigate_url.sh <url>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url>"
    echo "Investigates a URL safely"
    exit 1
fi

URL="$1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_DIR="$HOME/investigations/url_${TIMESTAMP}"

echo "=== URL Investigation Report ==="
echo "URL: $URL"
echo "Investigation started: $(date)"
echo "Report directory: $REPORT_DIR"
echo

# Create report directory
mkdir -p "$REPORT_DIR"

# Basic URL analysis
echo "=== URL Analysis ===" | tee "$REPORT_DIR/url_analysis.txt"
echo "URL: $URL" | tee -a "$REPORT_DIR/url_analysis.txt"
echo "Domain: $(echo $URL | sed 's|^[^/]*//||' | sed 's|/.*||')" | tee -a "$REPORT_DIR/url_analysis.txt"
echo | tee -a "$REPORT_DIR/url_analysis.txt"

# DNS lookup
echo "=== DNS Information ===" | tee "$REPORT_DIR/dns_info.txt"
DOMAIN=$(echo $URL | sed 's|^[^/]*//||' | sed 's|/.*||')
nslookup "$DOMAIN" 2>/dev/null | tee -a "$REPORT_DIR/dns_info.txt" || echo "DNS lookup failed" | tee -a "$REPORT_DIR/dns_info.txt"
echo | tee -a "$REPORT_DIR/dns_info.txt"

# Curl headers (safe)
echo "=== HTTP Headers ===" | tee "$REPORT_DIR/http_headers.txt"
curl -I -L --max-time 10 --user-agent "Investigation-Tool/1.0" "$URL" 2>/dev/null | tee -a "$REPORT_DIR/http_headers.txt" || echo "Could not retrieve headers" | tee -a "$REPORT_DIR/http_headers.txt"
echo | tee -a "$REPORT_DIR/http_headers.txt"

echo "=== Investigation Complete ==="
echo "Report saved to: $REPORT_DIR"
echo "To open URL in browser, run: firefox \"$URL\" &"
echo "WARNING: Only open trusted URLs in the browser!"