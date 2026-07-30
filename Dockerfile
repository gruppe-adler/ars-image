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
RUN steamcmd +force_install_dir /ars +login anonymous +@sSteamCmdForcePlatformType linux +app_update ${STEAM_APP_ID} validate +quit

# change owner of /ars to ubuntu user and group to allow executing it
RUN chown -R ubuntu:ubuntu /ars

# create group 'arsa'(gid 1337) and add user 'ubuntu' to that group to allow accessing config and profile
RUN groupadd --gid 1337 arsa && usermod -a -G arsa ubuntu

# switch to unprivileged user 'ubuntu'
USER ubuntu

# set working directory
WORKDIR "/ars"

EXPOSE 2001/tcp
EXPOSE 17777/tcp
EXPOSE 19999/tcp

ENTRYPOINT ["./ArmaReforgerServer"]
