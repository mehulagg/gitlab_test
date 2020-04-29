select pg_create_logical_replication_slot('shard1', 'pgoutput');
select pg_create_logical_replication_slot('shard2', 'pgoutput');

create publication test for table users, projects;