local Queries = {}

local entries = {
	["terminal"] = "This terminal is property of the NXT-1 Training Collective (Unit 4). It's purpose is to provide several utilities (varies with security clearance) to users without the need for an overseeing operator. These utilities include initiating training duels, and viewing database entries.",
	["nacht-1"] = "The Nacht-1 Training Collective is a hidden underground organization founded by the Architects which serves to rebel against external forces such as the Matrices and the Conformists.",
	["matrices"] = "[REDACTED]",
	["outsider"] = [[The term Outsider is used to describe an individual or group of individials which are not a part of the NXT-1 Training Collective. Outsiders have gained a notorious reputation for attempting to infiltrate NXT-1 related facilities in order to steal resources and sabotage operations. There have been many cases of Outsiders assimilating into the training collective, however they should be treated with caution.]],
	["conformists"] = "The term conformist refers to any Outsider who is loyal to and/or works for/with the Matrices in accomplishing their goals.",
}

local aliases = {
	["nacht"] = "nacht-1",
	["nacht-1 training collective"] = "nacht-1",
	["the matrices"] = "matrices",
	["outsiders"] = "outsider",
}

local commands = {
	help = function()
		return
		[[eth.os Version 3.76.1
		help: display this message
		query [entry name]: display entry corresponding with provided name (eg. query terminal)
		]]
	end,

	query = function(args)
		if #args == 0 then return "Please provide a query (eg. `query terminal`)." end

		local key = string.lower(table.concat(args, " "))
		key = aliases[key] or key
		return entries[key] or "Query does not match any entries."
	end,

	status = function()
		return "All systems nominal."
	end
}

function Queries:Execute(command, args)
	local callback = commands[command]
	if callback == nil then return "Command not found." end

	return callback(args)
end

return Queries
