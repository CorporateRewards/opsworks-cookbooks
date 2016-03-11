default["munin-node"]["host_name"] = "SET MUNIN HOST NAME"
default["munin-node"]["port"] = "4949"
default["munin-node"]["plugins"] = []
default["munin-node"]["allow"] = ["^127."]
default["munin-node"]["cidr_allow"] = []
default["munin-master"]["nodes"] = [{name:"localhost",address:"127.0.0.1",use_node_name:"yes"}]
