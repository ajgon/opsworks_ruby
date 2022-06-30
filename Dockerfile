FROM ruby:2.7-bullseye

RUN printf "deb http://deb.debian.org/debian testing main\ndeb http://deb.debian.org/debian testing-updates main" >> /etc/apt/sources.list
RUN apt-get update && \
    apt-get remove --purge --yes python2 python3 && \
    apt-get autoremove --purge --yes && \
    apt-get install --yes --no-install-recommends apt-transport-https build-essential git locales python3 python3-pip python3-setuptools python3-yaml && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.* 0
RUN echo 'deb https://deb.nodesource.com/node_14.x buster main' > /etc/apt/sources.list.d/nodesource.list && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    apt-get update && \
    apt-get install --yes --target-release=buster --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN gem update --no-document --system
RUN npm install -g conventional-changelog-cli
RUN pip3 install mike mkdocs-material yamllint

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen
ENV LC_ALL en_US.UTF-8

ENV CHEF_LICENSE=accept
RUN echo 'deb [trusted=yes] https://packages.chef.io/repos/apt/stable bionic main' > /etc/apt/sources.list.d/chefdk.list && \
    curl -s https://packages.chef.io/chef.asc | apt-key add - && \
    apt-get update && \
    apt-get install --yes chefdk

ENV APP_HOME /cookbooks/opsworks_ruby
RUN mkdir -p "$APP_HOME"

COPY Gemfile* $APP_HOME/
WORKDIR $APP_HOME

RUN chef exec bundle install -j 4

COPY package.json $APP_HOME/
RUN npm install

COPY .chef.login $APP_HOME/
RUN mkdir -p /root/.chef
RUN printf "client_key \"/cookbooks/opsworks_ruby/client.pem\"\n" >> /root/.chef/knife.rb
RUN printf "node_name \"$(cat /cookbooks/opsworks_ruby/.chef.login)\"\n" >> /root/.chef/knife.rb
RUN printf "cookbook_path \"/cookbooks\"\n" >> /root/.chef/knife.rb

COPY README.md $APP_HOME/
COPY metadata.rb $APP_HOME/
COPY Berksfile* $APP_HOME/

RUN chef exec berks
