FROM debian:jessie
MAINTAINER Adrian Dvergsdal [atmoz.net]

RUN apt-get -qq update && apt-get -qq -y install openssh-server && apt-get -qq -y clean
RUN rm -rf /var/lib/apt/lists/*

# Step 1: sshd needs /var/run/sshd/ to run
# Step 2: Remove keys, they will be generated later by entrypoint
#         (unique keys for each container)
RUN mkdir -p /var/run/sshd && \
    rm /etc/ssh/ssh_host_*key*

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /
COPY README.md /

ENTRYPOINT ["entrypoint.sh"]
VOLUME /etc/ssh

EXPOSE 22


