-- FUNCTION: "Outdoor_Activities".whereshouldigo(character varying)

-- DROP FUNCTION "Outdoor_Activities".whereshouldigo(character varying);

CREATE OR REPLACE FUNCTION "Outdoor_Activities".whereshouldigo(
	season character varying)
    RETURNS TABLE(parkid integer, parkname character varying, activityname character varying) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$
BEGIN
--Takes activities that can be done by one person, and tells you
--which park has that activity for the given season, with least people
--according to the log file
Return Query Select distinct(S3."ParkId"),S3."ParkName",S4."ActivityName" 
from (Select t."ActivityName",i."ActivityID", i."ParkId"
		from "Outdoor_Activities"."ParkDetails" as i, "Outdoor_Activities"."outdoor_single_activities" as t
		where i."ActivityID" = t."ActivityID"
	    and t."ActivitySeason" = season) as S4
join (Select S1."ParkId",S1."ParkName",S2."ActivityID"
		from (Select n."ParkId",n."ParkName"
			from "Outdoor_Activities"."ParkVisitorLog" as n
			where n."Season" = season
			group by n."ParkId",n."ParkName",n."VisitorLogCount"
			order by n."VisitorLogCount"
			limit 1) as S1
		inner join (Select distinct (i."ParkId"),i."ActivityID"
			from "Outdoor_Activities"."ParkDetails" as i) as S2
		on S1."ParkId" = S2."ParkId") as S3
on S3."ActivityID" = S4."ActivityID";

END
$BODY$;

ALTER FUNCTION "Outdoor_Activities".whereshouldigo(character varying)
    OWNER TO postgres;
