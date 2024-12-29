-- SmartThings Edge Driver: Virtual Humidifier

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"

-- Command handlers
local command_handlers = {}

function command_handlers.switch_on(driver, device, command)
  log.info("Turning on the humidifier")
  device:emit_event(capabilities.switch.switch.on())
end

function command_handlers.switch_off(driver, device, command)
  log.info("Turning off the humidifier")
  device:emit_event(capabilities.switch.switch.off())
end

function command_handlers.set_mode(driver, device, command)
  local mode = command.args.mode
  log.info(string.format("Setting humidifier mode to %s", mode))
  
  -- emit_event에 프레젠테이션 values와 일치하는 값 전달
  device:emit_event(capabilities.mode.mode({ value = mode }))
end

local function device_added(driver, device)
  log.info(string.format("Device %s added", device.id))
  device:emit_event(capabilities.switch.switch.off())
  -- 초기 모드 설정
  device:emit_event(capabilities.mode.mode({ value = "자동" }))
end

local function device_init(driver, device)
  log.info(string.format("Initializing device %s", device.id))
  device:online()
  device:emit_event(capabilities.switch.switch.off())
  device:emit_event(capabilities.mode.mode({ value = "자동" }))
end

local function device_removed(driver, device)
  log.info(string.format("Device %s removed", device.id))
end

-- Discovery handler
local function handle_discovery(driver, should_continue)
  log.info("Discovering virtual humidifier")
  local metadata = {
    type = "LAN",
    device_network_id = "virtual_humidifier",
    label = "Virtual Humidifier",
    profile = "evaporative-humidifier.v1",
    manufacturer = "Virtual Manufacturer",
    model = "VirtualHumidifier",
    vendor_provided_label = "Virtual Humidifier"
  }

  driver:try_create_device(metadata)
end

-- Driver definition
local virtual_humidifier_driver = Driver("VirtualHumidifier", {
  discovery = handle_discovery,
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    removed = device_removed
  },
  capability_handlers = {
    [capabilities.switch.ID] = {
      [capabilities.switch.commands.on.NAME] = command_handlers.switch_on,
      [capabilities.switch.commands.off.NAME] = command_handlers.switch_off,
    },
    [capabilities.mode.ID] = {
      [capabilities.mode.commands.setMode.NAME] = command_handlers.set_mode
    }
  }
})

virtual_humidifier_driver:run()
