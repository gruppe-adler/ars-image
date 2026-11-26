# steamcmd/steamcmd:latest is based on ubuntu. Pinned by digest so a new steamcmd version can't break the
# build unnoticed; bump it on purpose with: docker buildx imagetools inspect steamcmd/steamcmd:latest
FROM steamcmd/steamcmd:latest@sha256:7d9bef424526d66b3f3aa5290f701e4ebea725f47c2320f107905a88f9293c37

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
# steamcmd randomly fails with "ERROR! Failed to install app (Missing configuration)", exit code 8, so retry.
# A failed attempt leaves nothing behind that breaks the next one, and 'validate' resumes a partial download.
RUN for attempt in 1 2 3 4 5 6 7 8 9 10; do \
      steamcmd +force_install_dir /ars +login anonymous +@sSteamCmdForcePlatformType linux +app_update ${STEAM_APP_ID} validate +quit && exit 0; \
      echo "steamcmd failed (attempt ${attempt}/10)"; \
      [ "${attempt}" -lt 10 ] && sleep $((attempt * 15)); \
    done; \
    exit 1

# Run as the unprivileged user 'ubuntu' (1000). arsa-backend also runs as 1000 and owns the mounted
# config, profile and addon directories. The base image sets HOME=/root, which 1000 can't write to.
USER 1000:1000
ENV HOME=/home/ubuntu USER=ubuntu

# set working directory
WORKDIR "/ars"

ENTRYPOINT ["./ArmaReforgerServer"]
