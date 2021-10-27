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
/**************************Rename Indexes from Old ActivityWaitQueue_staging to ActivityWaitQueue_staging*****************************/
--Rename PK_ActivityWaitQueue_QueueID_cl
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_staging_old].PK_ActivityWaitQueue_staging_Id_cl', N'PK_ActivityWaitQueue_staging_Id_cl_old', N'INDEX'; 

/**************************Rename Indexes from (that is empty) to Q1RequestObject old*****************************/
EXEC sp_rename N'[InteractionStudio].[ActivityWaitQueue_staging].PK_ActivityWaitQueue_staging_tmp_Id_cl', N'PK_ActivityWaitQueue_staging_Id_cl', N'INDEX';

/*####################################################################
$$Sproc:  Swap Q1RequestObject table index
$$Author: Jithendra Renati
$$History:  
			2021-10-27 - JRenati	Created
#####################################################################*/