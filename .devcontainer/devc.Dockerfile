# Generic development container base image
# Provides essential dev tools without stack-specific dependencies
# Stack-specific repos should extend this with their own tools

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install essential development tools
# These are generally useful across different stacks
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    bash \
    bash-completion \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    # Version control
    git \
    # Build tools
    build-essential \
    make \
    # Text processing & search
    ripgrep \
    fd-find \
    jq \
    # File utilities
    tree \
    file \
    # Process utilities
    procps \
    psmisc \
    # Network utilities  
    net-tools \
    iputils-ping \
    # Editors (minimal)
    vim \
    nano \
    # Compression
    zip \
    unzip \
    # Other utilities
    less \
    man-db \
    && rm -rf /var/lib/apt/lists/*

# Copy and execute tooling installation scripts
# This ensures toolings are installed during image build, not at runtime
COPY .devcontainer/install-toolings.sh /tmp/install-toolings.sh
COPY tooling /tmp/tooling
RUN chmod +x /tmp/install-toolings.sh && \
    TOOLING_DIR=/tmp/tooling bash /tmp/install-toolings.sh && \
    rm -rf /tmp/install-toolings.sh /tmp/tooling

# Set up workspace directory
WORKDIR /workspace

# Create a non-root user for development (optional, can be overridden)
# Uncomment if you want a default dev user:
# ARG USERNAME=devuser
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID
# RUN groupadd --gid $USER_GID $USERNAME \
#     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
#     && apt-get update \
#     && apt-get install -y sudo \
#     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME
# USER $USERNAME

WORKDIR /workspace

CMD ["bash"]