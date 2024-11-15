# Start from the official Ubuntu 24.04 image
FROM ubuntu:24.04
LABEL maintainer="Jakub Zasański <jakub.zasanski.dev@gmail.com>"

# Define the build-time arguments that can be passed from docker-compose.yml or during docker build
ARG GIT_USER_EMAIL
ARG GIT_USER_NAME

# Disables interactive prompts (used for non-interactive mode in Docker builds)
ENV DEBIAN_FRONTEND=noninteractive

# Set the locale to POSIX
ENV LC_ALL=C

# Enables ccache for faster compilation
ENV USE_CCACHE=1

# Sets the maximum cache size to 100GB
ENV CCACHE_SIZE=100G

# Specifies the path to the ccache binary
ENV CCACHE_EXEC=/usr/bin/ccache

# Defines the default user for the container
ENV USER=user

# Sets the user's home directory
ENV USER_DIR=/home/$USER

# Update the package list and install essential packages
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
    python-is-python3 \
    rsync \
    schedtool \
    squashfs-tools \
    sudo \
    unzip \
    xsltproc \
    zip \
    zlib1g-dev \
    && apt-get clean  # Updates the package list, installs dependencies, and then cleans up to reduce image size

# Disable some gpg options which can cause problems in IPv4 only environments
RUN mkdir ~/.gnupg && chmod 600 ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# Download the 'repo' binary, which is used for managing Android source code repositories, and make it executable
RUN curl -s https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo && chmod a+x /usr/bin/repo

# Add a new user and group named 'user' with appropriate permissions
RUN groupadd $USER && useradd -g $USER -m -s /bin/bash $USER && usermod -u 1001 $USER

# Allow the default user to run sudo commands without a password
RUN echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers

# Create the user's home directory and set proper ownership
RUN mkdir -p "$USER_DIR" && chown "$USER:$USER" "$USER_DIR" && chmod ug+s $USER_DIR

# Switch to the created user for further commands
USER $USER

# Configure Git with the user's email and name (provided as build-time arguments)
RUN git config --global user.email "$GIT_USER_EMAIL" && git config --global user.name "$GIT_USER_NAME" && git lfs install && git config --global trailer.changeid.key "Change-Id"

# Create android dir
RUN mkdir -p "$USER_DIR/android" && chown "$USER:$USER" "$USER_DIR/android" && chmod ug+s $USER_DIR/android

# Set the default working directory for the container
WORKDIR $USER_DIR/android

# Set the default command to run an infinite sleep to keep the container running
CMD ["/bin/bash", "-c", "sleep infinity"]
