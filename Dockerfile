#
# ElasticSearch Dockerfile
#
# https://github.com/dockerfile/elasticsearch
#
# Busybox with a Java installation

FROM progrium/busybox
MAINTAINER  Olav Gjerde <olav@backupbay.com>

RUN opkg-install curl ca-certificates

ENV JAVA_HOME /usr/jdk1.8.0_31

RUN curl \
  --silent \
  --location \
  --retry 3 \ 
  --cacert /etc/ssl/certs/GeoTrust_Global_CA.crt \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/8u31-b13/server-jre-8u31-linux-x64.tar.gz" \
    | gunzip \
    | tar x -C /usr/ \
    && ln -s $JAVA_HOME /usr/java \
    && rm -rf $JAVA_HOME/man

ENV PATH ${PATH}:${JAVA_HOME}/bin

ENV ES_PKG_NAME elasticsearch-1.4.2

# Install Elasticsearch.
RUN curl \
  --silent \
  --location \
  --retry 3 \
  --cacert /etc/ssl/certs/GeoTrust_Global_CA.crt \
	"https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz" \
  | gunzip \
  | tar x -C /

RUN ls -la /
RUN mv /$ES_PKG_NAME /elasticsearch

# Install Plugins.
RUN \
  /elasticsearch/bin/plugin -install elasticsearch/elasticsearch-analysis-icu/2.4.1 && \
  /elasticsearch/bin/plugin -install mobz/elasticsearch-head

# Define mountable directories.
VOLUME ["/data"]

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["/elasticsearch/bin/elasticsearch"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300

