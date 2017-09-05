FROM ruby:2.4.1

RUN printf "deb http://deb.debian.org/debian testing main\ndeb http://deb.debian.org/debian testing-updates main\ndeb http://security.debian.org testing/updates main" >> /etc/apt/sources.list
RUN apt-get update && \
    apt-get install --yes --no-install-recommends apt-transport-https=1.0.* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN echo 'deb https://deb.nodesource.com/node_6.x jessie main' > /etc/apt/sources.list.d/nodesource.list && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    apt-get update && \
    apt-get install --yes --target-release=jessie --no-install-recommends python-pip python-yaml locales nodejs=6.* build-essential \
            advancecomp optipng pngquant jhead jpegoptim gifsicle && \
    apt-get install --yes --target-release=testing --no-install-recommends git python-sphinx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN gem update --no-document --system
RUN npm install -g conventional-changelog-cli

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen
ENV LC_ALL en_US.UTF-8

ENV APP_HOME /app
RUN mkdir "$APP_HOME"

RUN gem install bundler
RUN pip install yamllint
RUN npm install -g jsl jshint eslint svgo eslint-config-jquery

WORKDIR $APP_HOME
COPY package.json $APP_HOME/
COPY Gemfile* $APP_HOME/

RUN npm install
RUN bundle install -j 4

CMD jekyll s -H 0.0.0.0
