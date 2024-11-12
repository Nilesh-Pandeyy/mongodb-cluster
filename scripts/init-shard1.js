rs.initiate(
    {
      _id: "shard1RS",
      members: [
        { _id: 0, host: "shard1svr1:27018", priority: 2 },
        { _id: 1, host: "shard1svr2:27018", priority: 1 },
        { _id: 2, host: "shard1svr3:27018", priority: 1 }
      ]
    }
  );