FROM mariadb

ARG BUILD_DATE
ARG VCS_REF
ARG NODE_VERSION=8

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/DeloitteDigitalAPAC/docker-drupal-builder" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0"

# Add deloitte user & group.
RUN groupadd deloitte; \
    useradd -g deloitte -md /home/deloitte -s /bin/bash deloitte

# Install PHP & chrome.
RUN set -ex; \
    apt-get update; \
    apt-get install -y software-properties-common; \
    apt-get install -y curl; \
    add-apt-repository ppa:ondrej/php; \
    curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -; \
    add-apt-repository "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"; \
    apt-get update; \
    apt-get install -y git google-chrome-stable \
      php7.1-bz2 php7.1-cli php7.1-curl php7.1-dom php7.1-gd php7.1-mbstring php7.1-mysql php7.1-zip \
      unzip; \
    rm -rf /var/lib/apt/lists/*; \
    LATEST_RELEASE=`curl https://chromedriver.storage.googleapis.com/LATEST_RELEASE`; \
    curl -L https://chromedriver.storage.googleapis.com/${LATEST_RELEASE}/chromedriver_linux64.zip -o /tmp/chromedriver_linux64.zip; \
    unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin;

# Install composer.
RUN set -ex; \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
    rm composer-setup.php; \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /etc/profile; \
    gosu deloitte bash -c 'composer global require hirak/prestissimo && composer clear-cache';

# Install nvm.
RUN set -ex; \
    gosu deloitte bash -c 'curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash'; \
    echo 'export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"\n\
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"\n'\
>> /home/deloitte/.profile;

COPY deloitte-entrypoint.sh /usr/local/bin/

# Run our entrypoint, from which we call mariadb's.
ENTRYPOINT ["/usr/local/bin/deloitte-entrypoint.sh"]
