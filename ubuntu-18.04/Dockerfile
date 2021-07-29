FROM ubuntu:18.04

RUN apt update 
RUN DEBIAN_FRONTEND=noninteractive apt -qq upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt -qq install -y wget checkinstall openssl
RUN wget https://dist.1-2.dev/imei.sh 
RUN bash -x ./imei.sh --log-file /usr/local/src/imei-build.log --use-checkinstall --config-dir /etc

CMD bash

