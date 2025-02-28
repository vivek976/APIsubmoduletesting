USE [piHIRE1.0_QA]
GO
Alter PROCEDURE [dbo].[Sp_Dashboard_JobStage_recruiter]
	@jobId int,
	--Authorization
	@userType int,
	@userId int
AS
begin
	select 
		* 
	from 
		vwDashboardJobStageRecruiter with (nolock)
	where @jobId=jobId and
		( 
			(@userType = 1) or --SuperAdmin
			(@userType = 2 and jobId in (select JOID from PH_JOB_OPENINGS_ADDL_DETAILS jbDtl with(nolock) inner join [dbo].[vwUserPuBu] vw on /*jbDtl.BUID=vw.[BusinessUnit] and*/ jbDtl.PUID=vw.[ProcessUnit] and vw.UserId=@userId)) or --Admin
			(@userType = 3 and @userId = bdmId) or --BDM
			(@userType = 4 and @userId = recruiterID) --Recruiter
			--Candidate - 5
			--Hire manager PH_JOB_OPENINGS_ADDL_DETAILS
		)
	order by PostedDate,jobId desc
end





Alter view vwDashboardJobStageRecruiter
as
select distinct
	job.ID as jobId, coalesce(job.BroughtBy,job.createdby) bdmId, jobCand.recruiterID, job.PostedDate, 
	--stageCnt.Sourcing, stageCnt.Screening, stageCnt.Submission, stageCnt.Interview,  stageCnt.Offered, stageCnt.Hired,
	coalesce(usr.FirstName + ' '+ usr.LastName,'') recrName
from  
	[dbo].[PH_JOB_OPENINGS] job with (nolock)
	--inner join (
	--	select piv.JOID,piv.RecruiterID,piv.[1] as Sourcing, [2] as Screening, [3] as Submission, [4] as Interview, [5] as Offered, [6] as Hired
	--	from
	--	(
	--	  select JOID,RecruiterID, StageID, count(1) [Counter] from [PH_JOB_CANDIDATEs] with (nolock) group by JOID, RecruiterID, StageID
	--	) d
	--	pivot
	--	(
	--	  max([Counter])
	--	  for StageID in ([1], [2], [3], [4], [5], [6])
	--	) piv
	--) stageCnt on stageCnt.JOID=job.ID and job.status!=5
	inner join [PH_JOB_CANDIDATEs] jobCand with (nolock)  on jobCand.JOID=job.ID and job.status!=5
	inner join [dbo].[PI_HIRE_USERS] usr with (nolock) on usr.ID=jobCand.RecruiterID and usr.status!=5