FROM debian:stable
MAINTAINER Florian Reck
RUN apt-get -qy update
RUN apt-get -qy install gnupg gnupg2 curl apt-transport-https git-core
RUN apt-get -qy install software-properties-common apt-transport-https
RUN set ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
RUN curl --silent https://packages.grafana.com/gpg.key | apt-key add -
RUN add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
RUN apt-get -qy update
RUN apt-get install -y selinux-utils policycoreutils locales
ENV TERM=xterm
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN apt-get install -y apt apt-utils aptitude unattended-upgrades zsh vim wget busybox-syslogd less man-db manpages dialog bash-completion python3-pip python3-pyodbc python3-dev libcairo2-dev libffi-dev build-essential uwsgi uwsgi-plugin-python lighttpd grafana 
RUN apt-get -qy clean


# Connector stuff
RUN python3 -m pip install ExasolDatabaseConnector
RUN pip3 install --upgrade pip
RUN PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" python3 -m pip install --quiet git+https://github.com/graphite-project/whisper
RUN PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" python3 -m pip install --quiet git+https://github.com/graphite-project/carbon
RUN PYTHONPATH="/opt/graphite/lib/:/opt/graphite/webapp/" python3 -m pip install --quiet git+https://github.com/graphite-project/graphite-web
RUN mkdir -p /etc/grafana/cert
ADD usr/local/bin/generate-certificate /usr/local/bin/generate-certificate
ADD etc/uwsgi/apps-available /etc/uwsgi/apps-available

RUN sed -i 's/;cert_file =/cert_file = \/etc\/grafana\/cert\/server.pem/g' /etc/grafana/grafana.ini
RUN sed -i 's/;cert_key =/cert_key = \/etc\/grafana\/cert\/server.priv/g' /etc/grafana/grafana.ini

#make things easier, can be removed for production
#RUN bash -c 'wget -O /tmp/.zshrc http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc && cp -v /tmp/.zshrc /etc/zsh/zshrc'
#RUN chsh -s /usr/bin/zsh root
#RUN bash -c 'base64 -di <<< "H4sIALetz1gCA22QTW7EIAxG95yCzqrdzEhVl02XvYcDJrEENgIzM7l9E5Jp1aoLxPee+TGUxkoJn6zHkYDPV0omUERdMlrhn5xjm4h/KWKPrJuqCyvce0K1dZabS/47J1A375SgqIOKnYhdRShHTWGsKnl4O/ZR0Bt5nR9Cgv5Zsh22qg54z8D+QdBU9u46ZqiKKtMUcXj/fP3oMkmrOOxX63KQkyilWoxhnb2hYLfXFgQPY8Tn0wXVXdY/2kZx5ygO4unF2LW9Vhza/+oG2VMwX48OyfBqAQAA" |gzip -dc >/etc/vim/vimrc'

WORKDIR /root
ENTRYPOINT bash -c "generate-certificate; while true; do sleep 30; done;"
