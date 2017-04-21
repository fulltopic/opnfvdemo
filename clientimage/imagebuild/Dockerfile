FROM sitespeedio/webbrowsers

COPY charon-cmd /root
COPY server-root-ca.pem /root
COPY vpnconn.sh /root

RUN apt-get update \
	&& apt-get install -y net-tools iputils-ping strongswan charon-cmd strongswan-plugin-eap-mschapv2 \
	&& mkdir -p /root/certs \
	&& mv /root/server-root-ca.pem /root/certs \
	&& mv /root/charon-cmd /usr/sbin \
	&& chmod +x /root/vpnconn.sh \
	&& adduser --disabled-password --gecos "" test

USER root

CMD ["bin/bash"]
