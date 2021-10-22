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


IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_old' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue_old does not exist', 1;
	RETURN;
END;

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue does not exist', 1;
	RETURN;
END;

EXEC sp_rename 'InteractionStudio.ActivityWaitQueue' , 'ActivityWaitQueue_temp';
EXEC sp_rename 'InteractionStudio.ActivityWaitQueue_old' , 'ActivityWaitQueue';

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_temp' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue_temp does not exist', 1;
	RETURN;
END;

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue does not exist', 1;
	RETURN;
END;

/*####################################################################
$$Sproc:  Swap AWQ table with a temp table and rename 
$$Author: Varun Batra
$$History:  
			2021-10-22 - JRenati	Created
#####################################################################*/