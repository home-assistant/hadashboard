FROM ruby:2.2.5
MAINTAINER Marijn Giesen <marijn@studio-donder.nl>

RUN apt-get update \
 && apt-get install -y \
      postgresql-9.4 \
      postgresql-server-dev-9.4 \
      sqlite \
      nodejs \
      libpq-dev \
      libssl-dev \
      libsqlite3-dev \
      ruby-dev \
      python3 \
      python3-pip \
 && mkdir /app \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN gem install dashing \
 && gem install bundler \
 && bundle \
 && pip3 install daemonize sseclient configobj \
 && pip3 install --upgrade requests


EXPOSE 3030

VOLUME /app/lib /app/dashboards /app/hapush

CMD dashing start
