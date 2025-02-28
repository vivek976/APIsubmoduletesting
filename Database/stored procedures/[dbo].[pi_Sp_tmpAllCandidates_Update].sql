CREATE OR ALTER PROCEDURE [dbo].[pi_Sp_tmpAllCandidates_Update]
AS
begin
    SET NOCOUNT ON;
	BEGIN TRAN

	BEGIN TRY
	
		delete dbo.tmpAllCandidates;
		insert into dbo.tmpAllCandidates
		--SELECT 
		--	--[PH_CANDIDATE_PROFILES]
		--	c.ID as CandProfID,
		--	c.SourceID,
		--	c.EmailID,
		--	c.CandName,
		--	c.FullNameInPP,
		--	c.DOB, 
		--	c.Gender, 
		--	c.MaritalStatus,
		--	c.CandOverallStatus as CandProfStatus,
		--	c.CurrOrganization, c.CurrLocation, c.CurrLocationID,
		--	c.NoticePeriod, 
		--	c.ReasonType, c.ReasonsForReloc,
		--	c.CountryID as CountryID,
		--	c.Nationality,
		--	c.Experience, c.ExperienceInMonths,
		--	c.RelevantExperience, c.ReleExpeInMonths,
		--	c.ContactNo, c.AlteContactNo,
		--	c.CreatedDate,c.UpdatedDate,
		--	c.CPCurrency, c.CPTakeHomeSalPerMonth, c.CPGrossPayPerAnnum,
		--	--[PH_JOB_CANDIDATES]
		--	ph.Id as CandJobId,
		--	ph.JoId,
		--	ph.StageId as StageID,
		--	ph.RecruiterID as RecruiterId,
		--	ph.EPCurrency as EPCurrency, ph.EPTakeHomePerMonth as EPTakeHomePerMonth,  
		--	ph.OpCurrency as OpCurrency,ph.OPGrossPayPerMonth as OpTakeHomePerMonth,
		--	--PH_COUNTRY
		--	Cuntry.nicename as CountryName, 
		--	--vwALLRecruiters
		--	CONCAT(RecUser.FirstName,' ',RecUser.LastName) as RecName,
		--	--none
		--	'' as CsCode,
		--	CASE
		--		WHEN CandOverallStatus = 3 THEN 'Blacklisted'
		--		WHEN CandOverallStatus = 2 THEN 'Joined'
		--		ELSE 'Available' END AS CandProfStatusName,	
		--	(select STUFF((select ','+ TaggingWord from [dbo].[PH_CANDIDATE_TAGS] as Tags  WITH(NOLOCK)
		--		where Tags.CandProfID = c.ID  and Status !=5  for xml path('')),1,1,'')) as TagWords,
		--	(select Convert(decimal(10,2),SUM(pjc.SelfRating)/Count(*)) from PH_CANDIDATE_SKILLSET as pjc
		--		where pjc.CandProfId = c.ID) as SelfRating,
		--	(select Convert(decimal(10,2),SUM(pjce.Rating)/Count(*)) from PH_JOB_CANDIDATE_EVALUATION as pjce
		--		where pjce.CandProfId = c.ID) as Evaluation
	
		--FROM 
		--	dbo.PH_CANDIDATE_PROFILES c 
		--	left outer join (
		--	  SELECT  Id,JoId,RecruiterID,StageId,EPCurrency,CandProfId, ROW_NUMBER() OVER (PARTITION BY CandProfId ORDER BY ID DESC) AS RowNumber,
		--	  EPTakeHomePerMonth,OpCurrency,OPGrossPayPerMonth
		--	  FROM dbo.PH_JOB_CANDIDATES  
		--	  --WHERE CandProfId = c.Id
		--	  --ORDER BY Id desc
		--	  ) ph on ph.CandProfId = c.Id and ph.RowNumber=1
		--	left join dbo.vwALLRecruiters as RecUser WITH(NOLOCK) on ph.RecruiterID = RecUser.Id
		--	left join dbo.PH_COUNTRY as Cuntry  WITH(NOLOCK) on c.CountryID = Cuntry.Id   
		--order by ph.Id/*CandJobId*/ desc

		select 
			--[PH_CANDIDATE_PROFILES]		
			CANDIDATE_PROFILE.ID as CandProfID,        --JOB_CANDIDATES.CandProfID,
			CANDIDATE_PROFILE.SourceID,
			CANDIDATE_PROFILE.EmailID,
			CANDIDATE_PROFILE.CandName, 
			CANDIDATE_PROFILE.FullNameInPP,
			CANDIDATE_PROFILE.DOB,
			(select RMValue from dbo.PH_REF_MASTER_S where id = CANDIDATE_PROFILE.Gender) AS Gender,
			(select RMValue from dbo.PH_REF_MASTER_S where id = CANDIDATE_PROFILE.MaritalStatus) AS MaritalStatus,
			CANDIDATE_PROFILE.CurrOrganization,  CANDIDATE_PROFILE.CurrLocation, CANDIDATE_PROFILE.CurrLocationID,
			CANDIDATE_PROFILE.NoticePeriod,
			CANDIDATE_PROFILE.ReasonType, CANDIDATE_PROFILE.ReasonsForReloc,
			CANDIDATE_PROFILE.CountryID,
			(select nicename from dbo.PH_COUNTRY where id = CANDIDATE_PROFILE.Nationality) AS Nationality,
			CANDIDATE_PROFILE.Experience, CANDIDATE_PROFILE.ExperienceInMonths,
			CANDIDATE_PROFILE.RelevantExperience, CANDIDATE_PROFILE.ReleExpeInMonths, 
			CANDIDATE_PROFILE.ContactNo, CANDIDATE_PROFILE.AlteContactNo,
			CANDIDATE_PROFILE.CreatedDate, 
			CANDIDATE_PROFILE.CPCurrency, CANDIDATE_PROFILE.CPTakeHomeSalPerMonth, CANDIDATE_PROFILE.CPGrossPayPerAnnum,
			--PH_JOB_CANDIDATES	
			JOB_CANDIDATES.CandProfStatus,
			JOB_CANDIDATES.UpdatedDate, 
			JOB_CANDIDATES.Id as CandJobId,	
			JOB_CANDIDATES.JoId,
			JOB_CANDIDATES.StageID,
			JOB_CANDIDATES.RecruiterId,
			JOB_CANDIDATES.EPCurrency as EPCurrency,
			JOB_CANDIDATES.EPTakeHomePerMonth as EPTakeHomePerMonth,
			JOB_CANDIDATES.OpCurrency as OpCurrency,
			JOB_CANDIDATES.OpGrossPayPerMonth as OpTakeHomePerMonth,
			--PH_COUNTRY
			Cuntry.nicename as CountryName,
			--PI_HIRE_USERS
			CONCAT(RecUser.FirstName,' ',RecUser.LastName) as RecName,
		
			--PH_CAND_STATUS_S CandProfStatusName 
			CAND_STATUS_S.CsCode,  
			CAND_STATUS_S.title as [CandProfStatusName],  -- no

			(select STUFF((select distinct ','+ TaggingWord from [dbo].[PH_CANDIDATE_TAGS] as Tags  WITH(NOLOCK)
				where Tags.JOID = JOB_CANDIDATES.JOID and Tags.CandProfID =JOB_CANDIDATES.CandProfID  
				and Status !=5  for xml path('')),1,1,'')) as TagWords,
			(select Convert(decimal(10,2),SUM(pjc.SelfRating)/Count(*)) from PH_JOB_CANDIDATES as pjc
				where pjc.CandProfId = CANDIDATE_PROFILE.ID) as SelfRating,
			(select Convert(decimal(10,2),SUM(pjce.Rating)/Count(*)) from PH_JOB_CANDIDATE_EVALUATION as pjce
				where  pjce.JoId = JOB_CANDIDATES.JoId and pjce.CandProfId = JOB_CANDIDATES.CandProfID) as Evaluation,

			(select STUFF((select distinct ','+ TaggingWord from [dbo].[PH_CANDIDATE_TAGS] as Tags  WITH(NOLOCK)
				where Tags.CandProfID = CANDIDATE_PROFILE.ID  and Status !=5  for xml path('')),1,1,'')) as [AllTagWords],
			(select Convert(decimal(10,2),SUM(pjc.SelfRating)/Count(*)) from PH_CANDIDATE_SKILLSET as pjc
				where pjc.CandProfId = CANDIDATE_PROFILE.ID) as [AllSelfRating],
			(select Convert(decimal(10,2),SUM(pjce.Rating)/Count(*)) from PH_JOB_CANDIDATE_EVALUATION as pjce
				where pjce.CandProfId = CANDIDATE_PROFILE.ID) as [AllEvaluation]
		from 
			dbo.PH_CANDIDATE_PROFILES as CANDIDATE_PROFILE 
			join (
				select * from (
					select *, row_number() over (
						partition by CandProfID
						order by CreatedDate desc
					) as row_num
					from dbo.PH_JOB_CANDIDATES
				) as ordered_widgets
				where ordered_widgets.row_num = 1
			) as JOB_CANDIDATES
				on CANDIDATE_PROFILE.ID = JOB_CANDIDATES.CandProfID
			join PH_CAND_STATUS_S as CAND_STATUS_S  WITH(NOLOCK) on JOB_CANDIDATES.CandProfStatus  = CAND_STATUS_S.Id
			left join PI_HIRE_USERS as RecUser on JOB_CANDIDATES.RecruiterID = RecUser.Id
			left join PH_COUNTRY as Cuntry  WITH(NOLOCK) on CANDIDATE_PROFILE.CountryID = Cuntry.Id 
		order by JOB_CANDIDATES.Id/*CandJobId*/ desc

		COMMIT TRAN
	END TRY
	BEGIN CATCH
	  ROLLBACK TRAN
	END CATCH
end



select *, row_number() over (
						
						order by CreatedDate desc
					) as row_num
					from dbo.PH_JOB_CANDIDATES