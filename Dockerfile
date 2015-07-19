FROM quay.io/aptible/ubuntu:14.04

# Install NGiNX.
RUN apt-get update && \
    apt-get install -y software-properties-common \
    python-software-properties && \
    add-apt-repository -y ppa:nginx/stable && apt-get update && \
    apt-get -y install curl ucspi-tcp apache2-utils nginx ruby

# Download Kibana 4.1.1, extract into /opt/kibana-4.1.1.
RUN curl -O https://download.elastic.co/kibana/kibana/kibana-4.1.1-linux-x64.tar.gz && \
    echo "d43e039adcea43e1808229b9d55f3eaee6a5edb9  kibana-4.1.1-linux-x64.tar.gz" | sha1sum -c - && \
    tar xzf kibana-4.1.1-linux-x64.tar.gz -C /opt

# Overwrite default nginx config with our config.
RUN rm /etc/nginx/sites-enabled/*
ADD templates/sites-enabled /
RUN rm /opt/kibana-4.1.1-linux-x64/config/kibana.yml
ADD templates/opt/kibana-4.1.1/ /

# Add script that starts NGiNX in front of Kibana and tails the NGiNX access/error logs.
ADD bin .
RUN chmod 700 ./run-kibana.sh

# Run tests.
ADD test /tmp/test
RUN bats /tmp/test

EXPOSE 80

CMD ["./run-kibana.sh"]