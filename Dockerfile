FROM ubuntu:latest

MAINTAINER mahuaibo ma_huaibo@qq.com

ENV VERSION 0.3.1
ENV RPCPORT 18332
ENV PORT 8332
ENV bitcoinconf /bitcoin.conf
ENV nginxconf /etc/nginx/sites-available/default
ENV rpcuser bitcoin
ENV rpcpassword bitcoin

RUN apt-get update -y && apt-get install nginx -y && apt-get install wget -y \
&& wget https://github.com/OmniLayer/omnicore/releases/download/v$VERSION/omnicore-$VERSION-x86_64-linux-gnu.tar.gz \
&& tar -zvxf omnicore-$VERSION-x86_64-linux-gnu.tar.gz \
&& mv omnicore-$VERSION/bin/omnicored /usr/local/bin/omnicored \
&& mv omnicore-$VERSION/bin/omnicore-cli /usr/local/bin/omnicore-cli \
&& rm -rvf omnicore-$VERSION* \
&& mkdir /root/.bitcoin \
&& auth_base=$(echo -n $rpcuser:$rpcpassword | base64 ) \
&& echo "server=1\nrest=1\nrpcuser=bitcoin\nrpcpassword=bitcoin\nrpcport=$RPCPORT\ntxindex=1\ndatacarriersize=80\nlogtimestamps=1\nomnidebug=tally\nomnidebug=pending\ndisablewallet=1\ndatadir=/root/.bitcoin\nprinttoconsole=1" > $bitcoinconf \
&& echo -n "server {\n\tlisten      $PORT;\n\tlisten [::]:$PORT;\n\tserver_name _;\n\tkeepalive_timeout    90;\n\tclient_max_body_size 1m;\n\tsendfile             on;\n\troot       /srv/empty;\n\taccess_log /var/log/nginx/blockchain_access_log;\n\terror_log  /var/log/nginx/blockchain_error_log;\n\tlocation / {\n\t\tproxy_pass       http://127.0.0.1:$RPCPORT;\n\t\tproxy_set_header Host \$host;\n\t\tproxy_set_header X-Real-IP \$remote_addr;\n\t\tproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n\t\tproxy_set_header Authorization \"Basic $auth_base\";\n\t}\n}" > $nginxconf \
&& echo "#!/bin/sh\n\n/usr/sbin/nginx\n\nomnicored -conf=/bitcoin.conf $@" > /service.sh \
&& chmod 755 /service.sh

EXPOSE $PORT

ENTRYPOINT /service.sh