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
    # GUI support for basic functionality
    firefox \
    gedit \
    # Minimal desktop components
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for document analysis (with fallback for SSL issues)
RUN pip3 install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org \
    openpyxl \
    || pip3 install openpyxl || true

# Create a non-root user for security
RUN useradd -m -s /bin/bash investigator && \
    usermod -aG sudo investigator

# Create directories for investigations
RUN mkdir -p /home/investigator/investigations && \
    mkdir -p /home/investigator/tools && \
    chown -R investigator:investigator /home/investigator

# Copy investigation scripts
COPY scripts/ /home/investigator/tools/
RUN chown -R investigator:investigator /home/investigator/tools && \
    chmod +x /home/investigator/tools/*.sh

# Set up environment for the investigator user
USER investigator
WORKDIR /home/investigator

# Set display for GUI applications
ENV DISPLAY=:0

# Default command starts the investigation environment
CMD ["/home/investigator/tools/start.sh"]