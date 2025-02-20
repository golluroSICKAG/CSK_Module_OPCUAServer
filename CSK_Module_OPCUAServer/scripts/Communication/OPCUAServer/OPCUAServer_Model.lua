---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_OPCUAServer'

local opcuaServer_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
opcuaServer_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
opcuaServer_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
opcuaServer_Model.parametersName = 'CSK_OPCUAServer_Parameter' -- name of parameter dataset to be used for this module
opcuaServer_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the OPCUAServer_Model interface and give access
-- to the OPCUAServer_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setOPCUAServer_ModelHandle = require('Communication/OPCUAServer/OPCUAServer_Controller')
setOPCUAServer_ModelHandle(opcuaServer_Model)

--Loading helper functions if needed
opcuaServer_Model.helperFuncs = require('Communication/OPCUAServer/helper/funcs')

-- Optionally check if specific API was loaded via
--[[
if _G.availableAPIs.specific then
-- ... doSomething ...
end
]]


-- Create parameters / instances for this module
opcuaServer_Model.styleForUI = 'None' -- Optional parameter to set UI style
opcuaServer_Model.version = Engine.getCurrentAppVersion() -- Version of module
--[[
opcuaServer_Model.object = Image.create() -- Use any AppEngine CROWN
opcuaServer_Model.counter = 1 -- Short docu of variable
opcuaServer_Model.varA = 'value' -- Short docu of variable
--...
]]

-- Parameters to be saved permanently if wanted
opcuaServer_Model.parameters = {}
opcuaServer_Model.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
opcuaServer_Model.parameters.registerEvent = '' -- Event to get data
--opcuaServer_Model.parameters.paramA = 'paramA' -- Short docu of variable
--opcuaServer_Model.parameters.paramB = 123 -- Short docu of variable
--...

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  opcuaServer_Model.styleForUI = theme
  Script.notifyEvent("OPCUAServer_OnNewStatusCSKStyle", opcuaServer_Model.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

local function processData(data)
  _G.logger:fine(nameOfModule .. ": Process data...")

  -- Process data...
  -- ...

  Script.notifyEvent('OPCUAServer_OnNewResult', data)
end
opcuaServer_Model.processData = processData

local function registerToEvent(event)
  if opcuaServer_Model.parameters.registerEvent then
    Script.deregister(opcuaServer_Model.parameters.registerEvent, processData)
  end
  opcuaServer_Model.parameters.registerEvent = event
  Script.register(event, processData)
end
opcuaServer_Model.registerToEvent = registerToEvent

local function deregisterFromEvent()
  if opcuaServer_Model.parameters.registerEvent ~= '' then
    Script.deregister(opcuaServer_Model.parameters.registerEvent, processData)
    opcuaServer_Model.parameters.registerEvent = ''
    Script.notifyEvent("OPCUAServer_OnNewStatusEventToRegister", opcuaServer_Model.parameters.registerEvent)
  end
end
opcuaServer_Model.deregisterFromEvent = deregisterFromEvent

--[[
-- Some internal code docu for local used function to do something
---@param content auto Some info text if function is not already served
local function doSomething(content)
  _G.logger:fine(nameOfModule .. ": Do something")
  opcuaServer_Model.counter = opcuaServer_Model.counter + 1
end
opcuaServer_Model.doSomething = doSomething
]]

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return opcuaServer_Model
