---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

-----------------
local tmr = Timer.create()
tmr:setExpirationTime(1000)
tmr:setPeriodic(true)

local baseEventTypeNode
-----------------

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

-- Create parameters / instances for this module
opcuaServer_Model.styleForUI = 'None' -- Optional parameter to set UI style
opcuaServer_Model.version = Engine.getCurrentAppVersion() -- Version of module

opcuaServer_Model.isActive = false -- Status if OPC UA server is active
opcuaServer_Model.server = OPCUA.Server.create() -- OPC UA server handle
opcuaServer_Model.namespaces = {} -- Namespaces of OPC UA server
opcuaServer_Model.selectedNamespace = '' -- Name of selected namespace
opcuaServer_Model.selectedNamespaceIndex = 2 -- Selected namespace index
opcuaServer_Model.selectedNamespaceURI = '' -- Selected namespace URI

opcuaServer_Model.nodeReferences = {} -- List of available node references
opcuaServer_Model.listOfReferences = '' -- String list of available node references 

opcuaServer_Model.tempNodes = {} -- Table of temporary nodes of all namespaces

opcuaServer_Model.currentNodeClass = 'OBJECT' -- OPC UA node class, check ENUMs OPCUA.NodeClass
opcuaServer_Model.currentNodeType = 'FOLDER_TYPE' -- OPC UA node type definition, check ENUMs OPCUA.NodeType
opcuaServer_Model.currentNodeIDType = 'STRING' -- OPC UA node ID type, check ENUMs OPCUA.NodeIDType
opcuaServer_Model.currentNodeID = 'RootID' -- OPC UA node ID
opcuaServer_Model.currentNodeDataType = 'INT32' -- OPC UA node data type
opcuaServer_Model.currentNodeAccessLevel = 'READ_WRITE' -- OPC UA node data type
opcuaServer_Model.currentNodeReference = '' -- Optional node reference
opcuaServer_Model.currentNodeReferenceType = 'ORGANIZES' -- Optional reference type
opcuaServer_Model.currentEventToRegister = 'CSK_Commands.OnNewEvent' -- Event to receive data for node
opcuaServer_Model.setValueFunctions = {} -- Function to handle the set value event calls

opcuaServer_Model.currentNodes = {} -- Table of nodes of all namespaces
opcuaServer_Model.listOfNodeIDs = {} -- List of all existing node IDs (to prevent nodes with same ID)

opcuaServer_Model.ethernetPorts =  Engine.getEnumValues("EthernetInterfaces") -- Available interfaces of device running the app
opcuaServer_Model.ethernetPortsList = opcuaServer_Model.helperFuncs.createJsonList(opcuaServer_Model.ethernetPorts)

-- Parameters to be saved permanently if wanted
opcuaServer_Model.parameters = {}
opcuaServer_Model.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations

opcuaServer_Model.parameters.active = false -- Status if OPC UA server should be active
opcuaServer_Model.parameters.interface = opcuaServer_Model.ethernetPorts[1] -- Interface to use for OPC UA server
opcuaServer_Model.parameters.port = 4840 -- Server port
opcuaServer_Model.parameters.registerEvent = '' -- Event to get data
opcuaServer_Model.parameters.applicationName = 'CSK_ApplicationServer' -- OPC UA application name
opcuaServer_Model.parameters.applicationURI = '' -- Optional application URI, like urn://sick.com/opc/ua/app/sim/sim4000/12345678

opcuaServer_Model.parameters.namespaces = {} -- OPC UA namespaces
opcuaServer_Model.parameters.namespaces.names = {} -- Names of namespaces
opcuaServer_Model.parameters.namespaces.indexes = {} -- OPC UA namespace indexes
opcuaServer_Model.parameters.namespaces.urls = {} -- OPC UA namespace URIs
opcuaServer_Model.parameters.namespaces.nodes = {}

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

local function addAllNodes(node, reference, nameSpace)
  for key, value in pairs(node) do
    local newNode = OPCUA.Server.Node.create(value.class)
    if value.idType == 'NUMERIC' then
      local checkNumber = tonumber(value.id)
      if checkNumber then
        newNode:setID(value.idType, checkNumber)
      else
        _G.logger:warning(nameOfModule .. ": ID is not a number!")
        return false
      end
    else
      newNode:setID(value.idType, value.id)
    end

    if value.class == 'OBJECT' then
      --newNode:setTypeDefinition('FOLDER_TYPE')
      newNode:setTypeDefinition(value.nodeType)
    elseif value.class == 'VARIABLE' then
      newNode:setDataType(value.dataType)
      newNode:setAccessLevel(value.accessLevel)
    end
    opcuaServer_Model.currentNodes[nameSpace][value.id] = newNode
    reference:addReference(value.referenceType, newNode)
    --opcuaServer_Model.currentNodes[opcuaServer_Model.parameters.nodes.references[key]]:addReference('HAS_EVENT_SOURCE', newNode)

    table.insert(opcuaServer_Model.tempNodes[nameSpace], opcuaServer_Model.currentNodes[nameSpace][value.id])

    local function setValue(newValue)
      --print("Set value " .. newValue .. ' for NodeID ' .. value.id)
      opcuaServer_Model.currentNodes[nameSpace][value.id]:setValue(newValue)
    end
    opcuaServer_Model.setValueFunctions[value.id] = setValue

    if value.registeredEvent ~= '' and value.registeredEvent ~= nil then
      --print("Register to event " .. value.registeredEvent)
      local suc = Script.register(value.registeredEvent, opcuaServer_Model.setValueFunctions[value.id])
      --print(suc)
    end

    if value.nodes then
      addAllNodes(value.nodes, opcuaServer_Model.currentNodes[nameSpace][value.id], nameSpace)
    end
  end
  return true
end

local function startServer()
  opcuaServer_Model.setValueFunctions = {}
  opcuaServer_Model.namespaces = {} -- Namespaces of OPC UA server
  opcuaServer_Model.currentNodes = {}
  opcuaServer_Model.tempNodes = {}
  collectgarbage()

  _G.logger:fine(nameOfModule .. ": Starting server...")
  opcuaServer_Model.server:setInterface(opcuaServer_Model.parameters.interface)
  opcuaServer_Model.server:setPort(opcuaServer_Model.parameters.port)

  opcuaServer_Model.server:setApplicationName(opcuaServer_Model.parameters.applicationName)
  opcuaServer_Model.server:setApplicationURI(opcuaServer_Model.parameters.applicationURI)

  --TODO
  --opcuaServer_Model.baseEventTypeNode = OPCUA.Server.Namespace.getNodeFromStandardNamespace(opcuaServer_Model.namespace, 'NUMERIC', 2041 ) -- 2041: BaseEventType

  for namespaceKey, _ in pairs(opcuaServer_Model.parameters.namespaces.names) do
    local namespace = OPCUA.Server.Namespace.create() -- First namespace
    namespace:setIndex(opcuaServer_Model.parameters.namespaces.indexes[namespaceKey])
    table.insert(opcuaServer_Model.namespaces, namespace)

    local rootNodeData
    for rootKey, __ in pairs(opcuaServer_Model.parameters.namespaces.nodes[namespaceKey]) do
      rootNodeData = opcuaServer_Model.parameters.namespaces.nodes[namespaceKey][rootKey]
      break
    end

    local rootNode = OPCUA.Server.Node.create(rootNodeData.class)
    rootNode:setID(rootNodeData.idType, rootNodeData.id)
    rootNode:setTypeDefinition(rootNodeData.nodeType)
    namespace:setRootNode(rootNode)

    opcuaServer_Model.currentNodes[namespaceKey] = {}
    opcuaServer_Model.currentNodes[namespaceKey][namespaceKey] = rootNode

    opcuaServer_Model.tempNodes[namespaceKey] = {} -- Does this work for multiple namespaces? TODO

    -- Add all nodes
    local suc = addAllNodes(rootNodeData.nodes, opcuaServer_Model.currentNodes[namespaceKey][namespaceKey], namespaceKey)
    if suc == false then
      _G.logger:warning(nameOfModule .. ": Something went wrong creating the nodes. Won't start the server.")
      return
    end

    -- Adding all created nodes to the namespace
    opcuaServer_Model.namespaces[#opcuaServer_Model.namespaces]:setNodes(opcuaServer_Model.tempNodes[namespaceKey])

  end

  opcuaServer_Model.server:setNamespaces(opcuaServer_Model.namespaces)

  local suc = opcuaServer_Model.server:start()
  opcuaServer_Model.isActive = suc
  if not suc then
    _G.logger:warning(nameOfModule .. ": Starting server did not work!")
  end
  Script.notifyEvent('OPCUAServer_OnNewStatusServerIsCurrentlyActive', opcuaServer_Model.isActive)
  --tmr:start()
end
opcuaServer_Model.startServer = startServer

local function stopServer()
  local suc = opcuaServer_Model.server:stop()
  opcuaServer_Model.server:resetAddressSpace()
  --tmr:stop()
  _G.logger:fine(nameOfModule .. ": Success to stop server: " .. tostring(suc))
  opcuaServer_Model.isActive = false
  Script.notifyEvent('OPCUAServer_OnNewStatusServerIsCurrentlyActive', opcuaServer_Model.isActive)
end
opcuaServer_Model.stopServer = stopServer


------------------------------------------
------------------------------------------
------------------------------------------
local value = 100
local function handleOnExpired()
  --print("Set " .. tostring(value))
  value = value + 1
  --opcuaServer_Model.currentNodes['NodeID']:setValue(value)

  --opcuaServer_Model.currentNodes['NodeIDNo2']:setValue(value-50)

  --opcuaServer_Model.currentNodes['NodeIDNo3']:setValue(value-50)

  --Actual notification of the event, which can be viewed in the client
  --local message = 'Begin Message Event ' .. value .. ' ' .. string.rep('x', 10) .. ' End Message Event ' .. value
  --print(message)
  --OPCUA.Server.Node.notifyEvent(opcuaServer_Model.currentNodes['NodeID123'], opcuaServer_Model.baseEventTypeNode, 'MEDIUM', message)
end
Timer.register(tmr, 'OnExpired', handleOnExpired)
------------------------------------------
------------------------------------------
------------------------------------------










--[[
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
]]

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return opcuaServer_Model
