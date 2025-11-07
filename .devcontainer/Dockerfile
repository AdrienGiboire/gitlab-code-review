FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
  nodejs \
  postgresql-client \
  vim \
  git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENV BUNDLE_PATH=/usr/local/bundle

# Set up aliases for the user
RUN echo "alias l='ls -AFglh --color'" >> ~/.bashrc && \
    echo "alias be='bundle exec'" >> ~/.bashrc && \
    echo "alias r='RUBY_YJIT_ENABLE=1 RAILS_ENV=development bin/rails'" >> ~/.bashrc && \
    echo "alias s='r s -b 0.0.0.0'" >> ~/.bashrc

CMD ["/bin/bash"]
