FROM ubuntu:26.04
LABEL maintainer="Jesus Palencia sinfallas@gmail.com"
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app
RUN apt update && apt -y dist-upgrade && apt -y install --no-install-recommends --no-install-suggests less groff ansible jq ca-certificates gnupg software-properties-common tzdata git tar zip unzip s3fs ssh sshpass sshfs samba-client swaks nano wget curl rsync expect iputils-ping python3-pip && apt clean && apt -y autoremove && rm -rf /var/lib/{apt,dpkg,cache,log} && rm -rf /var/cache/* && rm -rf /var/log/apt/* && rm -rf /tmp/*
# awscli install
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "/root/awscliv2.zip" && unzip /root/awscliv2.zip -d /root && /root/aws/install && rm -f /root/awscliv2.zip && rm -rf /root/aws
# google cloud cli
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
RUN apt update && apt -y install --no-install-recommends --no-install-suggests google-cloud-cli && touch ~/.bashrc && apt clean && apt -y autoremove && rm -rf /var/lib/{apt,dpkg,cache,log} && rm -rf /var/cache/* && rm -rf /var/log/apt/* && rm -rf /tmp/*
# semaphore install
RUN ARCH=$(dpkg --print-architecture) && LATEST_VERSION=$(curl -s https://api.github.com/repos/semaphoreui/semaphore/releases/latest | jq -r .tag_name | sed 's/^v//') && wget --tries=20 --waitretry=5 --read-timeout=45 -P /tmp "https://github.com/semaphoreui/semaphore/releases/download/v${LATEST_VERSION}/semaphore_${LATEST_VERSION}_linux_${ARCH}.deb" && apt -y install "/tmp/semaphore_${LATEST_VERSION}_linux_${ARCH}.deb" && rm -f "/tmp/semaphore_${LATEST_VERSION}_linux_${ARCH}.deb" && apt clean && apt -y autoremove && rm -rf /var/lib/{apt,dpkg,cache,log} && rm -rf /var/cache/* && rm -rf /var/log/apt/* && rm -rf /tmp/*
# opentofu
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
RUN chmod +x install-opentofu.sh && ./install-opentofu.sh --install-method standalone && rm -f install-opentofu.sh
RUN tofu -install-autocomplete
# misc
COPY config.json /etc/semaphore/config.json
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY configuraraws /usr/bin/configuraraws
RUN chmod +x /usr/bin/configuraraws
RUN mkdir -p /etc/semaphore
RUN chmod +x /usr/bin/entrypoint.sh
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 CMD curl --silent --fail http://localhost:3000/api/ping || exit 1
EXPOSE 3000
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
