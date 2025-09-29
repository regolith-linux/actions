FROM ubuntu:23.10
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's|archive\.ubuntu\.com/ubuntu|old-releases\.ubuntu\.com/ubuntu|' /etc/apt/*.list
RUN sed -i 's|security\.ubuntu\.com/ubuntu|old-releases\.ubuntu\.com/ubuntu|' /etc/apt/*.list
RUN sed -i 's|ports\.ubuntu\.com/ubuntu-ports|old-releases\.ubuntu\.com/ubuntu|' /etc/apt/*.list
RUN apt update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata wget sudo gnupg keyboard-configuration
ENTRYPOINT ["/entrypoint.sh"]
