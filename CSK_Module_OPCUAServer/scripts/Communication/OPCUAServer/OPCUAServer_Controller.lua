---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the OPCUAServer_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_OPCUAServer'

-- Timer to update UI via events after page was loaded
local tmrOPCUAServer = Timer.create()
tmrOPCUAServer:setExpirationTime(300)
tmrOPCUAServer:setPeriodic(false)

-- Reference to global handle
local opcuaServer_Model

-- ************************ UI Events Start ********************************

-- Script.serveEvent("CSK_OPCUAServer.OnNewEvent", "OPCUAServer_OnNewEvent")

Script.serveEvent('CSK_OPCUAServer.OnNewResult', 'OPCUAServer_OnNewResult')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusModuleVersion', 'OPCUAServer_OnNewStatusModuleVersion')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusCSKStyle', 'OPCUAServer_OnNewStatusCSKStyle')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusModuleIsActive', 'OPCUAServer_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusEventToRegister', 'OPCUAServer_OnNewStatusEventToRegister')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusFlowConfigPriority', 'OPCUAServer_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_OPCUAServer.OnNewStatusLoadParameterOnReboot", "OPCUAServer_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_OPCUAServer.OnPersistentDataModuleAvailable", "OPCUAServer_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_OPCUAServer.OnNewParameterName", "OPCUAServer_OnNewParameterName")
Script.serveEvent("CSK_OPCUAServer.OnDataLoadedOnReboot", "OPCUAServer_OnDataLoadedOnReboot")

Script.serveEvent('CSK_OPCUAServer.OnUserLevelOperatorActive', 'OPCUAServer_OnUserLevelOperatorActive')
Script.serveEvent('CSK_OPCUAServer.OnUserLevelMaintenanceActive', 'OPCUAServer_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_OPCUAServer.OnUserLevelServiceActive', 'OPCUAServer_OnUserLevelServiceActive')
Script.serveEvent('CSK_OPCUAServer.OnUserLevelAdminActive', 'OPCUAServer_OnUserLevelAdminActive')

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("OPCUAServer_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("OPCUAServer_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("OPCUAServer_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("OPCUAServer_OnUserLevelAdminActive", status)
end

--- Function to get access to the opcuaServer_Model object
---@param handle handle Handle of opcuaServer_Model object
local function setOPCUAServer_Model_Handle(handle)
  opcuaServer_Model = handle
  if opcuaServer_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if opcuaServer_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("OPCUAServer_OnUserLevelAdminActive", true)
    Script.notifyEvent("OPCUAServer_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("OPCUAServer_OnUserLevelServiceActive", true)
    Script.notifyEvent("OPCUAServer_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrOPCUAServer()

  updateUserLevel()

  Script.notifyEvent("OPCUAServer_OnNewStatusModuleVersion", opcuaServer_Model.version)
  Script.notifyEvent("OPCUAServer_OnNewStatusCSKStyle", opcuaServer_Model.styleForUI)
  Script.notifyEvent("OPCUAServer_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  Script.notifyEvent("OPCUAServer_OnNewStatusEventToRegister", opcuaServer_Model.parameters.registerEvent)

  -- Script.notifyEvent("OPCUAServer_OnNewEvent", false)

  Script.notifyEvent("OPCUAServer_OnNewStatusFlowConfigPriority", opcuaServer_Model.parameters.flowConfigPriority)
  Script.notifyEvent("OPCUAServer_OnNewStatusLoadParameterOnReboot", opcuaServer_Model.parameterLoadOnReboot)
  Script.notifyEvent("OPCUAServer_OnPersistentDataModuleAvailable", opcuaServer_Model.persistentModuleAvailable)
  Script.notifyEvent("OPCUAServer_OnNewParameterName", opcuaServer_Model.parametersName)
  -- ...
end
Timer.register(tmrOPCUAServer, "OnExpired", handleOnExpiredTmrOPCUAServer)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrOPCUAServer:start()
  return ''
end
Script.serveFunction("CSK_OPCUAServer.pageCalled", pageCalled)

--[[
local function setSomething(value)
  _G.logger:fine(nameOfModule .. ": Set new value = " .. value)
  opcuaServer_Model.varA = value
end
Script.serveFunction("CSK_OPCUAServer.setSomething", setSomething)
]]

local function setEventToRegister(event)
  opcuaServer_Model.registerToEvent(event)
end
Script.serveFunction('CSK_OPCUAServer.setEventToRegister', setEventToRegister)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_OPCUAServer.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  -- Insert code here to clear FlowConfig relevant actions
  opcuaServer_Model.deregisterFromEvent()
end
Script.serveFunction('CSK_OPCUAServer.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters()
  return opcuaServer_Model.helperFuncs.json.encode(opcuaServer_Model.parameters)
end
Script.serveFunction('CSK_OPCUAServer.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name: " .. tostring(name))
  opcuaServer_Model.parametersName = name
end
Script.serveFunction("CSK_OPCUAServer.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if opcuaServer_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(opcuaServer_Model.helperFuncs.convertTable2Container(opcuaServer_Model.parameters), opcuaServer_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, opcuaServer_Model.parametersName, opcuaServer_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send OPCUAServer parameters with name '" .. opcuaServer_Model.parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_OPCUAServer.sendParameters", sendParameters)

local function loadParameters()
  if opcuaServer_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(opcuaServer_Model.parametersName)
    if data then
      clearFlowConfigRelevantConfiguration()
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      opcuaServer_Model.parameters = opcuaServer_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      -- ...
      -- ...

      CSK_OPCUAServer.pageCalled()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_OPCUAServer.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  opcuaServer_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("OPCUAServer_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_OPCUAServer.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  opcuaServer_Model.parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("OPCUAServer_OnNewStatusFlowConfigPriority", opcuaServer_Model.parameters.flowConfigPriority)
end
Script.serveFunction('CSK_OPCUAServer.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')

    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')
      opcuaServer_Model.persistentModuleAvailable = false
    else

      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

      if parameterName then
        opcuaServer_Model.parametersName = parameterName
        opcuaServer_Model.parameterLoadOnReboot = loadOnReboot
      end

      if opcuaServer_Model.parameterLoadOnReboot then
        loadParameters()
      end
      Script.notifyEvent('OPCUAServer_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    clearFlowConfigRelevantConfiguration()
    pageCalled()
  end
end
Script.serveFunction('CSK_OPCUAServer.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setOPCUAServer_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

