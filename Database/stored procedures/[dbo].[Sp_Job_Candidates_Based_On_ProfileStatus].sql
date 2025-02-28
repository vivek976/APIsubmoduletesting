
--CREATE OR ALTER PROCEDURE [dbo].[Sp_Job_Candidates_Based_On_ProfileStatusCount]
--    @searchKey NVARCHAR(MAX), 
--	@jobId int,
--	@profileStatus varchar(10)
--AS
--BEGIN
--    SELECT COUNT(1) AS CandidateCount
--    FROM
--        [dbo].PH_JOB_CANDIDATES AS JC WITH (NOLOCK)
--        JOIN [dbo].PH_CANDIDATE_PROFILES AS CP WITH (NOLOCK) ON JC.CandProfId = CP.Id
--        JOIN [dbo].PH_CAND_STATUS_S AS CS WITH (NOLOCK) ON JC.CandProfStatus = CS.Id
--        JOIN [dbo].PH_JOB_OPENINGS AS J WITH (NOLOCK) ON JC.JoId = J.Id
--        LEFT JOIN [dbo].[vwALLRecruiters] AS RU ON JC.RecruiterID = RU.Id
--        LEFT JOIN [dbo].PH_COUNTRY AS Cuntry WITH (NOLOCK) ON CP.CountryID = Cuntry.Id
--    WHERE
--        (1 = 1) AND 
--		(@jobId IS NULL OR JOID = @jobId) 
--        AND ((@profileStatus = 'FCV' AND (CS.CSCode = 'FCV' AND (JC.TLReview = 1 or JC.MReview =1)))
--		OR (@profileStatus != 'FCV' AND CS.CSCode = @profileStatus))           	
--        AND (@SearchKey IS NULL OR (JC.CandProfID LIKE '%' + @SearchKey + '%' 
--		OR CP.ContactNo LIKE '%' + @SearchKey + '%' 
--		OR CP.EmailID LIKE '%' + @SearchKey + '%' 
--		OR CP.CandName LIKE '%' + @SearchKey + '%'))    
   
--END
--Go

CREATE OR ALTER PROCEDURE [dbo].[Sp_Job_Candidates_Based_On_ProfileStatus]
    @searchKey NVARCHAR(MAX), 
	@jobId int,
	@profileStatus varchar(10),
    @fetchCount INT,
    @offsetCount INT
AS
BEGIN
    SELECT
        JC.Id AS CandJobId,
        JC.JoId,
        JC.CandProfID,
        SourceID,
        CP.EmailID,
        CP.CandName,
        CP.FullNameInPP,
        CP.DOB,
        (select RMValue from dbo.PH_REF_MASTER_S where id = CP.Gender) AS Gender,
        (select RMValue from dbo.PH_REF_MASTER_S where id = CP.MaritalStatus) AS MaritalStatus,
        JC.CandProfStatus,
        CS.title AS CandProfStatusName,
		stageLg.CandProfStatusAge,
        JC.StageID,
        CS.CsCode,
        CP.CurrOrganization,
        CP.CurrLocation,
        CP.CurrLocationID,
        CP.NoticePeriod,
        CP.CountryID,
        Cuntry.nicename AS CountryName,
        CP.ReasonType,
        CP.ReasonsForReloc,
        (select nicename from dbo.PH_COUNTRY where id = CP.Nationality) AS Nationality,
        CP.Experience,
        CP.ExperienceInMonths,
        CP.RelevantExperience,
        CP.ReleExpeInMonths,
        CP.ContactNo,
        CP.AlteContactNo,
        JC.RecruiterID AS RecruiterId,
        CONCAT(RU.FirstName, ' ', RU.LastName) AS RecName,
        CP.CPCurrency,
        CP.CPTakeHomeSalPerMonth,
        CP.CPGrossPayPerAnnum,
        JC.EPCurrency AS EPCurrency,
        JC.EPTakeHomePerMonth AS EPTakeHomePerMonth,
        JC.OpCurrency AS OpCurrency,
        JC.OpGrossPayPerMonth AS OpTakeHomePerMonth,
        CONVERT(DECIMAL(10, 2), JC.SelfRating) AS SelfRating,
        CONVERT(DECIMAL(10, 2), ISNULL((
            SELECT SUM(pjce.Rating) / COUNT(*)
            FROM [dbo].PH_JOB_CANDIDATE_EVALUATION AS pjce
            WHERE pjce.JoId = JC.JoId AND pjce.CandProfId = JC.CandProfID
        ), 0)) AS Evaluation,
        JC.CreatedDate AS CreatedDate,
        JC.UpdatedDate AS UpdatedDate,
        J.JobCategory,
		J.ClientID,
		JC.TLReview,
		JC.MReview,
		JC.L1Review
    FROM
        [dbo].PH_JOB_CANDIDATES AS JC WITH (NOLOCK)
        JOIN [dbo].PH_CANDIDATE_PROFILES AS CP WITH (NOLOCK) ON JC.CandProfId = CP.Id
        JOIN [dbo].PH_CAND_STATUS_S AS CS WITH (NOLOCK) ON JC.CandProfStatus = CS.Id
        JOIN [dbo].PH_JOB_OPENINGS AS J WITH (NOLOCK) ON JC.JoId = J.Id
        LEFT JOIN [dbo].[vwALLRecruiters] AS RU ON JC.RecruiterID = RU.Id
        LEFT JOIN [dbo].PH_COUNTRY AS Cuntry WITH (NOLOCK) ON CP.CountryID = Cuntry.Id
		CROSS APPLY (
			select top 1 CAST(DATEDIFF(DAY, lg.CreatedDate, GETDATE()) AS VARCHAR(10)) AS CandProfStatusAge from dbo.PH_ACTIVITY_LOG lg with(nolock) 
			where lg.JOID = JC.JoId and ActivityOn = JC.CandProfID and UpdateStatusID = JC.CandProfStatus
			 ORDER BY ID DESC
		) stageLg
    WHERE
        (1 = 1) AND 
		(@jobId IS NULL OR JOID = @jobId) 
        AND ((@profileStatus = 'FCV' AND (CS.CSCode = 'FCV' AND (JC.TLReview = 1 or JC.MReview =1)))
		OR (@profileStatus != 'FCV' AND CS.CSCode = @profileStatus))       	
        AND (@SearchKey IS NULL OR (JC.CandProfID LIKE '%' + @SearchKey + '%' 
		OR CP.ContactNo LIKE '%' + @SearchKey + '%' 
		OR CP.EmailID LIKE '%' + @SearchKey + '%' 
		OR CP.CandName LIKE '%' + @SearchKey + '%')) 
		
        
    ORDER BY       
        JC.Id DESC
    OFFSET @offsetCount ROWS FETCH NEXT @fetchCount ROWS ONLY;
END
