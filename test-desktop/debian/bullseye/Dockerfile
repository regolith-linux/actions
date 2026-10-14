FROM debian:bullseye
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's|deb\.debian\.org/debian-security|archive\.debian\.org/debian-security|' /etc/apt/sources.list
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata wget sudo gnupg keyboard-configuration
ENTRYPOINT ["/entrypoint.sh"]
