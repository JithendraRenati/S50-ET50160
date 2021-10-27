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


IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'Q1RequestObject_temp' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'Q1RequestObject_temp does not exist', 1;
	RETURN;
END;

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'Q1RequestObject' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'Q1RequestObject does not exist', 1;
	RETURN;
END;

EXEC sp_rename 'InteractionStudio.Q1RequestObject' , 'Q1RequestObject_old';
EXEC sp_rename 'InteractionStudio.Q1RequestObject_temp' , 'Q1RequestObject';

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'Q1RequestObject_old' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'Q1RequestObject_old does not exist', 1;
	RETURN;
END;

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'Q1RequestObject' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'Q1RequestObject does not exist', 1;
	RETURN;
END;

/*####################################################################
$$Sproc:  Swap Q1RequestObject table with a temp table and rename 
$$Author: Jithendra Renati
$$History:  
			2021-10-27 - JRenati	Created
#####################################################################*/