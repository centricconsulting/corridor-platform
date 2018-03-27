CREATE PROCEDURE calendar_rebuild
  @start_year int = 2010
, @end_year int = 2020
AS
BEGIN

  SET NOCOUNT ON

  DECLARE
    @source_key INT
  , @current_dt DATE
  , @last_dt DATE
  , @date_uid CHAR(8)
  , @first_of_month_weekday INT
  , @current_weekday INT
  , @week_of_month INT
 
  DECLARE 
	@unknown_key INT = 0
  , @unknown_text VARCHAR(20) = 'Unknown'
  , @extreme_key INT = 99999999
  , @extreme_text VARCHAR(20) = 'Indefinite'
  , @process_batch_key INT = 0;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- completely clear out the calendar table
  
  TRUNCATE TABLE calendar;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert zero key

	INSERT INTO calendar (
	  date_key
    , day_desc_01
	, day_desc_02
	, day_desc_03
	, day_desc_04
	, weekday_desc_01
	, weekday_desc_02
	, week_desc_01
	, week_desc_02
	, week_desc_03
	, semi_month_desc_01
	, semi_month_desc_02
	, month_desc_01
	, month_desc_02
	, month_desc_03
	, month_desc_04
	, quarter_desc_01
	, quarter_desc_02
	, quarter_desc_03
	, quarter_desc_04
	, year_desc_01
	, week_key
	, semi_month_key
	, month_key
	, quarter_key
	, year_key
  , process_batch_key
	) VALUES (
	  @unknown_key -- date_key
	, @unknown_text -- day_desc_01
	, @unknown_text -- day_desc_02
	, @unknown_text -- day_desc_03
	, @unknown_text -- day_desc_04
	, @unknown_text -- weekday_desc_01
	, @unknown_text -- weekday_desc_02
	, @unknown_text -- week_desc_01
	, @unknown_text -- week_desc_02
	, @unknown_text -- week_desc_03
	, @unknown_text -- semi_month_desc_01
	, @unknown_text -- semi_month_desc_02
	, @unknown_text -- month_desc_01
	, @unknown_text -- month_desc_02
	, @unknown_text -- month_desc_03
	, @unknown_text -- month_desc_04
	, @unknown_text -- quarter_desc_01
	, @unknown_text -- quarter_desc_02
	, @unknown_text -- quarter_desc_03
	, @unknown_text -- quarter_desc_04
	, @unknown_text -- year_desc_01
	, @unknown_key -- week_key
	, @unknown_key -- semi_month_key
	, @unknown_key -- month_key
	, @unknown_key -- quarter_key
	, @unknown_key -- year_key
	, @process_batch_key -- process_batch_key
	)

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- determine the start date, end date and source key
  -- NOTE: expanding range by one year FROM start and end...should be cleaned up at end

  SET @current_dt = CONVERT(date,CAST(@start_year-1 AS CHAR(4)) + '-01-01')
  SET @last_dt = CONVERT(date,CAST(@end_year+1 AS CHAR(4)) + '-12-31')
  
  SELECT @source_key = 1 -- x.source_key FROM source x where x.source_uid = 'STD'

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- loop and load basic values into calendar table
    
  WHILE @current_dt <= @last_dt
  BEGIN

    SET @date_uid = CONVERT(char(8),@current_dt,112)

	SET @first_of_month_weekday = DATEPART(weekday, (DATEFROMPARTS(YEAR(@current_dt), month(@current_dt), 1)));
	SET @week_of_month = FLOOR((DAY(@current_dt) + @first_of_month_weekday - 2) / 7) + 1;

    INSERT INTO calendar (
      date_key
    , [date]
    , day_of_week
    , day_of_semi_month --SEMI MONTH 
    , day_of_month
    , day_of_quarter
    , day_of_year
    , day_desc_01
    , day_desc_02
    , day_desc_03
    , day_desc_04
    , weekday_desc_01
    , weekday_desc_02
    , day_weekday_ct
    , week_key
    , week_start_dt
    , week_end_dt
    , week_day_ct
    , week_weekday_ct
    , week_desc_01
    , week_desc_02
    , week_desc_03
	, semi_month_key --SEMI MONTH 
	, semi_month_start_dt --SEMI MONTH 
	, semi_month_end_dt --SEMI MONTH 
	, semi_month_desc_01 --SEMI MONTH 
	, semi_month_desc_02 --SEMI MONTH 
    , month_key
    , month_start_dt
    , month_end_dt
    , month_of_quarter
    , month_of_year
    , month_desc_01
    , month_desc_02
    , month_desc_03
    , month_desc_04
    , month_day_ct
    , month_weekday_ct
    , quarter_key
    , quarter_start_dt
    , quarter_end_dt
    , quarter_of_year
    , quarter_desc_01
    , quarter_desc_02
    , quarter_desc_03
    , quarter_desc_04
    , quarter_month_ct
    , quarter_day_ct
    , quarter_weekday_ct
    , year_key
    , [year]
    , year_start_dt
    , year_end_dt
    , year_desc_01
    , year_month_ct
    , year_quarter_ct
    , year_day_ct
    , year_weekday_ct
    , process_batch_key
    ) VALUES (
      CONVERT(int,@date_uid) -- date_key
    , @current_dt -- date
    , DATEPART(weekday,@current_dt) -- day_of_week 
	, CASE WHEN DATEPART(day, @current_dt) BETWEEN 1 AND 15 THEN 1 ELSE 15 END -- day_of_semi_month

    , DATEPART(day,@current_dt) -- day_of_month
    , NULL -- day_of_quarter
    , DATEPART(dayofyear,@current_dt) -- day_of_year
    , CONVERT(char(10),@current_dt,101) -- day_desc_01 "12/31/2010"
    , SUBSTRING(@date_uid,7,2) + '-' + SUBSTRING(DATENAME(month,@current_dt),1,3) + '-' + SUBSTRING(@date_uid,1,4) -- day_desc_02 "31-Dec-2010"
    , SUBSTRING(@date_uid,1,4) + '.' + SUBSTRING(@date_uid,5,2) + '.' + SUBSTRING(@date_uid,7,2) -- day_desc_03 "2010.12.31"   
    , DATENAME(month,@current_dt) + ' ' + CAST(DAY(@current_dt) AS varchar(2)) + ', ' + CAST(YEAR(@current_dt) AS varchar(4)) -- day_desc_04 "December 31, 2010"
    , SUBSTRING(DATENAME(weekday,@current_dt),1,3) -- weekday_desc_01 "Wed"    
    , DATENAME(weekday,@current_dt) -- weekday_desc_02 "Wednesday"
    , CASE WHEN DATEPART(weekday,@current_dt) IN (1,7) THEN 0 ELSE 1 END -- day_weekday_ct
    , CONVERT(char(8),DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt),112) -- week_key
    , DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt) -- week_start_dt
    , DATEADD(d,7-DATEPART(weekday,@current_dt),@current_dt) -- week_end_dt
    , 7 -- week_day_ct
    , 5 -- week_weekday_ct
    , FORMAT(DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt), 'M/d/yyyy') -- week_desc_01
    , FORMAT(DATEADD(d,7-DATEPART(weekday,@current_dt),@current_dt), 'M/d/yyyy') -- week_desc_02
    , 'Week ' + FORMAT(DATEADD(d,1-DATEPART(weekday,@current_dt),@current_dt), 'M/d') + '-'
      + FORMAT(DATEADD(d,7-DATEPART(weekday,@current_dt),@current_dt), 'M/d') --  week_desc_03

	, CASE WHEN DATEPART(day, @current_dt) BETWEEN 1 AND 15 THEN  CONVERT(VARCHAR(10),YEAR(DATEADD(DAY, 1, EOMONTH(@current_dt, -1)))*10000 + MONTH(DATEADD(DAY, 1, EOMONTH(@current_dt, -1)))*100 + DAY('1900-01-01'), 112)
		   ELSE YEAR(DATEADD(DAY, 14, DATEADD(MONTH, DATEDIFF(MONTH, 0, @current_dt), 0)))*10000 + MONTH(DATEADD(DAY, 14, DATEADD(MONTH, DATEDIFF(MONTH, 0, @current_dt), 0)))*100 + DAY(DATEADD(DAY, 14, DATEADD(MONTH, DATEDIFF(MONTH, 0, @current_dt), 0))) 
		   END --  semi_month_key    
    , NULL -- semi_month_start_dt
    , NULL -- semi_month_end_dt
	, CASE WHEN DATEPART(day, @current_dt) BETWEEN 1 AND 15 THEN '1st'
		   ELSE '2nd'
		   END + ' Half ' + SUBSTRING(DATENAME(month,@current_dt),1,3) + '-' + CAST(YEAR(@current_dt) AS varchar(4)) -- semi_month_desc_01
    ,  CASE WHEN DATEPART(day, @current_dt) BETWEEN 1 AND 15 THEN '1st'
		   ELSE '2nd'
		   END + ' Half ' + DATENAME(month,@current_dt) + ' ' + CAST(YEAR(@current_dt) AS varchar(4)) -- semi_month_desc_02

    , YEAR(@current_dt)*100 + MONTH(@current_dt) -- month_key
    , NULL -- month_start_dt
    , NULL -- month_end_dt
    , CONVERT(int,(MONTH(@current_dt)-1)/3) + 1 -- month_of_quarter
    , MONTH(@current_dt) -- month_of_year
    , SUBSTRING(DATENAME(month,@current_dt),1,3) + '-' + CAST(YEAR(@current_dt) AS varchar(4)) -- month_desc_01
    , DATENAME(month,@current_dt) + ' ' + CAST(YEAR(@current_dt) AS varchar(4)) -- month_desc_02
    , SUBSTRING(DATENAME(month,@current_dt),1,3) -- month_desc_03
    , DATENAME(month,@current_dt) -- month_desc_04
    , NULL -- month_day_ct
    , NULL -- month_weekday_ct
    , YEAR(@current_dt)*100
	    + CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 4 
	      WHEN MONTH(@current_dt) >= 7 THEN 3
	      WHEN MONTH(@current_dt) >= 4 THEN 2
	      ELSE 1 END -- quarter_key
    , NULL -- quarter_start_dt
    , NULL -- quarter_end_dt
    ,  CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 4 
	      WHEN MONTH(@current_dt) >= 7 THEN 3
	      WHEN MONTH(@current_dt) >= 4 THEN 2
	      ELSE 1 END -- quarter_of_year
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 'Q4' 
	      WHEN MONTH(@current_dt) >= 7 THEN 'Q3'
	      WHEN MONTH(@current_dt) >= 4 THEN 'Q2'
	      ELSE 'Q1' END + '.' + CAST(YEAR(@current_dt) AS varchar(4)) -- quarter_desc_01
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN 'Q4' 
	      WHEN MONTH(@current_dt) >= 7 THEN 'Q3'
	      WHEN MONTH(@current_dt) >= 4 THEN 'Q2'
	      ELSE 'Q1' END -- quarter_desc_02
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN '4th' 
	      WHEN MONTH(@current_dt) >= 7 THEN '3rd'
	      WHEN MONTH(@current_dt) >= 4 THEN '2nd'
	      ELSE '1st' END   + ' Quarter, ' + CAST(YEAR(@current_dt) AS varchar(4))-- quarter_desc_03
    , CASE
	      WHEN MONTH(@current_dt) >= 10 THEN '4th' 
	      WHEN MONTH(@current_dt) >= 7 THEN '3rd'
	      WHEN MONTH(@current_dt) >= 4 THEN '2nd'
	      ELSE '1st' END   + ' Quarter' -- quarter_desc_04
    , 3 -- quarter_month_ct
    , NULL -- quarter_day_ct
    , NULL -- quarter_weekday_ct
    , YEAR(@current_dt)  -- year_key
    , YEAR(@current_dt)  -- year  
    , NULL -- year_start_dt
    , NULL -- year_end_dt
    , CAST(YEAR(@current_dt) AS varchar(4)) -- year_desc_01
    , 12 -- year_month_ct
    , 4 -- year_quarter_ct
    , NULL -- year_day_ct
    , NULL -- year_weekday_ct        
    , @process_batch_key -- process_batch_key
    );
        
    SET @current_dt = DATEADD(d,1,@current_dt)
    
  END
  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- update standard calendar counts and positions

  UPDATE cal SET
    month_day_ct = x.month_day_ct
  , month_weekday_ct = x.month_weekday_ct
  , month_start_dt = x.month_start_dt
  , month_end_dt = x.month_end_dt
  --, semi_month_key = x.semi_month_key
  , semi_month_start_dt = x.semi_month_start_dt
  , semi_month_end_dt = x.semi_month_end_dt
  --, semi_month_desc_01 = x.semi_month_desc_01
  , day_of_quarter = x.day_of_quarter
  , quarter_day_ct = x.quarter_day_ct
  , quarter_weekday_ct = x.quarter_weekday_ct
  , quarter_start_dt = x.quarter_start_dt
  , quarter_end_dt = x.quarter_end_dt  
  , year_day_ct = x.year_day_ct
  , year_weekday_ct = x.year_weekday_ct
  , year_start_dt = x.year_start_dt
  , year_end_dt = x.year_end_dt
  FROM
  calendar cal
  INNER JOIN (
	SELECT 
	date_key
	, csm.month_day_ct
	, csm.month_weekday_ct
	, csm.month_start_dt
	, csm.month_end_dt
	, csm.day_of_quarter
	, csm.quarter_day_ct
	, csm.quarter_weekday_ct
	, csm.quarter_start_dt
	, csm.quarter_end_dt
	, csm.year_day_ct
	, csm.year_weekday_ct
	, csm.year_start_dt
	, csm.year_end_dt
	--, csm.semi_month_key
	, csm.semi_month_start_dt
	, csm.semi_month_end_dt
	--, CASE WHEN @current_dt > csm.semi_month_end_dt  THEN 'Next Semi Months' 
 --       WHEN csm.[date] BETWEEN csm.semi_month_start_dt AND csm.semi_month_end_dt AND month_index = 0 THEN 'Current Semi Month' 
	--	WHEN @current_dt < csm.semi_month_start_dt  THEN 'Previous Semi Month' 
	--	END AS semi_month_desc_01


	FROM (
		 SELECT
		  date_key
		, cm.[date]
		, cm.month_day_ct
		, cm.month_weekday_ct
		, cm.month_start_dt
		, cm.month_end_dt
		, cm.day_of_quarter
		, cm.quarter_day_ct
		, cm.quarter_weekday_ct
		, cm.quarter_start_dt
		, cm.quarter_end_dt
		, cm.year_day_ct
		, cm.year_weekday_ct
		, cm.year_start_dt
		, cm.year_end_dt
		--, CASE WHEN DATE BETWEEN month_start_dt AND DATEADD(DD, 14, month_start_dt) THEN CONVERT(VARCHAR(10),YEAR(date)*10000 + MONTH(date)*100 + DAY('1900-01-01'), 112) 
		--	   ELSE CONVERT(VARCHAR(10),YEAR(date)*10000 + MONTH(date)*100 + DAY('1900-01-02'), 112) 
		--	   END semi_month_key
		, CASE WHEN DATE BETWEEN month_start_dt AND DATEADD(DD, 14, month_start_dt) THEN month_start_dt
			   ELSE DATEADD(DD, 15, month_start_dt)
			   END semi_month_start_dt
		, CASE WHEN DATE BETWEEN month_start_dt AND DATEADD(DD, 14, month_start_dt) THEN  DATEADD(DD, 14, month_start_dt)
			   ELSE month_end_dt
			   END semi_month_end_dt
		, month_index
	

		FROM (
			SELECT
			  date_key
			, [date]
			, [month_index]
			, COUNT(date_key) OVER (PARTITION BY month_key) AS month_day_ct
			, COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (PARTITION BY month_key) AS month_weekday_ct
			, MIN([date]) OVER (PARTITION BY month_key) AS month_start_dt
			, MAX([date]) OVER (PARTITION BY month_key) AS month_end_dt  
    
			, ROW_NUMBER() OVER (PARTITION BY quarter_key order by date_key) AS day_of_quarter
			, COUNT(date_key) OVER (PARTITION BY quarter_key) AS quarter_day_ct
			, COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (PARTITION BY quarter_key) AS quarter_weekday_ct  
			, MIN([date]) OVER (PARTITION BY quarter_key) AS quarter_start_dt
			, MAX([date]) OVER (PARTITION BY quarter_key) AS quarter_end_dt
      
			, COUNT(date_key) OVER (PARTITION BY year_key) AS year_day_ct
			, COUNT(CASE WHEN day_weekday_ct = 1 THEN date_key END) OVER (PARTITION BY year_key) AS year_weekday_ct
			, MIN([date]) OVER (PARTITION BY year_key) AS year_start_dt
			, MAX([date]) OVER (PARTITION BY year_key) AS year_end_dt
    
			FROM
			calendar
			) cm
		) csm
  ) x ON x.date_key = cal.date_key
  WHERE
  cal.date_key != 0;
  

   -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- delete extra calendar years expanded earlier
  
  DELETE FROM calendar WHERE
  (year = @start_year - 1 or year = @end_year + 1 )
  and date_key != 0;

  
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- insert the extreme date record

  INSERT INTO calendar (
	  date_key
	, day_desc_01
	, day_desc_02
	, day_desc_03
	, day_desc_04
	, weekday_desc_01
	, weekday_desc_02
	, week_desc_01
	, week_desc_02
	, week_desc_03
	, semi_month_desc_01  
	, semi_month_desc_02  
	, month_desc_01
	, month_desc_02
	, month_desc_03
	, month_desc_04
	, quarter_desc_01
	, quarter_desc_02
	, quarter_desc_03
	, quarter_desc_04
	, year_desc_01
	, week_key
	, semi_month_key
	, month_key
	, quarter_key
	, year_key
  , process_batch_key
	) VALUES (
	  @extreme_key -- date_key
	, @extreme_text -- day_desc_01
	, @extreme_text -- day_desc_02
	, @extreme_text -- day_desc_03
	, @extreme_text -- day_desc_04
	, @extreme_text -- weekday_desc_01
	, @extreme_text -- weekday_desc_02
	, @extreme_text -- week_desc_01
	, @extreme_text -- week_desc_02
	, @extreme_text -- week_desc_03
	, @extreme_text -- semi_month_desc_01
	, @extreme_text -- semi_month_desc_02
	, @extreme_text -- month_desc_01
	, @extreme_text -- month_desc_02
	, @extreme_text -- month_desc_03
	, @extreme_text -- month_desc_04
	, @extreme_text -- quarter_desc_01
	, @extreme_text -- quarter_desc_02
	, @extreme_text -- quarter_desc_03
	, @extreme_text -- quarter_desc_04
	, @extreme_text -- year_desc_01
	, @extreme_key -- week_key
	, @extreme_key -- semi_month_key
	, @extreme_key -- month_key
	, @extreme_key -- quarter_key
	, @extreme_key -- year_key
	, @process_batch_key -- process_batch_key
	)
       
END
