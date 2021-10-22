SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET QUOTED_IDENTIFIER ON;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

/**************************Rename Indexes from Old AWQ to AWQ (that is empty)*****************************/
--Rename PK_ActivityWaitQueue_temp_QueueID_cl
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_old].PK_ActivityWaitQueue_temp_QueueID_cl', N'PK_ActivityWaitQueue_QueueID_cl_old', N'INDEX'; 

--Rename IX_ActivityWaitQueue_MID_ContactKey_IsProcessed_WaitEndDate_DefinitionID_IsActive
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_old].IX_ActivityWaitQueue_MID_ContactKey_IsProcessed_WaitEndDate_DefinitionID_IsActive', N'IX_ActivityWaitQueue_MID_ContactKey_IsProcessed_WaitEndDate_DefinitionID_IsActive_old', N'INDEX'; 

--Rename IX_ActivityWaitQueue_InstanceDefinitionId_Active_NotProcessed
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_old].IX_ActivityWaitQueue_InstanceDefinitionId_Active_NotProcessed', N'IX_ActivityWaitQueue_InstanceDefinitionId_Active_NotProcessed_old', N'INDEX'; 

--Rename IX_ActivityWaitQueue_WaitingForEventID_Status_ContactKey_ActivityId
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_old].IX_ActivityWaitQueue_WaitingForEventID_Status_ContactKey_ActivityId', N'IX_ActivityWaitQueue_WaitingForEventID_Status_ContactKey_ActivityId_old', N'INDEX'; 

--Rename IX_Q1RequestObjectId
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_old].IX_Q1RequestObjectId', N'IX_Q1RequestObjectId_old', N'INDEX'; 

--Rename IX_ActivityWaitQueue_ActivityId_WaitEndDate_MID_StatusFlags
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_old].IX_ActivityWaitQueue_ActivityId_WaitEndDate_MID_StatusFlags', N'IX_ActivityWaitQueue_ActivityId_WaitEndDate_MID_StatusFlags_old', N'INDEX'; 

--Rename IX_ActivityWaitQueue_StatusFlags_WaitEndDate_DefId_MID_INC_TimesP_ECLastChk_IsL_IsP_IsA_WFEventID_Status_Q1ReqObjId_WaitType
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_old].IX_ActivityWaitQueue_StatusFlags_WaitEndDate_DefId_MID_INC_TimesP_ECLastChk_IsL_IsP_IsA_WFEventID_Status_Q1ReqObjId_WaitType', N'IX_ActivityWaitQueue_StatusFlags_WaitEndDate_DefId_MID_INC_TimesP_ECLastChk_IsL_IsP_IsA_WFEventID_Status_Q1ReqObjId_WaitType_old', N'INDEX'; 

/**************************Rename Indexes from (that is empty) to AWQ old*****************************/
--Rename PK_ActivityWaitQueue_temp_QueueID_cl
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue].PK_ActivityWaitQueue_temp_QueueID_cl', N'PK_ActivityWaitQueue_QueueID_cl', N'INDEX'; 

--Rename IX_ActivityWaitQueue_temp_MID_ContactKey_IsProcessed_WaitEndDate_DefinitionID_IsActive
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue].IX_ActivityWaitQueue_temp_MID_ContactKey_IsProcessed_WaitEndDate_DefinitionID_IsActive', N'IX_ActivityWaitQueue_MID_ContactKey_IsProcessed_WaitEndDate_DefinitionID_IsActive', N'INDEX'; 

--Rename IX_ActivityWaitQueue_InstanceDefinitionId_Active_NotProcessed
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue].IX_ActivityWaitQueue_temp_InstanceDefinitionId_Active_NotProcessed', N'IX_ActivityWaitQueue_InstanceDefinitionId_Active_NotProcessed', N'INDEX'; 

--Rename IX_ActivityWaitQueue_WaitingForEventID_Status_ContactKey_ActivityId
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue].IX_ActivityWaitQueue_temp_WaitingForEventID_Status_ContactKey_ActivityId', N'IX_ActivityWaitQueue_WaitingForEventID_Status_ContactKey_ActivityId', N'INDEX'; 

--Rename IX_Q1RequestObjectId
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue].IX_Q1RequestObjectId_temp', N'IX_Q1RequestObjectId', N'INDEX';

--Rename IX_ActivityWaitQueue_temp_ActivityId_WaitEndDate_MID_StatusFlags
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue].IX_ActivityWaitQueue_temp_ActivityId_WaitEndDate_MID_StatusFlags', N'IX_ActivityWaitQueue_ActivityId_WaitEndDate_MID_StatusFlags', N'INDEX';

--Rename IX_ActivityWaitQueue_temp_StatusFlags_WaitEndDate_DefId_MID_INC_TimesP_ECLastChk_IsL_IsP_IsA_WFEventID_Status_Q1ReqObjId
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue].IX_ActivityWaitQueue_temp_StatusFlags_WaitEndDate_DefId_MID_INC_TimesP_ECLastChk_IsL_IsP_IsA_WFEventID_Status_Q1ReqObjId', N'IX_ActivityWaitQueue_StatusFlags_WaitEndDate_DefId_MID_INC_TimesP_ECLastChk_IsL_IsP_IsA_WFEventID_Status_Q1ReqObjId_WaitType', N'INDEX'; 

GO
/*####################################################################
$$Sproc:  Swap AWQ table indexes
$$Author: Jithendra Renati
$$History:  
			2021-10-22 - JRenati	Created
#####################################################################*/