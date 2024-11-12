rs.initiate(
    {
      _id: "shard2RS",
      members: [
        { _id: 0, host: "shard2svr1:27018", priority: 2 },
        { _id: 1, host: "shard2svr2:27018", priority: 1 },
        { _id: 2, host: "shard2svr3:27018", priority: 1 }
      ]
    }
  );