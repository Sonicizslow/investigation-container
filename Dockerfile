# Investigation Container for Document Analysis
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install essential packages
RUN apt-get update && apt-get install -y \
    # Basic utilities
    curl \
    wget \
    unzip \
    git \
    vim \
    nano \
    tree \
    file \
    # Python and analysis libraries
    python3 \
    python3-pip \
    # Desktop environment and RDP server
    xfce4 \
    xfce4-goodies \
    xrdp \
    # Web browser
    firefox \
    lynx \
    # Text editor and file manager
    gedit \
    thunar \
    # Document viewers
    evince \
    libreoffice \
    # Network tools
    net-tools \
    # GUI support
    x11-apps \
    # Python GUI libraries
    python3-tk \
    # Analysis tools
    exiftool \
    xxd \
    poppler-utils \
    # Archive and security tools
    unrar \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for document analysis (with fallback for SSL issues)
RUN pip3 install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org \
    openpyxl \
    python-docx \
    pdfplumber \
    python-magic \
    oletools \
    binwalk \
    yara-python \
    || pip3 install openpyxl python-docx || true

# Configure xrdp for Docker environment
RUN sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini \
    && sed -i 's/max_bpp=32/#max_bpp=32\nmax_bpp=128/g' /etc/xrdp/xrdp.ini \
    && sed -i 's/xserverbpp=24/#xserverbpp=24\nxserverbpp=128/g' /etc/xrdp/xrdp.ini \
    && echo "xfce4-session" > /etc/skel/.xsession

# Create investigator user and set password for RDP access
RUN useradd -m -s /bin/bash investigator && \
    usermod -aG sudo investigator && \
    echo "investigator:investigate2024" | chpasswd \
    && echo "xfce4-session" > /home/investigator/.xsession \
    && mkdir -p /var/run/xrdp \
    && chown investigator:investigator /home/investigator/.xsession

# Create directories for investigations with proper ownership
RUN mkdir -p /home/investigator/investigations && \
    mkdir -p /home/investigator/tools && \
    chown -R investigator:investigator /home/investigator

# Copy investigation scripts
COPY scripts/ /home/investigator/tools/
RUN chown -R investigator:investigator /home/investigator/tools && \
    chmod +x /home/investigator/tools/*.sh && \
    chmod +x /home/investigator/tools/*.py

# Set up environment for the investigator user
USER investigator
WORKDIR /home/investigator

# Expose RDP port
EXPOSE 3389

# Set display for GUI applications
ENV DISPLAY=:1

# Default command starts the RDP investigation environment
CMD ["/home/investigator/tools/start_rdp.sh"]