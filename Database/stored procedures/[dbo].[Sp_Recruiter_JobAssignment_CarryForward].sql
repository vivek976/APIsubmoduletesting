USE [piHIRE1.0_QA]
GO

CREATE OR ALTER PROCEDURE [dbo].[Sp_Recruiter_JobAssignment_CarryForward]
AS
BEGIN     
	SET NOCOUNT ON 
	DECLARE @curDt date = GETUTCDATE()
	DECLARE @chkDt date = DATEADD(DAY,-1, @curDt)
	
	DECLARE @tbl table(ID int, pendingCvs int)
	INSERT INTO @tbl
		SELECT ID, (NoCVSRequired-NoOfFinalCVsFilled) pendingCvs FROM DBO.PH_JOB_ASSIGNMENTS_DAY_WISE WHERE [Status] = 1 AND CAST([AssignmentDate] AS DATE) = @chkDt AND NoCVSRequired > NoOfFinalCVsFilled

	DECLARE @ID int, @NewID int, @pendingCvs int;
	WHILE EXISTS(SELECT 1 FROM @tbl)
	BEGIN
		SELECT TOP 1 @ID = ID, @pendingCvs = pendingCvs FROM @tbl
		PRINT @ID

		INSERT INTO [dbo].[PH_JOB_ASSIGNMENTS_DAY_WISE]
			([JOID],[AssignedTo],[NoCVSRequired],[Status],[CreatedBy],[AssignmentDate],[CreatedDate])
			SELECT 
				distinct OLD.[JOID], OLD.[AssignedTo],0,1,1,@curDt,GETUTCDATE() 
			FROM
				DBO.PH_JOB_ASSIGNMENTS_DAY_WISE OLD 
				LEFT OUTER JOIN DBO.PH_JOB_ASSIGNMENTS_DAY_WISE NW ON OLD.JOID = NW.JOID AND OLD.AssignedTo = NW.AssignedTo AND NW.Status=1 AND CAST(NW.[AssignmentDate] AS DATE) = @curDt
			WHERE OLD.ID = @ID AND NW.ID IS NULL

		SELECT 
			@NewID = NW.ID  
		FROM
			DBO.PH_JOB_ASSIGNMENTS_DAY_WISE OLD 
			INNER JOIN DBO.PH_JOB_ASSIGNMENTS_DAY_WISE NW ON OLD.JOID = NW.JOID AND OLD.AssignedTo = NW.AssignedTo AND NW.Status=1 AND CAST(NW.[AssignmentDate] AS DATE) = @curDt
		WHERE OLD.ID = @ID

		UPDATE DBO.PH_JOB_ASSIGNMENTS_DAY_WISE SET NoCVSRequired = NoCVSRequired - @pendingCvs, UpdatedBy = 1, UpdatedDate = GETUTCDATE() WHERE ID = @ID
		INSERT INTO [dbo].[PH_JOB_ASSIGNMENTS_DAY_WISE_LOG] ([JobAssignmentDayWiseId],[LogType],[NoCVSRequired])
		SELECT @ID, 1, @pendingCvs;
		
		UPDATE DBO.PH_JOB_ASSIGNMENTS_DAY_WISE SET NoCVSRequired = NoCVSRequired + @pendingCvs, UpdatedBy = 1, UpdatedDate = GETUTCDATE() WHERE ID = @NewID
		INSERT INTO [dbo].[PH_JOB_ASSIGNMENTS_DAY_WISE_LOG] ([JobAssignmentDayWiseId],[LogType],[NoCVSRequired])
		SELECT @NewID, 2, @pendingCvs;
		
		DELETE FROM @tbl WHERE ID = @ID
	END
END
GO
