CREATE SUBSCRIPTION test CONNECTION 'dbname=gitlabhq_development host=/home/abrandl-gl/workspace/gdk/postgresql' PUBLICATION test WITH (slot_name = 'shard1', create_slot = false);
