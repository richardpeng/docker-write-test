FROM ruby:2.5.8-buster
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -\
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list\
    && apt-get update \
        && apt-get install -qq -y --fix-missing --no-install-recommends \
        build-essential \
        git \
        less \
        libmagic-dev \
        libpq-dev \
        mariadb-client-10.3 \
        nodejs \
        nvi \
        time \
        zstd \
        yarn

ENV APP_HOME /ripper
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

RUN groupadd -g 1000 app \
    && useradd -u 1000 -g app -d $APP_HOME app

# Set up Bundler and application tree
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/bundle \
    GEM_HOME=/bundle \
    NODE_HOME=$APP_HOME/node_modules
ENV PATH=$GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

COPY Gemfile* package.json yarn.lock* $APP_HOME/

RUN mkdir -p $GEM_HOME && bundle install && chown -R app:app $GEM_HOME \
    && mkdir -p $NODE_HOME && yarn install --check-files && chown -R app:app $NODE_HOME

VOLUME $GEM_HOME $NODE_HOME
USER app:app
ENTRYPOINT ["/ripper/entrypoint"]
CMD ["./run_puma"]
