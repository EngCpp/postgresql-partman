# Dockerfile relative to docker-compose.yml

FROM postgres:16.1
ENV PG_CRON_VERSION           "1.4.2"

RUN apt-get update && apt-get -y install git build-essential postgresql-server-dev-16 postgresql-16-cron postgresql-16-partman

EXPOSE 5432
CMD ["postgres"]
