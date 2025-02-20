-- Block namespace
local BLOCK_NAMESPACE = 'ModuleName_FC.Consumer'
local nameOfModule = 'CSK_ModuleName'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function consume(handle, source)

  -- Optionally check for specific parameter
  local mode = Container.get(handle, 'Mode')

  -- Check incoming value
  if source then
    -- Do something like
    -- CSK_ModuleName.doSomething(source)
    -- or
    CSK_ModuleName.setEventToRegister(source)
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.consume', consume)

--*************************************************************
--*************************************************************

local function create(mode)

  -- Check if only one single instance is allowed
  if nil ~= instanceTable['Solo'] then
    _G.logger:warning(nameOfModule .. ": Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable['Solo'] = 'Solo'

    Container.add(handle, 'Mode', mode)
    return handle
  end

  -- OR
  --[[
  --local fullInstanceName = tostring(mode)

  -- Check for multiple instances if same instance is already configured
  if instanceTable[fullInstanceName] ~= nil then
    _G.logger:warning(nameOfModule .. "Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[fullInstanceName] = fullInstanceName
    Container.add(handle, 'Mode', mode)
    return handle
  end
  ]]
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)