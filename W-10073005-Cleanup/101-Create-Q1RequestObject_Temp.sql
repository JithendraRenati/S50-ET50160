--SQLMETA;Release:MCET_231;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = N'Q1RequestObject_temp' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN	
	CREATE TABLE InteractionStudio.Q1RequestObject_temp (
		Q1RequestObjectId				UNIQUEIDENTIFIER NOT NULL,
		Q1RequestObjectIsCompressed		BIT				NOT	NULL	DEFAULT 0,
		Q1RequestObject					NVARCHAR(max)	NULL,	
		Q1RequestObjectCompressed		VARBINARY(max)	NULL,
		Q1RequestObjectCompressionLevel SMALLINT		NULL,
		Q1RequestObjectCompressedSize	BIGINT			NULL,	
		Q1RequestObjectOriginalSize		BIGINT			NULL,
		Q1RequestObjectCompressedHash	VARBINARY(16)	NULL,
		Q1RequestObjectOriginalHash		VARBINARY(16)	NULL,
		MID								BIGINT			NOT NULL,
		EID								BIGINT			NOT NULL,
		CreatedDate						DATETIME		NOT NULL	DEFAULT(GETDATE()),
		Q1RequestObjectSourceMachine	NVARCHAR(128)	NULL		DEFAULT(HOST_NAME()),	

		CONSTRAINT PK_Q1RequestObject_temp_Q1RequestObjectId_cl PRIMARY KEY CLUSTERED (Q1RequestObjectId)
	)
	WITH (DATA_COMPRESSION = NONE);
END;
GO

--Configure the table to store BLOBs out of row. Based on test, this option resulted better Insert perforamnce.  
IF EXISTS(SELECT * FROM sys.tables WHERE object_id = OBJECT_ID('InteractionStudio.Q1RequestObject_temp') AND large_value_types_out_of_row <> 1)
BEGIN
	EXEC sp_tableoption 'InteractionStudio.Q1RequestObject_temp', 'large value types out of row', 1;  
END;
GO

/*##########################################################################################
$$Author: Jithendra Renati
$$Purpose: JB Q1 Store RequestObject BLOB in separate table
$$History:	
############################################################################################*/