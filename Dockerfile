FROM ruby:2.5

ENV APP_ROOT /usr/src/rails-todo

WORKDIR ${APP_ROOT}

RUN apt-get update && \
    apt-get install -y mysql-client \
                       build-essential \
                       apt-transport-https \
                       libssl-dev \
                       curl \
                       wget \
                       --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# install node.js
ENV PATH /root/.nodebrew/current/bin:$PATH
RUN curl -s -L git.io/nodebrew | perl - setup && \
    nodebrew install-binary v8.7.0 && \
    nodebrew use v8.7.0

# install yarn
# https://yarnpkg.com/en/docs/install#linux-tab
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

COPY Gemfile ${APP_ROOT}
COPY Gemfile.lock ${APP_ROOT}

RUN \
    echo 'gem: --no-document' >> ~/.gemrc && \
    cp ~/.gemrc /etc/gemrc && \
    chmod uog+r /etc/gemrc && \
    bundle config --global build.nokogiri --use-system-libraries && \
    bundle config --global jobs 4 && \
    bundle install && \
    rm -rf ~/.gem

COPY . ${APP_ROOT}

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
