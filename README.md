# Investigation Container

A containerized investigation tool for cyber security professionals to safely analyze potentially malicious documents (PDF, DOCX, XLSX) and URLs. The container provides both CLI and GUI tools while maintaining security through minimal permissions and isolated environment.

## Features

- **Document Analysis**: Analyze PDF, DOCX, XLSX files for malicious content
- **URL Investigation**: Safely investigate suspicious URLs
- **Full GUI Environment**: Complete desktop environment accessible via RDP
- **GUI Dashboard**: User-friendly graphical interface for all investigation tools
- **CLI Tools**: exiftool, binwalk, strings, and more for command-line analysis
- **Security**: Runs as non-root user with minimal permissions
- **Isolation**: Downloads folder mounted read-only from host

## Quick Start (GUI Mode - Recommended)

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd investigation-container
   ```

2. **Create the phishing downloads directory** (if it doesn't exist):
   ```bash
   mkdir -p ~/phishing/Downloads
   ```

3. **Build and start the container**:
   ```bash
   docker compose up --build
   ```

4. **Connect via RDP**:
   - **Host**: `localhost`
   - **Port**: `3389`
   - **Username**: `investigator`
   - **Password**: `investigate2024`

   Use any RDP client:
   - **Windows**: Built-in Remote Desktop Connection
   - **macOS**: Microsoft Remote Desktop (App Store)
   - **Linux**: Remmina, FreeRDP, or Vinagre

5. **Access the Investigation Dashboard**:
   - The GUI dashboard will start automatically
   - Or double-click the "Investigation Container" icon on the desktop

## GUI Dashboard Features

The Investigation Container includes a user-friendly GUI dashboard with the following features:

### Document Analysis Tab
- Browse and select documents from the Downloads folder
- Configure analysis options (basic info, strings, metadata)
- One-click document analysis with real-time output
- Safe document viewing

### URL Investigation Tab
- Enter URLs for automated investigation
- DNS lookup and HTTP header analysis
- Safe browsing with text-based browser (Lynx)

### File Browser Tab
- Quick access to Downloads and Investigations folders
- Launch applications (LibreOffice, Firefox, Text Editor, etc.)
- Integrated file management

### Results Tab
- View all investigation results in an organized list
- Open investigation reports with double-click
- Refresh results automatically

## Legacy CLI Mode

For users who prefer command-line access or need X11 forwarding:

### Prerequisites for CLI Mode

- Docker and Docker Compose installed
- X11 server running (for GUI applications)
- `~/phishing/Downloads` directory on host system

#### Linux Setup for CLI Mode

For GUI applications to work, you need to allow X11 connections:

```bash
# Allow local connections to X server
xhost +local:docker
```

#### macOS Setup for CLI Mode

Install XQuartz for X11 support:

```bash
# Install XQuartz
brew install --cask xquartz

# Start XQuartz and enable "Allow connections from network clients"
# Then run:
xhost +localhost
```

### Document Analysis

#### Automated Analysis
```bash
# Analyze a document comprehensively
./tools/analyze_document.sh ~/downloads/suspicious.pdf

# This creates a report in ~/investigations/ with:
# - File metadata and hashes
# - Embedded content analysis
# - Strings extraction
# - File type specific analysis
```

#### Manual Analysis Tools
```bash
# Extract metadata
exiftool ~/downloads/document.pdf

# Find embedded files
binwalk ~/downloads/document.docx

# Extract strings
strings ~/downloads/document.xlsx | less

# Identify file type
file ~/downloads/unknown_file
```

#### Safe Document Viewing
```bash
# Open document in read-only mode
./tools/safe_view.sh ~/downloads/document.pdf
```

### URL Investigation

```bash
# Investigate a URL safely
./tools/investigate_url.sh "https://suspicious-domain.com"

# Open URL in Firefox (use caution!)
firefox "https://google.com" &
```

### GUI Applications

```bash
# Text editor
gedit &

# Text-based web browser
lynx google.com
```

## Security Features

- **Non-root execution**: Container runs as user `investigator` (UID 1000)
- **Read-only downloads**: Host downloads folder mounted read-only
- **Minimal capabilities**: Only essential Linux capabilities enabled
- **Resource limits**: CPU and memory limits applied
- **No new privileges**: Prevents privilege escalation
- **Network isolation**: Controlled network access

## Directory Structure

```
investigation-container/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Container orchestration
├── scripts/                # Investigation tools
│   ├── analyze_document.sh  # Document analysis script
│   ├── safe_view.sh        # Safe document viewer
│   ├── investigate_url.sh  # URL investigation script
│   └── start.sh            # Container startup script
├── investigations/         # Analysis results (created at runtime)
└── README.md              # This file
```

## Container Layout

```
/home/investigator/
├── downloads/              # Read-only mount from ~/phishing/Downloads
├── investigations/         # Analysis results and reports
└── tools/                 # Investigation scripts
```

## Installed Tools

### CLI Analysis Tools
- `exiftool` - Metadata extraction
- `binwalk` - Embedded file analysis
- `strings` - String extraction
- `file` - File type identification
- `xxd` - Hex dump utility
- `yara` - Pattern matching
- `oletools` - Office document analysis
- `pdfgrep` - PDF text search
- `poppler-utils` - PDF utilities

### GUI Applications
- **Gedit** - Text editor
- **Lynx** - Text-based web browser (secure for URL investigation)

### Python Libraries
- `oletools` - Office document analysis
- `python-magic` - File type detection
- `pdfplumber` - PDF text extraction
- `openpyxl` - Excel file handling
- `python-docx` - Word document handling

## Testing

### Test Document Analysis
1. Place a test document in `~/phishing/Downloads/`
2. Run analysis: `./tools/analyze_document.sh ~/downloads/test.pdf`
3. Check results in `~/investigations/`

### Test GUI Applications
1. Start file manager: `pcmanfm &`
2. Open LibreOffice: `libreoffice &`
3. Test Firefox: `firefox google.com &`

### Test URL Investigation
```bash
# Test with a safe URL
./tools/investigate_url.sh "https://google.com"

# Browse safely with text browser
lynx google.com
```

## Troubleshooting

### GUI Applications Not Working
- Ensure X11 server is running
- Check X11 permissions: `xhost +local:docker`
- Verify DISPLAY variable is set correctly

### Permission Issues
- Ensure your user ID is 1000: `id -u`
- If not, modify the docker-compose.yml user setting

### Container Won't Start
- Check Docker daemon is running
- Verify docker-compose.yml syntax
- Check available disk space

## Advanced Usage

### Custom Analysis Scripts
Create custom scripts in the `scripts/` directory and rebuild the container:

```bash
# Add your script to scripts/
# Rebuild container
docker-compose build --no-cache
```

### Persistent Data
Investigation results are saved to `./investigations/` on the host system for persistence across container restarts.

### Network Analysis
For network traffic analysis, additional tools like Wireshark are available:

```bash
# Start Wireshark (requires additional setup for packet capture)
wireshark &
```

### Switching Between GUI and CLI Modes

The container defaults to GUI mode with RDP access. To use CLI mode:

```bash
# Start in CLI mode (requires X11 setup on host)
docker compose run --rm investigation-container /home/investigator/tools/start.sh

# Or modify docker-compose.yml to change the default command
```

For CLI mode, you'll also need to update the docker-compose.yml volumes to include X11:

```yaml
volumes:
  - /tmp/.X11-unix:/tmp/.X11-unix:rw
  - ${HOME}/phishing/Downloads:/home/investigator/downloads:ro
  - ./investigations:/home/investigator/investigations:rw
environment:
  - DISPLAY=${DISPLAY}
```

## Security Considerations

- **Never run as root**: Always use the provided non-root user
- **Verify downloads**: Only analyze files from trusted sources when possible
- **Network isolation**: Consider running without network access for sensitive analysis
- **Regular updates**: Keep container images updated with security patches

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add your improvements
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
