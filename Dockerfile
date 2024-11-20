# Start from the official Ubuntu 24.04 image
FROM ubuntu:24.04
LABEL maintainer="Jakub Zasański <jakub.zasanski.dev@gmail.com>"

# Define the build-time arguments for Git configuration
ARG GIT_USER_EMAIL
ARG GIT_USER_NAME

# Non-interactive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set locale to POSIX for consistent behavior across environments
ENV LC_ALL=C
ENV CPU_SSE42=false
ENV WITH_DEXPREOPT=false

# Define the default user and group
ENV USERNAME=user
ENV UID=1000
ENV GID=1000

# Define important paths
ENV USER_DIR=/home/$USERNAME
ENV MOUNT_DIR=$USER_DIR/workdir
ENV SOURCE_DIR=$MOUNT_DIR/source

# Configure ccache for build caching
ENV USE_CCACHE=1
ENV CCACHE_COMPRESS=1
ENV CCACHE_SIZE=100G
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=$MOUNT_DIR/ccache

# Update the package list and install essential build dependencies
# `apt-get clean` ensures no unnecessary files remain, reducing image size
RUN apt-get update && apt-get install -y \
    android-sdk-platform-tools-common \ # Tools for Android development
    android-tools-adb \                # ADB (Android Debug Bridge) tool
    android-tools-fastboot \           # Fastboot tool for Android
    bash \                             # Essential shell
    bc \                               # Basic calculator for scripts
    bison \                            # Parser generator
    bsdmainutils \                     # Common BSD utilities
    build-essential \                  # Compilation tools
    ccache \                           # Compiler cache for speeding up builds
    curl \                             # Command-line tool for transferring data
    fakeroot \                         # Tool for creating file archives
    flex \                             # Lexical analyzer generator
    g++-multilib \                     # 32-bit and 64-bit GCC support
    gcc-multilib \                     # GCC with multilib support
    git \                              # Version control system
    git-lfs \                          # Git Large File Storage
    gnupg \                            # Encryption utility for signing keys
    gperf \                            # Hash function generator
    imagemagick \                      # Image manipulation tools
    lib32readline-dev \                # 32-bit readline library
    lib32z1-dev \                      # 32-bit zlib compression library
    libelf-dev \                       # ELF object file support
    liblz4-tool \                      # LZ4 compression tool
    libsdl1.2-dev \                    # SDL library for development
    libssl-dev \                       # OpenSSL development libraries
    libxml2 \                          # XML parsing library
    libxml2-utils \                    # XML utilities
    lzop \                             # Lempel-Ziv-Oberhumer compression tool
    nano \                             # Simple text editor
    openssh-client \                   # SSH client tools
    pngcrush \                         # PNG optimization tool
    python3 \                          # Python 3 interpreter
    rsync \                            # File synchronization tool
    schedtool \                        # Scheduling priority tool
    squashfs-tools \                   # Tool for creating SquashFS filesystems
    sudo \                             # Superuser access management
    unzip \                            # Tool for extracting ZIP archives
    xsltproc \                         # XSLT processor
    zip \                              # ZIP compression tool
    zlib1g-dev \                       # Zlib compression library development files
    && apt-get clean                   # Remove temporary package files

# Download the 'repo' binary (used for Android source code management) and make it executable
RUN curl -s https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo \
    && chmod a+x /usr/bin/repo

# Create a new user with specified UID and GID
RUN groupadd --gid $GID --force $USERNAME \
    && useradd --uid $UID --gid $GID --non-unique --create-home $USERNAME

# Switch to the new user
USER $USERNAME

# Configure Git using build-time arguments for user email and name
RUN git config --global user.email "$GIT_USER_EMAIL" \
    && git config --global user.name "$GIT_USER_NAME" \
    && git lfs install \                      # Initialize Git LFS
    && git config --global trailer.changeid.key "Change-Id"  # Configure Git trailers

# Create directories for source code and ccache, setting appropriate permissions
RUN mkdir -p "$SOURCE_DIR" \
    && chmod -R ug+s "$SOURCE_DIR" \
    && mkdir -p "$CCACHE_DIR" \
    && chmod -R ug+s "$CCACHE_DIR"

# Set the default working directory
WORKDIR $SOURCE_DIR

# Set the default command to keep the container running
CMD ["/bin/bash", "-c", "sleep infinity"]
