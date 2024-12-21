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

# Define important paths
ENV USER_DIR=/home/ubuntu
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
    android-sdk-platform-tools-common \
    android-tools-adb \
    android-tools-fastboot \
    bash \
    bc \
    bison \
    bsdmainutils \
    build-essential \
    ccache \
    curl \
    fakeroot \
    flex \
    g++-multilib \
    gcc-multilib \
    git \
    git-lfs \
    gnupg \
    gperf \
    imagemagick \
    lib32readline-dev \
    lib32z1-dev \
    libelf-dev \
    liblz4-tool \
    libsdl1.2-dev \
    libssl-dev \
    libxml2 \
    libxml2-utils \
    lzop \
    nano \
    openssh-client \
    pngcrush \
    python3 \
    rsync \
    schedtool \
    squashfs-tools \
    sudo \
    unzip \
    xsltproc \
    zip \
    zlib1g-dev \
    && apt-get clean

# Download the 'repo' binary (used for Android source code management) and make it executable
RUN curl -s https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo \
    && chmod a+x /usr/bin/repo

# Switch to the new user
USER ubuntu

# Create the .ssh directory
RUN mkdir -p /home/ubuntu/.ssh

# Copy the .ssh directory
COPY .ssh /home/ubuntu/.ssh

# Create directories for source code and ccache
RUN mkdir -p "$SOURCE_DIR" \
    && mkdir -p "$CCACHE_DIR"

# Configure Git
RUN git config --global user.email "$GIT_USER_EMAIL"  \
    && git config --global user.name "$GIT_USER_NAME"  \
    && git lfs install  \
    && git config --global trailer.changeid.key "Change-Id"

# Set the default working directory
WORKDIR $SOURCE_DIR

# Set the default command to keep the container running
CMD ["/bin/bash", "-c", "sleep infinity"]
