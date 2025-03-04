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

--Script.serveEvent('CSK_OPCUAServer.OnNewResult', 'OPCUAServer_OnNewResult')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusModuleVersion', 'OPCUAServer_OnNewStatusModuleVersion')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusCSKStyle', 'OPCUAServer_OnNewStatusCSKStyle')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusModuleIsActive', 'OPCUAServer_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusEventToRegister', 'OPCUAServer_OnNewStatusEventToRegister')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusServerIsCurrentlyActive', 'OPCUAServer_OnNewStatusServerIsCurrentlyActive')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusServerActive', 'OPCUAServer_OnNewStatusServerActive')


Script.serveEvent('CSK_OPCUAServer.OnNewStatusInterfaceList', 'OPCUAServer_OnNewStatusInterfaceList')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusInterface', 'OPCUAServer_OnNewStatusInterface')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusPort', 'OPCUAServer_OnNewStatusPort')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusApplicationName', 'OPCUAServer_OnNewStatusApplicationName')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusApplicationURI', 'OPCUAServer_OnNewStatusApplicationURI')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusNamespaceIndex', 'OPCUAServer_OnNewStatusNamespaceIndex')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusNamespaceURL', 'OPCUAServer_OnNewStatusNamespaceURL')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusNamespaceExists', 'OPCUAServer_OnNewStatusNamespaceExists')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusNamespaceList', 'OPCUAServer_OnNewStatusNamespaceList')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusSelectedNamespace', 'OPCUAServer_OnNewStatusSelectedNamespace')

--Script.serveEvent('CSK_OPCUAServer.OnNewStatusNamespace', 'OPCUAServer_OnNewStatusNamespace')

--Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeTypeDefinition', 'OPCUAServer_OnNewStatusNodeTypeDefinition')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeID', 'OPCUAServer_OnNewStatusNodeID')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeIDType', 'OPCUAServer_OnNewStatusNodeIDType')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeType', 'OPCUAServer_OnNewStatusNodeType')

--Script.serveEvent('CSK_OPCUAServer.OnNewStatusIsRootNode', 'OPCUAServer_OnNewStatusIsRootNode')


Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeReferenceList', 'OPCUAServer_OnNewStatusNodeReferenceList')


Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeReference', 'OPCUAServer_OnNewStatusNodeReference')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeReferenceType', 'OPCUAServer_OnNewStatusNodeReferenceType')

Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeHasReference', 'OPCUAServer_OnNewStatusNodeHasReference')


Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeClass', 'OPCUAServer_OnNewStatusNodeClass')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeDataType', 'OPCUAServer_OnNewStatusNodeDataType')
Script.serveEvent('CSK_OPCUAServer.OnNewStatusNodeAccessLevel', 'OPCUAServer_OnNewStatusNodeAccessLevel')


Script.serveEvent('CSK_OPCUAServer.OnNewStatusAllNodesList', 'OPCUAServer_OnNewStatusAllNodesList')




Script.serveEvent('CSK_OPCUAServer.OnNewStatusFlowConfigPriority', 'OPCUAServer_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_OPCUAServer.OnNewStatusLoadParameterOnReboot", "OPCUAServer_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_OPCUAServer.OnPersistentDataModuleAvailable", "OPCUAServer_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_OPCUAServer.OnNewParameterName", "OPCUAServer_OnNewParameterName")
Script.serveEvent("CSK_OPCUAServer.OnDataLoadedOnReboot", "OPCUAServer_OnDataLoadedOnReboot")

Script.serveEvent('CSK_OPCUAServer.OnUserLevelOperatorActive', 'OPCUAServer_OnUserLevelOperatorActive')
Script.serveEvent('CSK_OPCUAServer.OnUserLevelMaintenanceActive', 'OPCUAServer_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_OPCUAServer.OnUserLevelServiceActive', 'OPCUAServer_OnUserLevelServiceActive')
Script.serveEvent('CSK_OPCUAServer.OnUserLevelAdminActive', 'OPCUAServer_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************
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

  Script.notifyEvent('OPCUAServer_OnNewStatusServerIsCurrentlyActive', opcuaServer_Model.isActive)
  Script.notifyEvent('OPCUAServer_OnNewStatusServerActive', opcuaServer_Model.parameters.active)

  Script.notifyEvent('OPCUAServer_OnNewStatusInterfaceList', opcuaServer_Model.ethernetPortsList)
  Script.notifyEvent('OPCUAServer_OnNewStatusInterface', opcuaServer_Model.parameters.interface)
  Script.notifyEvent('OPCUAServer_OnNewStatusPort', opcuaServer_Model.parameters.port)

  Script.notifyEvent('OPCUAServer_OnNewStatusApplicationName', opcuaServer_Model.parameters.applicationName)
  Script.notifyEvent('OPCUAServer_OnNewStatusApplicationURI', opcuaServer_Model.parameters.applicationURI)

  if opcuaServer_Model.selectedNamespace == '' then
    Script.notifyEvent('OPCUAServer_OnNewStatusNamespaceExists', false)
  else
    Script.notifyEvent('OPCUAServer_OnNewStatusNamespaceExists', true)
  end

  Script.notifyEvent('OPCUAServer_OnNewStatusNamespaceList', opcuaServer_Model.helperFuncs.createJsonList(opcuaServer_Model.parameters.namespaces.names))

  Script.notifyEvent('OPCUAServer_OnNewStatusSelectedNamespace', opcuaServer_Model.selectedNamespace)

  Script.notifyEvent('OPCUAServer_OnNewStatusNamespaceIndex', opcuaServer_Model.selectedNamespaceIndex)
  Script.notifyEvent('OPCUAServer_OnNewStatusNamespaceURL', opcuaServer_Model.selectedNamespaceURI)

  Script.notifyEvent('OPCUAServer_OnNewStatusNodeType', opcuaServer_Model.currentNodeType)
  --Script.notifyEvent('OPCUAServer_OnNewStatusNodeTypeDefinition', opcuaServer_Model.currentNodeTypeDefinition)
  --Script.notifyEvent('OPCUAServer_OnNewStatusIsRootNode', opcuaServer_Model.currentNodeIsRootNode)
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeReferenceList', opcuaServer_Model.helperFuncs.createJsonList(opcuaServer_Model.nodeReferences))
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeReference', opcuaServer_Model.currentNodeReference)

  if opcuaServer_Model.currentNodeReference == '' then
    Script.notifyEvent('OPCUAServer_OnNewStatusNodeHasReference', false)
  else
    Script.notifyEvent('OPCUAServer_OnNewStatusNodeHasReference', true)
  end

  Script.notifyEvent('OPCUAServer_OnNewStatusNodeReferenceType', opcuaServer_Model.currentNodeReferenceType)
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeClass', opcuaServer_Model.currentNodeClass)
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeIDType', opcuaServer_Model.currentNodeIDType)
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeID', opcuaServer_Model.currentNodeID)
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeDataType', opcuaServer_Model.currentNodeDataType)
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeAccessLevel', opcuaServer_Model.currentNodeAccessLevel)

  Script.notifyEvent('OPCUAServer_OnNewStatusAllNodesList', opcuaServer_Model.helperFuncs.createCustomJsonList(opcuaServer_Model.parameters.namespaces, opcuaServer_Model.selectedNamespace, ''))

  -- TODO Reference
  Script.notifyEvent("OPCUAServer_OnNewStatusEventToRegister", opcuaServer_Model.currentEventToRegister)

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

local function setInterface(interface)
  _G.logger:fine(nameOfModule .. ": Set interface to: " .. tostring(interface))
  opcuaServer_Model.parameters.interface = interface
end
Script.serveFunction('CSK_OPCUAServer.setInterface', setInterface)

local function setPort(port)
  _G.logger:fine(nameOfModule .. ": Set port to: " .. tostring(port))
  opcuaServer_Model.parameters.port = port
end
Script.serveFunction('CSK_OPCUAServer.setPort', setPort)

local function setApplicationName(name)
  _G.logger:fine(nameOfModule .. ": Set application name to: " .. tostring(name))
  opcuaServer_Model.parameters.applicationName = name
end
Script.serveFunction('CSK_OPCUAServer.setApplicationName', setApplicationName)

local function setApplicationURI(uri)
  _G.logger:fine(nameOfModule .. ": Set application URI to: " .. tostring(uri))
  opcuaServer_Model.parameters.applicationURI = uri
end
Script.serveFunction('CSK_OPCUAServer.setApplicationURI', setApplicationURI)

--TODO
local function setNamespace(name)
  
end

local function setNamespaceIndex(index)
  _G.logger:fine(nameOfModule .. ": Set namespace index to: " .. tostring(index))
  opcuaServer_Model.selectedNamespaceIndex = index
end
Script.serveFunction('CSK_OPCUAServer.setNamespaceIndex', setNamespaceIndex)

local function setNamespaceURL(url)
  _G.logger:fine(nameOfModule .. ": Set namespace URL to: " .. tostring(url))
  opcuaServer_Model.selectedNamespaceURI = url
end
Script.serveFunction('CSK_OPCUAServer.setNamespaceURL', setNamespaceURL)

local function addNamespaceViaUI()
  local namespaceName = 'NamespaceID_' .. tostring(opcuaServer_Model.selectedNamespaceIndex)
  if not opcuaServer_Model.parameters.namespaces.names[namespaceName] then

    opcuaServer_Model.selectedNamespace = namespaceName
    opcuaServer_Model.parameters.namespaces.names[namespaceName] = opcuaServer_Model.selectedNamespace
    opcuaServer_Model.parameters.namespaces.indexes[namespaceName] = opcuaServer_Model.selectedNamespaceIndex
    opcuaServer_Model.parameters.namespaces.urls[namespaceName] = ''
    opcuaServer_Model.parameters.namespaces.nodes[namespaceName] = {}

    Script.notifyEvent('OPCUAServer_OnNewStatusNamespaceExists', true)
    Script.notifyEvent('OPCUAServer_OnNewStatusNamespaceList', opcuaServer_Model.helperFuncs.createJsonList(opcuaServer_Model.parameters.namespaces.names))
    Script.notifyEvent('OPCUAServer_OnNewStatusSelectedNamespace', opcuaServer_Model.selectedNamespace)
  else
    _G.logger:warning(nameOfModule .. ": Namespace already exists! Choose other ID.")
  end
end
Script.serveFunction('CSK_OPCUAServer.addNamespaceViaUI', addNamespaceViaUI)

--TODO
--[[
local function setIsRootNode(status)
  _G.logger:fine(nameOfModule .. ": Is root node: " .. tostring(status))
  opcuaServer_Model.currentNodeIsRootNode = status
end
Script.serveFunction('CSK_OPCUAServer.setIsRootNode', setIsRootNode)
]]

--local function setNodeTypeDefinition(nodeType)
  --_G.logger:fine(nameOfModule .. ": Set node type definition to: " .. tostring(nodeType))
  --opcuaServer_Model.currentNodeTypeDefinition = nodeType
--end
--Script.serveFunction('CSK_OPCUAServer.setNodeTypeDefinition', setNodeTypeDefinition)

local function setNodeClass(class)
  _G.logger:fine(nameOfModule .. ": Set node class to: " .. tostring(class))
  opcuaServer_Model.currentNodeClass = class
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeClass', opcuaServer_Model.currentNodeClass)
end
Script.serveFunction('CSK_OPCUAServer.setNodeClass', setNodeClass)

local function setNodeType(nodeType)
  _G.logger:fine(nameOfModule .. ": Set node type definition to: " .. tostring(nodeType))
  opcuaServer_Model.currentNodeType = nodeType
  --[[
  _G.logger:fine(nameOfModule .. ": Set node type to: " .. tostring(nodeType))
  opcuaServer_Model.currentNodeType = nodeType
  if nodeType == 'ROOT' then
    --setIsRootNode(true)
    --opcuaServer_Model.currentNodeIsRootNode = true
    --opcuaServer_Model.currentNodeID = 'RootID'
    --setNodeClass('OBJECT')
    Script.notifyEvent('OPCUAServer_OnNewStatusNodeClass', opcuaServer_Model.currentNodeClass)
    Script.notifyEvent('OPCUAServer_OnNewStatusNodeID', opcuaServer_Model.currentNodeID)
  else
    --setIsRootNode(false)
    opcuaServer_Model.currentNodeIsRootNode = false
    opcuaServer_Model.currentNodeID = 'NodeID'
    setNodeClass('VARIABLE')
    Script.notifyEvent('OPCUAServer_OnNewStatusNodeClass', opcuaServer_Model.currentNodeClass)
    Script.notifyEvent('OPCUAServer_OnNewStatusNodeID', opcuaServer_Model.currentNodeID)
  end
  Script.notifyEvent('OPCUAServer_OnNewStatusNodeType', opcuaServer_Model.currentNodeType)
]]
end
Script.serveFunction('CSK_OPCUAServer.setNodeType', setNodeType)

local function setNodeIDType(idType)
  _G.logger:fine(nameOfModule .. ": Set node ID type to: " .. tostring(idType))
  opcuaServer_Model.currentNodeIDType = idType
end
Script.serveFunction('CSK_OPCUAServer.setNodeIDType', setNodeIDType)

local function setNodeID(id)
  _G.logger:fine(nameOfModule .. ": Set node ID to: " .. tostring(id))
  opcuaServer_Model.currentNodeID = id
end
Script.serveFunction('CSK_OPCUAServer.setNodeID', setNodeID)

local function setNodeDataType(dataType)
  _G.logger:fine(nameOfModule .. ": Set node data type to: " .. tostring(dataType))
  opcuaServer_Model.currentNodeDataType = dataType
end
Script.serveFunction('CSK_OPCUAServer.setNodeDataType', setNodeDataType)

local function setNodeAccessLevel(level)
  _G.logger:fine(nameOfModule .. ": Set node access level to: " .. tostring(level))
  opcuaServer_Model.currentNodeAccessLevel = level
end
Script.serveFunction('CSK_OPCUAServer.setNodeAccessLevel', setNodeAccessLevel)

local function setNodeReference(node)
  _G.logger:fine(nameOfModule .. ": Set node reference to: " .. tostring(node))
  opcuaServer_Model.currentNodeReference = node
  if opcuaServer_Model.currentNodeReference == '' then
    Script.notifyEvent('OPCUAServer_OnNewStatusNodeHasReference', false)
  else
    Script.notifyEvent('OPCUAServer_OnNewStatusNodeHasReference', true)
  end
end
Script.serveFunction('CSK_OPCUAServer.setNodeReference', setNodeReference)

local function setNodeReferenceType(refType)
  _G.logger:fine(nameOfModule .. ": Set node reference type to: " .. tostring(refType))
  opcuaServer_Model.currentNodeReferenceType = refType
end
Script.serveFunction('CSK_OPCUAServer.setNodeReferenceType', setNodeReferenceType)

--- Function to order nodes
local function checkForReferenceNode(data, reference, node)
  --[[
  for key, value in pairs(data) do
    if value.id then
      if value.id == reference then
        value.nodes[node.id] = node
        return
      end
    end
    if value.nodes then
      checkForReferenceNode(value, reference, node)
    end
  end
  ]]
  if data.id then
    if data.id == reference then
      data.nodes[node.id] = node
      return
    else
      if data.nodes then
        for key, value in pairs(data.nodes) do
          checkForReferenceNode(value, reference, node)
        end
      end
    end


  end
  return
end

local function addNodeViaUI()
  if not opcuaServer_Model.listOfNodeIDs[opcuaServer_Model.currentNodeID] then
    local rootExists = false
    local rootNodeID
    for rootKey, __ in pairs(opcuaServer_Model.parameters.namespaces.nodes[opcuaServer_Model.selectedNamespace]) do
      rootExists = true
      rootNodeID = rootKey
      break
    end
    if not rootExists and opcuaServer_Model.currentNodeClass ~= 'OBJECT' then
        _G.logger:warning(nameOfModule .. ": First create a node of type OBJECT!")
        return
    end
      local newNode = {}
      newNode.id = opcuaServer_Model.currentNodeID
      newNode.class = opcuaServer_Model.currentNodeClass
      newNode.idType = opcuaServer_Model.currentNodeIDType
      newNode.nodeType = opcuaServer_Model.currentNodeType
      newNode.dataType = opcuaServer_Model.currentNodeDataType
      newNode.accessLevel = opcuaServer_Model.currentNodeAccessLevel
      newNode.referenceType = opcuaServer_Model.currentNodeReferenceType

      if opcuaServer_Model.currentNodeClass == 'OBJECT' then
        newNode.nodes = {}
      else
        newNode.registeredEvent = opcuaServer_Model.currentEventToRegister
      end

      if rootExists then
        checkForReferenceNode(opcuaServer_Model.parameters.namespaces.nodes[opcuaServer_Model.selectedNamespace][rootNodeID], opcuaServer_Model.currentNodeReference, newNode)
      else
        opcuaServer_Model.parameters.namespaces.nodes[opcuaServer_Model.selectedNamespace][opcuaServer_Model.currentNodeID] = newNode
      end

    if opcuaServer_Model.currentNodeClass == 'OBJECT' then
      opcuaServer_Model.nodeReferences[opcuaServer_Model.currentNodeID] = opcuaServer_Model.currentNodeID
      Script.notifyEvent('OPCUAServer_OnNewStatusNodeReferenceList', opcuaServer_Model.helperFuncs.createJsonList(opcuaServer_Model.nodeReferences))
    end
    Script.notifyEvent('OPCUAServer_OnNewStatusAllNodesList', opcuaServer_Model.helperFuncs.createCustomJsonList(opcuaServer_Model.parameters.namespaces, opcuaServer_Model.selectedNamespace, ''))
    opcuaServer_Model.listOfNodeIDs[opcuaServer_Model.currentNodeID] = opcuaServer_Model.currentNodeID
  else
    _G.logger:warning(nameOfModule .. ": NodeID already exists! Change ID!")
  end
end
Script.serveFunction('CSK_OPCUAServer.addNodeViaUI', addNodeViaUI)

local function findNodeToDelete(data, node)
  for key, value in pairs(data) do
    if value.id then
      if value.id == node then
        if value.nodes then
          local hasSubNodes = false
          for _, __ in pairs(value.nodes) do
            hasSubNodes = true
            break
          end
          if hasSubNodes then
            _G.logger:warning(nameOfModule .. ": Won't delete node, as it still has sub nodes...")
          else
            value.nodes = {}
            data[key] = nil
            opcuaServer_Model.listOfNodeIDs[key] = nil
            if opcuaServer_Model.nodeReferences[key] then
              opcuaServer_Model.nodeReferences[key] = nil
            end
          end
        else
          data[key] = nil
          opcuaServer_Model.listOfNodeIDs[key] = nil
          if opcuaServer_Model.nodeReferences[key] then
            opcuaServer_Model.nodeReferences[key] = nil
          end
          return
        end
        return
      end
    end
    if value.nodes then
      findNodeToDelete(value.nodes, node)
    end
  end
  return
end

local function deleteNodeViaUI()
  if opcuaServer_Model.listOfNodeIDs[opcuaServer_Model.currentNodeID] then
    _G.logger:info(nameOfModule .. ": Delete node with ID " .. tostring(opcuaServer_Model.currentNodeID))
    findNodeToDelete(opcuaServer_Model.parameters.namespaces.nodes[opcuaServer_Model.selectedNamespace], opcuaServer_Model.currentNodeID)
  end
  pageCalled()
end
Script.serveFunction('CSK_OPCUAServer.deleteNodeViaUI', deleteNodeViaUI)

local function setServerActive(status)
  opcuaServer_Model.parameters.active = status
  if status == true then
    opcuaServer_Model.startServer()
  else
    opcuaServer_Model.stopServer()
  end
  Script.notifyEvent('OPCUAServer_OnNewStatusServerActive', opcuaServer_Model.parameters.active)
end
Script.serveFunction('CSK_OPCUAServer.setServerActive', setServerActive)

local tempResult = {}
local function searchForSubValue(selection)
  local foundPosStart, foundPosEnd = string.find(selection, ' // ')
  if foundPosStart then
    local tempNode = string.sub(selection, 1, foundPosStart-1)
    local newSelection = string.sub(selection, foundPosEnd+1, #selection)
    table.insert(tempResult, tempNode)
    searchForSubValue(newSelection)
  else
    table.insert(tempResult, selection)
  end
end

local function selectNodeViaUI(selection)
  local _, foundFullNode = string.find(selection, '"DTC_Node":"')
  if foundFullNode then
    local foundEndOfFullNode = string.find(selection, '"', foundFullNode+1)
    if foundFullNode then
      local subString = string.sub(selection, foundFullNode+1, foundEndOfFullNode-1)
      tempResult = {}
      searchForSubValue(subString)
    end
  end

  if #tempResult >= 1 then
    if #tempResult > 1 then
      opcuaServer_Model.currentNodeReference = tempResult[#tempResult-1]
    else
      opcuaServer_Model.currentNodeReference = ''
    end

    local subSelection = tempResult[1]
    local selectedNode = opcuaServer_Model.parameters.namespaces.nodes[opcuaServer_Model.selectedNamespace][subSelection]
    table.remove(tempResult, 1)
    for key, value in ipairs(tempResult) do
      selectedNode = selectedNode.nodes[value]
    end
    if selectedNode.id then
      opcuaServer_Model.currentNodeType = selectedNode.nodeType
      opcuaServer_Model.currentNodeIDType = selectedNode.idType
      opcuaServer_Model.currentNodeID = selectedNode.id
      opcuaServer_Model.currentNodeClass = selectedNode.class
      opcuaServer_Model.currentNodeReferenceType = selectedNode.referenceType
      if selectedNode.class == 'VARIABLE' then
        opcuaServer_Model.currentNodeDataType = selectedNode.dataType
        opcuaServer_Model.currentNodeAccessLevel = selectedNode.accessLevel
        opcuaServer_Model.currentEventToRegister = selectedNode.registeredEvent
      end

      Script.notifyEvent('OPCUAServer_OnNewStatusNodeReference', opcuaServer_Model.currentNodeReference)
      if opcuaServer_Model.currentNodeReference == '' then
        Script.notifyEvent('OPCUAServer_OnNewStatusNodeHasReference', false)
      else
        Script.notifyEvent('OPCUAServer_OnNewStatusNodeHasReference', true)
      end
      Script.notifyEvent('OPCUAServer_OnNewStatusNodeReferenceType', opcuaServer_Model.currentNodeReferenceType)
      Script.notifyEvent('OPCUAServer_OnNewStatusNodeType', opcuaServer_Model.currentNodeType)
      Script.notifyEvent('OPCUAServer_OnNewStatusNodeClass', opcuaServer_Model.currentNodeClass)
      Script.notifyEvent('OPCUAServer_OnNewStatusNodeIDType', opcuaServer_Model.currentNodeIDType)
      Script.notifyEvent('OPCUAServer_OnNewStatusNodeID', opcuaServer_Model.currentNodeID)
      Script.notifyEvent('OPCUAServer_OnNewStatusNodeDataType', opcuaServer_Model.currentNodeDataType)
      Script.notifyEvent('OPCUAServer_OnNewStatusNodeAccessLevel', opcuaServer_Model.currentNodeAccessLevel)
      Script.notifyEvent("OPCUAServer_OnNewStatusEventToRegister", opcuaServer_Model.currentEventToRegister)
    else
      _G.logger:warning(nameOfModule .. ": Selection went wrong.")
    end
  else
    _G.logger:warning(nameOfModule .. ": No Root ID available.")
  end
  Script.notifyEvent('OPCUAServer_OnNewStatusAllNodesList', opcuaServer_Model.helperFuncs.createCustomJsonList(opcuaServer_Model.parameters.namespaces, opcuaServer_Model.selectedNamespace, opcuaServer_Model.currentNodeID))
end
Script.serveFunction('CSK_OPCUAServer.selectNodeViaUI', selectNodeViaUI)

local function setEventToRegister(event)
  _G.logger:fine(nameOfModule .. ": Set event to register: " .. tostring(event))
  opcuaServer_Model.currentEventToRegister = event
end
Script.serveFunction('CSK_OPCUAServer.setEventToRegister', setEventToRegister)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_OPCUAServer.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  -- Insert code here to clear FlowConfig relevant actions
  --opcuaServer_Model.deregisterFromEvent()
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

