FROM node:6.0.0

MAINTAINER i9corp <support@i9corp.com.br>

WORKDIR /local-npm
ADD . /local-npm/

RUN groupadd -r local-npm --gid=999 \
    && useradd -r -g local-npm --uid=999 local-npm

RUN npm set progress=false && npm install --no-color && npm dedupe

EXPOSE 5080
EXPOSE 16984

VOLUME /data

ENV BASE_URL='http://127.0.0.1:5080'
ENV DATA_DIRECTORY='/data'
ENV REMOTE_REGISTRY='https://registry.npmjs.org'
ENV REMOTE_REGISTRY_SKIMDB='https://skimdb.npmjs.com/registry'

RUN mkdir -p ${DATA_DIRECTORY} chmod 700 ${DATA_DIRECTORY} \
    && chown -R local-npm ${DATA_DIRECTORY}

RUN npm start -- --remote ${REMOTE_REGISTRY} --remote-skim ${REMOTE_REGISTRY_SKIMDB} --directory ${DATA_DIRECTORY} --url-base ${BASE_URL}

COPY ./tools/start-packages /usr/local/bin/start-packages
RUN dos2unix /usr/local/bin/start-packages \
    && chmod +x /usr/local/bin/start-packages

CMD ["/usr/local/bin/start-packages"]
