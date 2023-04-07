FROM monetdb/monetdb-r-docker

WORKDIR /db

COPY ./zillow.csv /db

RUN yum -y install python-pandas

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
