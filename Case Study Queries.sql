-- Description: Energy stability is one of the key themes the AEMR management team cares about. To ensure energy security and reliability, AEMR needs to understand the following:

-- Question 1: What are the most common outage types and how long do they tend to last?

SELECT
	Status
	,Reason
	,Count(*) as Total_Number_Outage_Events
	,ROUND(AVG((TIMESTAMPDIFF(MINUTE, Start_Time, End_Time)/60)/24),2) AS Average_Outage_Duration_Time_Days
	,YEAR(Start_Time) as Year
FROM
	AEMR
WHERE
	Status='Approved'
GROUP BY
	Status
	,Reason
	,YEAR(Start_Time)
ORDER BY
   YEAR(Start_Time)
	,Reason

-- Question 2: How frequently do the outages occur?

SELECT
	Status
	,Count(*) as Total_Number_Outage_Events
	,Month(Start_Time) as Month
	,Year(Start_Time) as Year
FROM
	AEMR
WHERE
	Status='Approved'
GROUP BY
	Status
	,Month(Start_Time)
	,Year(Start_Time)
ORDER BY
	Year(Start_Time)
	,Month(Start_Time)

-- Question 3: Are there any energy providers that have more outages than their peers which may indicate that these providers are unreliable?

SELECT
	Participant_Code
	,Status
	,Year(Start_Time) as Year
	,ROUND(AVG((TIMESTAMPDIFF(MINUTE, Start_Time, End_Time)/60)/24),2) AS Average_Outage_Duration_Time_Days
FROM
	AEMR
WHERE
	Status='Approved'
GROUP BY
	Participant_Code
	,Status
	,Year(Start_Time)
ORDER BY 
	Year(Start_Time)
	,CAST(Avg(CAST(TIMESTAMPDIFF(DAY,Start_Time,End_Time)AS DECIMAL(18,2))) AS DECIMAL(18,2)) DESC

-- Description: When an energy provider provides energy to the market, they are making a commitment to the market and saying; “We will supply X amount of energy to the market under a contractual obligation.” However, in a situation where the outages are forced, the energy provider intended to provide energy but is unable to provide energy and is forced offline. If many energy providers are forced offline at the same time, it could cause an energy security risk that AEMR needs to mitigate.

-- Question 4: Of the outage types in 2016 and 2017, what percent were forced outages?

SELECT
	SUM(CASE WHEN Reason = 'Forced' THEN 1 ELSE 0 END) as Total_Number_Forced_Outage_Events
	,Count(*) as Total_Number_Outage_Events
	,CAST((CAST(SUM(CASE WHEN Reason = 'Forced' THEN 1 ELSE 0 END)AS DECIMAL(18,2))/CAST(Count(*) AS DECIMAL(18,2)))*100 AS DECIMAL(18,2)) as Forced_Outage_Percentage
	,Year(Start_Time) as Year
FROM
	AEMR
WHERE
	Status = 'Approved'
GROUP BY
	Year(Start_Time)

-- Question 5: What was the average duration for a forced outage during both 2016 and 2017? Have we seen an increase in the average duration of forced outages?

SELECT 
	Status
	,Reason
	,Year(Start_Time) AS Year
	,ROUND(AVG(Outage_MW),2) AS Avg_Outage_MW_Loss
	,Cast(ROUND(AVG(Cast(TIMESTAMPDIFF(MINUTE, Start_Time, End_Time) AS DECIMAL(18,2))),2) AS DECIMAL(18,2)) AS Average_Outage_Duration_Time_Minutes
FROM 
	AEMR
WHERE 
	Status='Approved' 
GROUP BY 
	Status
	,Reason
	,Year(Start_Time)
ORDER BY 
	Year(Start_Time)
	,Reason

-- Question 6: Which energy providers tended to be the most unreliable?

SELECT 
	Participant_Code
	,Facility_Code
	,Status
	,Year(Start_Time) AS Year
	,ROUND(AVG(Outage_MW),2) AS Avg_Outage_MW_Loss
	,ROUND(SUM(Outage_MW),2) AS Summed_Energy_Lost
FROM 
	AEMR
WHERE 
	Status='Approved' 
	AND Reason='Forced'
GROUP BY 
	Participant_Code
	,Facility_Code
	,Status
	,Year(Start_Time)
ORDER BY 
	Year(Start_Time) ASC
	,ROUND(SUM(Outage_MW),2) DESC