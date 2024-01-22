#!/bin/bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  BEGIN;
    CREATE TABLE IF NOT EXISTS customers (
	id BIGINT NOT NULL,
	name 	varchar(40),
	phone   varchar(15),
	email   varchar(20),
	registrationDate date not null
    ) PARTITION BY RANGE(registrationDate);
  COMMIT;

-- create schema for partman
CREATE SCHEMA partman;
      
-- enable extensions --
CREATE EXTENSION pg_partman SCHEMA partman;
CREATE EXTENSION pg_cron SCHEMA pg_catalog VERSION '1.5'; 

-- Create the partitions using partman

SELECT partman.create_parent(
    p_parent_table := 'public.customers', -- table to be attached to
    p_control := 'registrationdate',      -- partition key
    p_interval := '1 year', 		  -- partitions for each month
    p_start_partition := '2021-01-01', 	  -- start partitioning from 2020
    p_premake := 1, 			  -- create 0 years ahead of current date    
    p_default_table:= true 		  -- create default partition
);

--****************** WE MAY NOT NEED THIS PART ****************************************************
-- Configure policy to be used by the maintenance proc

UPDATE partman.part_config
SET infinite_time_partitions = true,  -- permit creation of partitions without limits
    retention = '2 years',  	      -- keep partitions for 5 years
    retention_keep_table=true 	      -- When the retention period is due, the table isn't deleted. Instead, partitions are only detached from the parent table.
WHERE parent_table = 'public.customers';


-- schedule it to run run_maintenance_proc every minute
SELECT cron.schedule('*/10 * * * *', 'CALL partman.run_maintenance_proc()');

--*************************************************************************************************

-- schedule process to move data from default table to a proper partition, it automatically creates partition
SELECT cron.schedule('* * * * *', 'select partman.partition_data_time('||'''public.customers'''||', p_batch_count:=999999)');
    
    
-- LOAD SOME DATA 
insert into customers values ('1','Tony Stark','1234-5678','tony@stakindustries','2021-01-01');
insert into customers values ('2','Peper Potts','1234-5678','pepper@stakindustry','2021-02-01');
insert into customers values ('3','Steve Banon','1234-5678','hulk@avengers.com','2022-02-01');
insert into customers values ('4','Steve Rogers','1234-5678','capitan@avengers.com','2023-01-01');
insert into customers values ('5','Natasha','1234-5678','romanov@avengers.com','2024-01-01');
insert into customers values ('6','Clint Barton','1234-5678','Hawkeye@avengers.com','2025-02-01');
insert into customers values ('7','Thor','1234-5678','Thor@avengers.com','2026-02-01');

-- ADD SOME SUPER VILLAIN TO SEE THEIR PARTITIONS BEING CREATED ON DEMAND
--insert into customers values ('8','Loki','1234-5678','loki@villains.com','2030-01-01');
--insert into customers values ('9','Thanos','1234-5678','thanos@villains.com','2040-01-01');
--insert into customers values ('10','Ultron','1234-5678','ultron@villains.com','2041-01-01');
--insert into customers values ('11','Kang','1234-5678','kang@villains.com','2042-01-01');
EOSQL
