# steamcmd/steamcmd:latest is based on ubuntu
FROM steamcmd/steamcmd:latest

# Build argument for Steam app ID (defaults to stable Arma Reforger Server)
ARG STEAM_APP_ID=1874900
ARG BRANCH=stable
ARG VERSION=1.0.0

LABEL de.grad.arsa.appid=${STEAM_APP_ID}
LABEL de.grad.arsa.branch=${BRANCH}
LABEL de.grad.arsa.version=${VERSION}

# set 'root' as current user
USER root

# install Arma Reforger Server with steamcmd to /ars
# The files stay owned by root: they are world readable and executable, and the server only writes
# to -profile, -addonDownloadDir and /tmp. A 'chown -R' would copy the whole install into another layer.
RUN steamcmd +force_install_dir /ars +login anonymous +@sSteamCmdForcePlatformType linux +app_update ${STEAM_APP_ID} validate +quit

# Run as the unprivileged user 'ubuntu' (1000). arsa-backend also runs as 1000 and owns the mounted
# config, profile and addon directories. The base image sets HOME=/root, which 1000 can't write to.
USER 1000:1000
ENV HOME=/home/ubuntu USER=ubuntu

# set working directory
WORKDIR "/ars"

ENTRYPOINT ["./ArmaReforgerServer"]
