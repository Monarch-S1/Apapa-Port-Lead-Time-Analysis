-- Preview: First 1000 rows
SELECT
	TOP 1000 *
FROM port_data


-- Numerical column statistics (min, max, average)
SELECT 
	MAX(Clearance_Lead_days) AS MaximumClearanceDays, MIN(Clearance_Lead_Days) AS MinimumClearanceDays, CAST(ROUND(AVG(Clearance_lead_days),0 )AS INT)AS AverageClearanceDays,
	MAX(Dispatch_Lead_Days) AS MaximumDispatchDays, MIN(Dispatch_Lead_Days) AS MinimumDispatchDays, CAST(ROUND(AVG(Dispatch_Lead_Days), 0) AS INT) AS AverageDispatchDays ,
	MAX(Total_Lead_Days) AS MaximumTotalLeadDays, MIN(Total_Lead_Days) AS MinimumTotalLeadDays , CAST(ROUND(AVG(Total_Lead_Days), 0)AS INT) AS AverageTotalLeadDays
FROM port_data


-- Total shipment count
SELECT COUNT(Shipment_ID) AS Total_shipments
FROM port_data

--Shipment count by status
SELECT
	Status,
	COUNT(Shipment_ID) AS Total_shipments,
	COUNT(Shipment_ID) * 100 / (SELECT COUNT(*) From port_data p2) AS Percentage
FROM port_data
GROUP BY Status
ORDER BY Total_shipments

-- Clearance lead days by cargo type
SELECT
	Cargo_Type, 
	COUNT(shipment_ID) AS Total_shipments,
	CAST(ROUND(AVG(Clearance_Lead_Days),0) AS INT)AS Average_clearance_days
From port_data
Group by Cargo_Type
Order by Total_shipments DESC

-- Clearance lead days by container size
SELECT 
	Container_Size, 
	COUNT(shipment_ID) AS Total_shipments,
	CAST(ROUND(AVG(Clearance_Lead_Days),0) AS INT)AS Average_clearance_days
From port_data
Group by Container_Size
Order by Total_shipments DESC

-- Average total lead days — delayed only
SELECT 
    CAST(ROUND(AVG(Total_Lead_Days),0) AS INT)AS AverageTotalLeadDays
FROM port_data
Where Status like 'delayed%'

-- Average total lead days — cleared & dispatched only
SELECT 
    CAST(ROUND(AVG(Total_Lead_Days),0) AS INT)AS AverageTotalLeadDays
FROM port_data
WHERE status = 'Cleared & Dispatched'

-- Lead time breakdown by stage and status
SELECT
	Status,
	 CAST(ROUND(AVG(Total_Lead_Days), 0) AS INT)AS AverageTotalLeadDays,
	 CAST(ROUND(AVG(Clearance_Lead_Days), 0) AS INT) AS Average_clearance_lead_days,
	 CAST(ROUND(AVG(Dispatch_Lead_Days), 0) AS INT) AS Average_dispatch_lead_days
FROM port_data
WHERE Status LIKE 'delayed%' OR Status = 'Cleared & Dispatched'
GROUP BY status

-- Delayed shipment count and delay rate by cargo type
SELECT
	cargo_type,
	COUNT(Shipment_ID) AS Delayed_shipments,
	CAST(ROUND(COUNT(Shipment_ID) * 100 / 
	(SELECT COUNT(*) FROM port_data p2
	WHERE p2.Cargo_Type = port_data.Cargo_Type), 0) AS INT) AS Delay_rate_pct
FROM port_data
WHERE Status LIKE 'Delayed%'
GROUP BY Cargo_Type
ORDER BY Delayed_shipments DESC

	
-- Delayed shipment count and delay rate by container size
SELECT
	container_size,
	COUNT(Shipment_ID) AS Delayed_shipments,
	(SELECT COUNT (*) FROM port_data p2
	WHERE p2.Container_Size = port_data.Container_Size) AS Total_shipments,
	CAST(ROUND(COUNT(shipment_ID) * 100 /
	(SELECT COUNT(*) FROM port_data p2
	WHERE p2.Container_Size = port_data.Container_Size), 0) AS INT) AS Delay_rate_pct
FROM port_data
WHERE Status LIKE 'Delayed%'
GROUP BY Container_Size
ORDER BY Delayed_shipments DESC

-- Monthly delay trend
SELECT 
	YEAR(Vessel_Arrival) AS Arrival_year,
	MONTH(Vessel_Arrival) AS Arrival_month,
	(SELECT COUNT(shipment_ID) FROM port_data p2
	where p2.Status like 'delayed%'
	AND YEAR(p2.Vessel_Arrival) = YEAR(port_data.Vessel_Arrival)
	AND MONTH(p2.Vessel_Arrival) = MONTH(port_data.Vessel_Arrival)) AS delayed_shipments,
	COUNT(shipment_ID) AS total_shipments,
	CAST(ROUND(
    (SELECT COUNT(Shipment_ID) FROM port_data p2
     WHERE p2.Status LIKE 'delayed%'
     AND YEAR(p2.Vessel_Arrival) = YEAR(port_data.Vessel_Arrival)
     AND MONTH(p2.Vessel_Arrival) = MONTH(port_data.Vessel_Arrival)) 
    * 100 / COUNT(Shipment_ID), 0)
AS INT) AS Delay_rate_pct
FROM port_data
Group by 
	YEAR(Vessel_Arrival),MONTH(Vessel_Arrival)
ORDER BY
	YEAR(Vessel_Arrival),MONTH(Vessel_Arrival)
	
-- Delayed - Traffic vs Delayed - Customs comparison
SELECT 
	Status,
	COUNT(Shipment_ID) AS Total_shipments,
	CAST(ROUND(COUNT(Shipment_ID) * 100 / (SELECT COUNT(*) FROM Port_data p2), 0) AS INT) AS Percentage,
	CAST(ROUND(AVG(Clearance_Lead_Days), 0) AS INT)AS Average_Clearance_Lead_Time,
	CAST(ROUND(AVG(Dispatch_Lead_Days), 0) AS INT)AS Average_Dispatch_Lead_Time,
	CAST(ROUND(AVG(Total_Lead_Days), 0) AS INT )AS Total_Lead_Time
FROM port_data
WHERE Status like 'Delayed%'
GROUP BY Status

-- CriticL Shipment flagging
SELECT
	*,
	CASE WHEN Total_Lead_Days >= 15 THEN 'Critical' ELSE 'Normal' END AS Shipment_flag
FROM port_data
ORDER BY Total_Lead_Days