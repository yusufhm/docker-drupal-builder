FROM mariadb

ARG BUILD_DATE
ARG VCS_REF
ARG NODE_VERSION=8

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://bitbucket.org/yusufhm/reins" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="0.1.0"

# Add deloitte user & group.
RUN groupadd deloitte; \
    useradd -g deloitte -md /home/deloitte -s /bin/bash deloitte

# Install PHP.
RUN apt-get update && \
    apt-get install -y curl git php7.2-cli php7.2-curl php7.2-zip unzip

# Install composer.
RUN set -ex; \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
    rm composer-setup.php; \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /etc/profile; \
    gosu deloitte bash -c 'composer global require hirak/prestissimo';

# Install nvm.
RUN set -ex; \
    gosu deloitte bash -c 'curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash';