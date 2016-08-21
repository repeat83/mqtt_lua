#!/usr/bin/lua
-- ------------------------------------------------------------------------- --
-- mqtt_publish.lua
-- ~~~~~~~~~~~~~~~~
-- Please do not remove the following notices.
-- Copyright (c) 2011-2012 by Geekscape Pty. Ltd.
-- Documentation: http://http://geekscape.github.com/mqtt_lua
-- License: AGPLv3 http://geekscape.org/static/aiko_license.html
-- Version: 0.2 2012-06-01
--
-- Description
-- ~~~~~~~~~~~
-- Publish an MQTT message on the specified topic with an optional last will.
--
-- References
-- ~~~~~~~~~~
-- Lapp Framework: Lua command line parsing
--   http://lua-users.org/wiki/LappFramework
--
-- ToDo
-- ~~~~
-- None, yet.
-- ------------------------------------------------------------------------- --

function callback(
  topic,    -- string
  message)  -- string

  print("Topic: " .. topic .. ", message: '" .. message .. "'")
end

function is_openwrt()
  return(os.getenv("USER") == "root")  -- Assume logged in as "root" on OpenWRT
end

-- ------------------------------------------------------------------------- --

print("[mqtt v0.3 2016-08-21]")

--if (not is_openwrt()) then require("luarocks.require") end
--local lapp = require("pl.lapp")

--[[
local args = lapp [[
  Publish a message to a specified MQTT topic
  -d,--debug                                Verbose console logging
  -H,--host          (default localhost)    MQTT server hostname
  -i,--id            (default mqtt_pub)     MQTT client identifier
  -m,--message       (string)               Message to be published
  -p,--port          (default 1883)         MQTT server port number
  -k,--keepalive     (default 60)           Send MQTT PING period (seconds)
  -t,--topic         (string)               Topic on which to publish
  -w,--will_message  (default .)            Last will and testament message
  -w,--will_qos      (default 0)            Last will and testament QOS
  -w,--will_retain   (default 0)            Last will and testament retention
  -w,--will_topic    (default .)            Last will and testament topic
]]

args = {}
--args.debug = true
args.host = "192.168.6.114"
args.method = "sub" -- pub or sub
args.id = "mqtt_id1"
args.keepalive = 60
args.message = "tttest"
args.topic = "/v1"
args.will_message = args.id.." leave"
args.will_qos = 0
args.will_retain = 0
args.will_topic = "/v1"


local MQTT = require("mqtt_library")

if (args.debug) then MQTT.Utility.set_debug(true) end


----------------------
if (args.keepalive) then MQTT.client.KEEP_ALIVE_TIME = args.keepalive end

local mqtt_client = MQTT.client.create(args.host, args.port, callback)
----------------

--local mqtt_client = MQTT.client.create(args.host, args.port)

if (args.will_message == "."  or  args.will_topic == ".") then
  mqtt_client:connect(args.id)
else
  mqtt_client:connect(
    args.id, args.will_topic, args.will_qos, args.will_retain, args.will_message
  )
end

if (args.method == "pub") then
  mqtt_client:publish(args.topic, args.message)
  mqtt_client:destroy()
elseif (args.method == "sub") then
  mqtt_client:subscribe({args.topic})

  local error_message = nil

  while (error_message == nil) do
    error_message = mqtt_client:handler()
    socket.sleep(1.0)  -- seconds
  end

  if (error_message == nil) then
    mqtt_client:unsubscribe({args.topic})
    mqtt_client:destroy()
  else
    print(error_message)
  end
end

-- ------------------------------------------------------------------------- --
