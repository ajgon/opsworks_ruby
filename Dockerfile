FROM ruby:2.5

RUN printf "deb http://deb.debian.org/debian testing main\ndeb http://deb.debian.org/debian testing-updates main" >> /etc/apt/sources.list
RUN apt-get update && \
    apt-get install --yes --no-install-recommends apt-transport-https && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN echo 'deb https://deb.nodesource.com/node_6.x jessie main' > /etc/apt/sources.list.d/nodesource.list && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    apt-get update && \
    apt-get install --yes --target-release=jessie --no-install-recommends git locales nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN gem update --no-document --system

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen
ENV LC_ALL en_US.UTF-8

ENV APP_HOME /app
RUN mkdir "$APP_HOME"

RUN gem install bundler
RUN npm install -g jsl jshint eslint svgo eslint-config-jquery

WORKDIR $APP_HOME

COPY package.json $APP_HOME/
RUN npm install

COPY Gemfile* $APP_HOME/
RUN bundle install -j 4

CMD jekyll s -H 0.0.0.0
