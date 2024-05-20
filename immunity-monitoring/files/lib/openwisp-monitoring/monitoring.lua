package.path = package.path .. ";../files/lib/?.lua"

local monitoring = {}

monitoring.dhcp = require('immunity-monitoring.dhcp')
monitoring.interfaces = require('immunity-monitoring.interfaces')
monitoring.neighbors = require('immunity-monitoring.neighbors')
monitoring.resources = require('immunity-monitoring.resources')
monitoring.utils = require('immunity-monitoring.utils')
monitoring.wifi = require('immunity-monitoring.wifi')

return monitoring
