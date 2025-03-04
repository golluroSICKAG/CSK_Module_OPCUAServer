---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

--- Function to load all default APIs
local function loadAPIs()
  CSK_OPCUAServer = require 'API.CSK_OPCUAServer'

  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'

  Container = require 'API.Container'
  Engine = require 'API.Engine'
  Object = require 'API.Object'
  Timer = require 'API.Timer'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    elseif appList[i] == 'CSK_Module_FlowConfig' then
      CSK_FlowConfig = require 'API.CSK_FlowConfig'
    end
  end
end

-- Function to load specific APIs
local function loadSpecificAPIs()
  -- If you want to check for specific APIs/functions supported on the device the module is running, place relevant APIs here
  OPCUA = {}
  OPCUA.Server = require 'API.OPCUA.Server'
  OPCUA.Server.EndpointConfiguration = require 'API.OPCUA.Server.EndpointConfiguration'
  OPCUA.Server.FileCertificateStoreConfiguration = require 'API.OPCUA.Server.FileCertificateStoreConfiguration'
  OPCUA.Server.Namespace = require 'API.OPCUA.Server.Namespace'
  OPCUA.Server.Node = require 'API.OPCUA.Server.Node'
  OPCUA.Server.SecurityConfiguration = require 'API.OPCUA.Server.SecurityConfiguration'
  OPCUA.Server.ServerConfiguration = require 'API.OPCUA.Server.ServerConfiguration'
  OPCUA.Server.UserTokenDatabase = require 'API.OPCUA.Server.UserTokenDatabase'
  OPCUA.Server.Value = require 'API.OPCUA.Server.Value'
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
availableAPIs.specific = xpcall(loadSpecificAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly

return availableAPIs
--**************************************************************************