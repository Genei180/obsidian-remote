FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

LABEL maintainer="github@sytone.com" \
      org.opencontainers.image.authors="github@sytone.com" \
      org.opencontainers.image.source="https://github.com/sytone/obsidian-remote" \
      org.opencontainers.image.title="Container hosted Obsidian MD" \
      org.opencontainers.image.description="Hosted Obsidian instance allowing access via web browser"

# Get Architekture
ARG BUILDARCH

# Update and install extra packages.
RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends curl libgtk-3-0 libnotify4 libatspi2.0-0 libsecret-1-0 libnss3 desktop-file-utils fonts-noto-color-emoji git ssh-askpass && \
    if [ $BUILDARCH = "arm64" ]; then \
        # Dependecies specific for Arm64
        # Workaorund for AppImage Bug! Remove when Issue Closed: https://github.com/AppImage/AppImageKit/issues/964
        apt-get install -y --no-install-recommends zlib1g-dev; \
    fi; \
    apt-get autoclean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*


# Set version label
ARG OBSIDIAN_VERSION=1.5.3

ARG DOWNLOAD_URL_BASE="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}"
# Download and install Obsidian
RUN echo "**** Downloading Obsidian for "$BUILDARCH" ****" && \
    if [ $BUILDARCH = "arm64" ]; then \
        DOWNLOAD_URL_BASE="${DOWNLOAD_URL_BASE}-arm64"; \
    fi; \
    DOWNLOAD_URL_BASE=${DOWNLOAD_URL_BASE}".AppImage" && \
    echo "Downloading from: "${DOWNLOAD_URL_BASE} && \
    curl --location --fail --output obsidian.AppImage $DOWNLOAD_URL_BASE

#ADD ${DOWNLOAD_URL_BASE}".AppImage" /

RUN echo "**** Extracting App ****" && \
    echo $(ls -l obsidian.AppImage) && \
    chmod +x obsidian.AppImage && \
    ./obsidian.AppImage --appimage-extract

# Environment variables
ENV CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8443" \
    CUSTOM_USER="" \
    PASSWORD="" \
    SUBFOLDER="" \
    TITLE="Obsidian v${OBSIDIAN_VERSION}" \
    FM_HOME="/vaults"

# Add local files
COPY root/ /
EXPOSE 8080 8443
VOLUME ["/config","/vaults"]

# Define a healthcheck
HEALTHCHECK CMD curl --fail http://localhost:8080/ || exit 1
