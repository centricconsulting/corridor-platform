
CREATE PROCEDURE [dbo].[Queue_Problems_for_update]
AS

/*

This procedure de-duplicates the problem_monitoring table and compares the latest the latest entries
from Kindred_Audit_List and compares to the Problem_Monitoring table.  It will flag any problems ready
for update in Problem_Monitoring

*/

-- Remove Duplicates
DELETE FROM Problem_Monitoring
WHERE ProblemID IN
(
	SELECT ProblemID FROM
	(
	SELECT MRN, AssessmentDate, sfc_Agency__c, MIN(ProblemID) FirstID, COUNT(*) RecordCount
	FROM Problem_Monitoring
	GROUP BY MRN, AssessmentDate, sfc_Agency__c
	) DupAssessments
	INNER JOIN
	(
		SELECT ProblemID, MRN, AssessmentDate, sfc_Agency__c
		FROM Problem_Monitoring
		WHERE ProblemID NOT IN
		(
			SELECT FirstID FROM
			(
				SELECT MRN, AssessmentDate, sfc_Agency__c, MIN(ProblemID) FirstID, COUNT(*) RecordCount
				FROM Problem_Monitoring
				GROUP BY MRN, AssessmentDate, sfc_Agency__c
			) DA
			WHERE FirstID IS NOT NULL
		)
	) OtherAssessments
	ON DupAssessments.MRN = OtherAssessments.MRN
	AND DupAssessments.AssessmentDate = OtherAssessments.AssessmentDate
	AND DupAssessments.sfc_Agency__c = OtherAssessments.sfc_Agency__c
	WHERE DupAssessments.RecordCount > 1
)

-- Update Queued Status
UPDATE Problem_Monitoring
SET update_ready_ind = 1, update_status = 'Queued', modify_timestamp = GETDATE(), problem_resolved_timestamp = GETDATE()
WHERE update_ready_ind = 0
AND problem_resolved_timestamp IS NULL
AND update_timestamp IS NULL
AND MRN NOT IN
(
	SELECT MRN FROM Kindred_Audit_List
	WHERE MRN IS NOT NULL
)