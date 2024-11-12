// File: scripts/init-sharding.js

// Add shards
sh.addShard("shard1RS/shard1svr1:27018,shard1svr2:27018,shard1svr3:27018");
sh.addShard("shard2RS/shard2svr1:27018,shard2svr2:27018,shard2svr3:27018");

// Enable sharding for database
sh.enableSharding("mydb");

// Switch to mydb database
db = db.getSiblingDB("mydb");

// Create and shard users collection
db.users.createIndex({ "userId": "hashed" });
sh.shardCollection("mydb.users", { "userId": "hashed" });

// Create and shard orders collection
db.orders.createIndex({ "timestamp": 1, "orderId": 1 });
sh.shardCollection("mydb.orders", { "timestamp": 1, "orderId": 1 });