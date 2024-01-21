# Postgresql partman
PostgreSQL Partman Example, demonstrates how to create partitions on demadand for a postgreSql table
This is using 100% PostgreSQL technology, and I use docker and docker-compose just to simulate the server


:dancers: 

## Build
In order for this demo to work, we need to create a docker image with PostgreSQL 16.1, PG_Partman and PG_Cron extensions.
To do that we run ./build.sh script

<img src="readme-imgs/build.png"/>


## Running Postgresql Sharding
The only concern to run this demo is to make sure posrgresql is not running already on your host machine, as the master runs on port 5432 it may collide with an existing running instance.

| Servers     | Port  | Table          |
| ------------| ------|----------------|
| pg_master   | 5432  | customers      |


:woman_dancing:
to start the server run:
```
docker-compose up
```
to stop the server (and keep the data)
```
docker-compose down
```
to stop the server (removing the database, it will be recreated again next time you docker-compose up)
```
docker-compose down -v
```

## Checking if it works
1 - Connect you pgAdmin to the instance:
<img src="readme-imgs/connection.png"/>

3 - run sql statemet to check the pg_db:
- SELECT * FROM cron.job ORDER BY jobid ASC (to check the job scheduled)
- SELECT * FROM cron.job_run_details ORDER BY runid ASC (to check if the job has run successfuly)
- SELECT * FROM public.customers (To check the data inserted by default)
<img src="readme-imgs/customers.png"/>


### go into the public table and check the partitions available:
<img src="readme-imgs/partitions.png"/>

### Add Extra Data:
go into the ./scripts/init-db.sh and copy some commented sql (super villains) at the botton
<img src="readme-imgs/add-extra-data.png"/>

### Check the default partition and confirm they are there:
<img src="readme-imgs/default-table-full.png"/>

Wait for 1 minute .. and check if the script has run ..

<img src="readme-imgs/scripit-has-run.png"/>

### Check the new partitions recentrly created:
<img src="readme-imgs/confirm-partitions.png"/>

and check if the data is there

<img src="readme-imgs/confirm-data.png"/>

