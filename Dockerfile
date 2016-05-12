FROM qa.stratio.com:5000/stratio/ubuntu-base-ssh:16.04
MAINTAINER Antonio Alfonso "aalfonso@stratio.com"

COPY docker-entrypoint.sh /dcos/docker-entrypoint.sh
COPY dcosToken.js /dcos/dcosToken.js

ADD https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 /dcos/.

RUN apt-get update && apt-get install -y build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev curl python-pip
RUN pip install dcoscli

RUN chmod a+x /dcos/docker-entrypoint.sh && chmod a+x /dcos/dcosToken.js

WORKDIR /dcos

RUN export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" && tar xvjf $PHANTOM_JS.tar.bz2 && mv $PHANTOM_JS /usr/local/share && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

EXPOSE 22

ENTRYPOINT ["/dcos/docker-entrypoint.sh"]
