-record(users, {id, name, password, display}).
-record(wtts, {id, wanters = ordsets:new(), havers = ordsets:new()}).
-record(auto_increment, {table, key}).
-record(cards, {id, name}).
