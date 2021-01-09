FROM php:7-fpm
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y openvpn nginx nodejs unzip git wget sed curl net-tools iptables mariadb-client zip libzip-dev \
  && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-install pdo_mysql 
RUN npm install -g bower

ADD nginx.conf /etc/nginx/sites-available/default
ADD . /opt/openvpn-admin/
WORKDIR /opt/openvpn-admin/
RUN cp -r index.php sql bower.json .bowerrc js include css installation/client-conf "/var/www/html"
WORKDIR /var/www/html
RUN bower --allow-root install

WORKDIR /opt/openvpn-admin
VOLUME [ "/etc/openvpn" ]
RUN chmod +x entrypoint.sh
EXPOSE 80 443
ENTRYPOINT [ "/opt/openvpn-admin/entrypoint.sh" ]