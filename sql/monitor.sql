/***************************
Monitor progress of schema_patch and data_patch
****************************/

-- USE CostManagementDev
-- USE CostManagementQA
-- USE CostManagementDemo

EXECUTE [dbo].[sp_whoisactive]
    @show_sleeping_spids = 1
    , @show_system_spids = 0
    , @show_own_spid = 0
    , @get_full_inner_text = 1
    , @get_plans = 1
GO
