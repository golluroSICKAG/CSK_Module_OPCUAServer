---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find helper functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

local funcs = {}
-- Providing standard JSON functions
funcs.json = require('Communication/OPCUAServer/helper/Json')

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

local nodeList = {}

local function addSubNodes(nodes, reference, currentSelection)
  local orderedTable = {}

  for n in pairs(nodes) do
    table.insert(orderedTable, n)
  end
  table.sort(orderedTable)

  for _, value in ipairs(orderedTable) do
    local isSelected = false
    if currentSelection == value then
      isSelected = true
    end
    table.insert(nodeList, {DTC_Node = reference .. ' // ' .. value, selected = isSelected})
    if nodes[value].nodes then
      addSubNodes(nodes[value].nodes, reference .. ' // ' .. nodes[value].id, currentSelection)
    end
  end
end

--- Create JSON list for dynamic table
---@param contentA string Lost of nodes
---@param namespaceIndex string Selected namespace index
---@param selectedParam string Currently selected parameter
---@return string jsonstring JSON string
local function createCustomJsonList(contentA, namespaceIndex, selectedParam)
  nodeList = {}
  local isSelected = false
  local entries = false

  local rootNodeData
  for rootKey, __ in pairs(contentA.nodes[namespaceIndex]) do
    rootNodeData = contentA.nodes[namespaceIndex][rootKey]
    break
  end

  if rootNodeData then
    if rootNodeData.id then
      for key, value in pairs(rootNodeData.nodes) do
        entries = true
        break
      end
      if rootNodeData.nodes == nil or entries == false then
        if selectedParam == rootNodeData.id then
          isSelected = true
        end
        nodeList = {{DTC_Node = rootNodeData.id, selected = isSelected},}
      else
        if selectedParam == rootNodeData.id then
          isSelected = true
        end
        table.insert(nodeList, {DTC_Node = rootNodeData.id, selected = isSelected})
        addSubNodes(rootNodeData.nodes, rootNodeData.id, selectedParam)
      end
    else
      nodeList = {{DTC_NodeID = '-', DTC_Node = '-'},}
    end
  else
    nodeList = {{DTC_NodeID = '-', DTC_Node = '-'},}
  end

  local jsonstring = funcs.json.encode(nodeList)
  return jsonstring
end
funcs.createCustomJsonList = createCustomJsonList

--- Function to create a list with numbers
---@param size int Size of the list
---@return string list List of numbers
local function createStringListBySize(size)
  local list = "["
  if size >= 1 then
    list = list .. '"' .. tostring(1) .. '"'
  end
  if size >= 2 then
    for i=2, size do
      list = list .. ', ' .. '"' .. tostring(i) .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySize = createStringListBySize

--- Function to convert a table into a Container object
---@param content auto[] Lua Table to convert to Container
---@return Container cont Created Container
local function convertTable2Container(content)
  local cont = Container.create()
  for key, value in pairs(content) do
    if type(value) == 'table' then
      cont:add(key, convertTable2Container(value), nil)
    else
      cont:add(key, value, nil)
    end
  end
  return cont
end
funcs.convertTable2Container = convertTable2Container

--- Function to convert a Container into a table
---@param cont Container Container to convert to Lua table
---@return auto[] data Created Lua table
local function convertContainer2Table(cont)
  local data = {}
  local containerList = Container.list(cont)
  local containerCheck = false
  if tonumber(containerList[1]) then
    containerCheck = true
  end
  for i=1, #containerList do

    local subContainer

    if containerCheck then
      subContainer = Container.get(cont, tostring(i) .. '.00')
    else
      subContainer = Container.get(cont, containerList[i])
    end
    if type(subContainer) == 'userdata' then
      if Object.getType(subContainer) == "Container" then

        if containerCheck then
          table.insert(data, convertContainer2Table(subContainer))
        else
          data[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck then
          table.insert(data, subContainer)
        else
          data[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck then
        table.insert(data, subContainer)
      else
        data[containerList[i]] = subContainer
      end
    end
  end
  return data
end
funcs.convertContainer2Table = convertContainer2Table

--- Function to get content list out of table
---@param data string[] Table with data entries
---@return string sortedTable Sorted entries as string, internally seperated by ','
local function createContentList(data)
  local sortedTable = {}
  for key, _ in pairs(data) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)
  return table.concat(sortedTable, ',')
end
funcs.createContentList = createContentList

--- Function to get content list as JSON string
---@param data string[] Table with data entries
---@return string sortedTable Sorted entries as JSON string
local function createJsonList(data)
  local sortedTable = {}
  for key, value in pairs(data) do
    table.insert(sortedTable, value)
  end
  table.sort(sortedTable)
  return funcs.json.encode(sortedTable)
end
funcs.createJsonList = createJsonList

--[[
--- Function to get content list as JSON string
---@param data string[] Table with data entries
---@return string sortedTable Sorted entries as JSON string
local function createJsonListOnKeys(data)
  local sortedTable = {}
  for key, _ in pairs(data) do
    table.insert(sortedTable, vakeylue)
  end
  table.sort(sortedTable)
  return funcs.json.encode(sortedTable)
end
funcs.createJsonListOnKeys = createJsonListOnKeys
]]
--- Function to create a list from table
---@param content string[] Table with data entries
---@return string list String list
local function createStringListBySimpleTable(content)
  local list = "["
  if #content >= 1 then
    list = list .. '"' .. content[1] .. '"'
  end
  if #content >= 2 then
    for i=2, #content do
      list = list .. ', ' .. '"' .. content[i] .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySimpleTable = createStringListBySimpleTable

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************