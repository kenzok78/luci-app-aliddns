local m, s, o

m = Map("aliddns", translate("AliDDNS"))

s = m:section(TypedSection, "base", translate("Base"))
s.anonymous = true

o = s:option(Flag, "enable", translate("enable"))
o.rmempty = false

o = s:option(Flag, "clean", translate("Clean Before Update"))
o.rmempty = false

o = s:option(Flag, "ipv4", translate("Enabled IPv4"))
o.rmempty = false

o = s:option(Flag, "ipv6", translate("Enabled IPv6"))
o.rmempty = false

o = s:option(Value, "app_key", translate("Access Key ID"))

o = s:option(Value, "app_secret", translate("Access Key Secret"))

o = s:option(
	ListValue,
	"interface",
	translate("WAN-IP Source"),
	translate("Select the WAN-IP Source for AliDDNS, like wan/internet")
)
o:value("", translate("Select WAN-IP Source"))
o:value("internet", translate("Internet"))
o:value("wan")
o.rmempty = false

o = s:option(
	ListValue,
	"interface6",
	translate("WAN6-IP Source"),
	translate("Select the WAN6-IP Source for AliDDNS, like wan6/internet")
)
o:value("", translate("Select WAN6-IP Source"))
o:value("internet", translate("Internet"))
o:value("wan")
o:value("wan6")
o:value("wan_6")
o.rmempty = true

o = s:option(Value, "main_domain", translate("Main Domain"),
	translate("For example: test.github.com -> github.com"))
o.rmempty = false

o = s:option(Value, "sub_domain", translate("Sub Domain"),
	translate("For example: test.github.com -> test"))
o.rmempty = false

o = s:option(Value, "time", translate("Inspection Time"),
	translate("Unit: Minute, Range: 1-59"))
o.default = "10"
o.rmempty = false

s = m:section(TypedSection, "base", translate("Update Log"))
s.anonymous = true

local log_path = "/var/log/aliddns.log"
o = s:option(TextValue, "sylogtext")
o.rows = 16
o.readonly = "readonly"
o.wrap = "off"
o.cfgvalue = function(self, section)
	local log_content = ""
	if nixio.fs.access(log_path) then
		local f = io.open(log_path, "r")
		if f then
			local lines = {}
			for i = 1, 200 do
				local line = f:read("*l")
				if not line then break end
				table.insert(lines, line)
			end
			f:close()
			if #lines > 100 then
				for i = #lines - 99, #lines do
					log_content = log_content .. lines[i] .. "\n"
				end
			else
				log_content = table.concat(lines, "\n")
			end
		end
	end
	return log_content
end

o.write = function(self, section, value)
end

if luci.http.formvalue("cbi.apply") then
	io.popen("/etc/init.d/aliddns restart &")
end

return m
