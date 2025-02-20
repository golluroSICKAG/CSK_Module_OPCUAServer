-- Include all relevant FlowConfig scripts

--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Communiciaton.OPCUAServer.FlowConfig.OPCUAServer_Consumer')
require('Communiciaton.OPCUAServer.FlowConfig.OPCUAServer_Provider')
require('Communiciaton.OPCUAServer.FlowConfig.OPCUAServer_Process')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    if opcuaServer_Model.parameters.flowConfigPriority then
      CSK_OPCUAServer.clearFlowConfigRelevantConfiguration()
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)