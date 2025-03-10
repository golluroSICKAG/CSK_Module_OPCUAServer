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

-- Create parameters / instances for this module
opcuaServer_Model.styleForUI = 'None' -- Optional parameter to set UI style
opcuaServer_Model.version = Engine.getCurrentAppVersion() -- Version of module

opcuaServer_Model.isActive = false -- Status if OPC UA server is active
opcuaServer_Model.server = OPCUA.Server.create() -- OPC UA server handle
opcuaServer_Model.namespaces = {} -- Namespaces of OPC UA server
opcuaServer_Model.selectedNamespace = '' -- Name of selected namespace
opcuaServer_Model.selectedNamespaceIndex = 2 -- Selected namespace index
opcuaServer_Model.selectedNamespaceURL = '' -- Selected namespace URL, e.g. 
opcuaServer_Model.nodeReferences = {} -- List of available node references
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
opcuaServer_Model.onWriteFunctions = {} -- Function to handle if value was written by client

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
      newNode:setTypeDefinition(value.nodeType)
    elseif value.class == 'VARIABLE' then
      newNode:setDataType(value.dataType)
      newNode:setAccessLevel(value.accessLevel)
    end
    opcuaServer_Model.currentNodes[nameSpace][value.id] = newNode
    reference:addReference(value.referenceType, newNode)

    table.insert(opcuaServer_Model.tempNodes[nameSpace], opcuaServer_Model.currentNodes[nameSpace][value.id])

    local function setValue(newValue)
      opcuaServer_Model.currentNodes[nameSpace][value.id]:setValue(newValue)
    end
    opcuaServer_Model.setValueFunctions[value.id] = setValue

    local isServed = Script.isServedAsEvent('CSK_OPCUAServer.OnNewValueUpdate_' .. nameSpace .. '_' .. value.id)
    if not isServed then
      Script.serveEvent('CSK_OPCUAServer.OnNewValueUpdate_' .. nameSpace .. '_' .. value.id, 'OPCUAServer_OnNewValueUpdate_'  .. nameSpace .. '_' .. value.id, 'auto:?')
    end

    local function gotNewValue()
      local newValue = opcuaServer_Model.currentNodes[nameSpace][value.id]:getValue()
      Script.notifyEvent('OPCUAServer_OnNewValueUpdate_'  .. nameSpace .. '_' .. value.id, newValue)
    end
    opcuaServer_Model.onWriteFunctions[value.id] = gotNewValue
    local getSuc = OPCUA.Server.Node.register(newNode, "OnWrite", opcuaServer_Model.onWriteFunctions[value.id])

    if value.registeredEvent ~= '' and value.registeredEvent ~= nil then
      local suc = Script.register(value.registeredEvent, opcuaServer_Model.setValueFunctions[value.id])
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

  for namespaceKey, _ in pairs(opcuaServer_Model.parameters.namespaces.names) do
    local namespace = OPCUA.Server.Namespace.create() -- First namespace
    if opcuaServer_Model.parameters.namespaces.urls[namespaceKey] ~= '' then
      namespace:setIndex(opcuaServer_Model.parameters.namespaces.indexes[namespaceKey], opcuaServer_Model.parameters.namespaces.urls[namespaceKey])
    else
      namespace:setIndex(opcuaServer_Model.parameters.namespaces.indexes[namespaceKey])
    end

    local defaultNamespaceNode = OPCUA.Server.Namespace.getNodeFromStandardNamespace(namespace, "NUMERIC", 85)

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
    OPCUA.Server.Node.addReference(defaultNamespaceNode, 'ORGANIZES', opcuaServer_Model.currentNodes[namespaceKey][namespaceKey])

    opcuaServer_Model.tempNodes[namespaceKey] = {}

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
end
opcuaServer_Model.startServer = startServer

local function stopServer()
  local suc = opcuaServer_Model.server:stop()
  opcuaServer_Model.server:resetAddressSpace()
  _G.logger:fine(nameOfModule .. ": Success to stop server: " .. tostring(suc))
  opcuaServer_Model.isActive = false
  Script.notifyEvent('OPCUAServer_OnNewStatusServerIsCurrentlyActive', opcuaServer_Model.isActive)
end
opcuaServer_Model.stopServer = stopServer

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return opcuaServer_Model
