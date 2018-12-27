FROM registry.cn-beijing.aliyuncs.com/dxq_docker/base:latest
LABEL maintainer=ahmerry@qq.com

ARG ek_version=6.4.0

RUN apk add --quiet --no-progress --no-cache nodejs java-jna-native openjdk8-jre openssl && adduser -D elsearch elsearch
WORKDIR /home/elsearch
ENV ES_TMPDIR=/home/elsearch/elasticsearch.tmp

RUN wget -q -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-${ek_version}.tar.gz \
 |  tar -zx elasticsearch-${ek_version}.tar.gz \
 && mv elasticsearch-${ek_version} elasticsearch \
 && mkdir -p ${ES_TMPDIR} \
 && wget -q -O - https://artifacts.elastic.co/downloads/kibana/kibana-oss-${ek_version}-linux-x86_64.tar.gz \
 |  tar -zx \
 && mv kibana-${ek_version}-linux-x86_64 kibana \
 && rm -f kibana/node/bin/node kibana/node/bin/npm \
 && ln -s $(which node) kibana/node/bin/node \
 && ln -s $(which npm) kibana/node/bin/npm
EXPOSE 9200 5601

#nginx
RUN apk add nginx \
  && mkdir -p /run/nginx \
  && chmod 777 -R /run/nginx
#复制nginx配置
COPY nginx_config /etc/nginx
#复制密码
COPY passwd_file /passwd_file
#hosts
RUN echo "127.0.0.1 search.a.com" >> /etc/hosts

COPY shell /shell
RUN cd /shell && chmod -R 777 /shell && chmod -R 777 /home/elsearch/elasticsearch && chmod -R 777 /home/elsearch/elasticsearch.tmp
CMD ["/shell/start.sh"]