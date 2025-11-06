FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client \
  vim \
  git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENV BUNDLE_PATH=/usr/local/bundle

CMD ["/bin/bash"]
