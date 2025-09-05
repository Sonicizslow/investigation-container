#!/bin/bash
# Investigation Container Start Script

echo "======================================"
echo "  Investigation Container Started"
echo "======================================"
echo
echo "Available tools and commands:"
echo
echo "Document Analysis:"
echo "  analyze_document.sh <file>  - Analyze a document for malicious content"
echo "  safe_view.sh <file>         - View a document safely"
echo
echo "URL Investigation:"
echo "  investigate_url.sh <url>    - Analyze a URL"
echo "  lynx <url>                  - Open URL in text browser"
echo
echo "File Management:"
echo "  Downloads folder: ~/downloads (read-only)"
echo "  Investigation results: ~/investigations"
echo
echo "System Tools:"
echo "  file <file>                 - Identify file type"
echo "  strings <file>              - Extract strings (or use grep)"
echo "  xxd <file>                  - Hex dump"
echo "  python3                     - Python interpreter"
echo "  lynx                        - Text-based web browser"
echo "  gedit                       - Text editor"
echo
echo "Security Note: Running as non-root user 'investigator'"
echo "Downloads folder is mounted read-only for safety"
echo
echo "Type 'exit' to close the container"
echo "======================================"
echo

# Start terminal
exec /bin/bash