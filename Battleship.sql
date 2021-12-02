



CREATE PROCEDURE solution()
BEGIN
    DECLARE min_id  INTEGER DEFAULT 0;
    DECLARE max_Id  INTEGER DEFAULT 0;
    DECLARE min_size INTEGER DEFAULT 0;
    DECLARE max_size INTEGER DEFAULT 0;
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE tid,x1,y1,x2,y2 INTEGER DEFAULT 0;
    DECLARE shipLocationCur CURSOR FOR 
    SELECT ID, UPPER_LEFT_X, UPPER_LEFT_Y, BOTTOM_RIGHT_X, BOTTOM_RIGHT_Y 
    FROM locations_of_ships;
    
   DECLARE CONTINUE HANDLER         
   FOR NOT FOUND SET finished = 1;
   
   DROP TEMPORARY TABLE IF EXISTS shipPoints;
    CREATE TEMPORARY TABLE shipPoints (
        ID INT, 
        X  INT, 
        Y  INT
    );
    DROP TEMPORARY TABLE IF EXISTS shipHit;
    CREATE TEMPORARY TABLE shipHit(
        ID  INT,
        HITS INT
    );
    
    DROP TEMPORARY TABLE IF EXISTS shipSize;
    CREATE TEMPORARY TABLE shipSize (
        id INT, 
        size INT
    );
    
    DROP TEMPORARY TABLE IF EXISTS shipResultData;
    CREATE TEMPORARY TABLE shipResultData (
            id      INT,
            shipsize    INT,
            hits    INT
    );
    
    DROP TEMPORARY TABLE IF EXISTS outcome;
    CREATE TEMPORARY TABLE outcome (
          ship_size  int, 
          undamaged int,
          partly_damaged int,
          sunk int
    );
    
    open shipLocationCur;

getShipLocation : LOOP
        FETCH shipLocationCur INTO tid, x1, y1, x2, y2;
        IF finished = 1 THEN 
            LEAVE getShipLocation;
        END IF;
        
        WHILE y1 = y2 and x1 <= x2 DO
        INSERT INTO shipPoints (ID, X, Y)
            VALUES (tid, x1, y1);
            set x1 = x1 + 1;
        END WHILE;
        
        WHILE x1 = x2 and y1 <= y2 DO
           INSERT INTO shipPoints (ID, X, Y)
            VALUES (tid, x1, y1);
            set y1 = y1 + 1;
        END WHILE;
        
     END LOOP getShipLocation;
     
     
     
     INSERT INTO shipSize (ID, SIZE)
     select id, count(id) from shipPoints group by id ORDER BY 2;
        
     select min(id) into min_id from shipPoints;
     select max(id) into max_id from shipPoints;
    
     WHILE min_id <= max_id DO
        INSERT INTO shipHit
        SELECT sp.id, count(os.id) from shipPoints sp left outer join opponents_shots os on sp.X = os.target_x and sp.Y = os.target_y where sp.id = min_id and os.id is not null group by sp.id;
     set min_id = min_id + 1;
     END WHILE;
     
     INSERT INTO shipResultData
     select s1.id, s1.size, coalesce(s2.hits, 0) as hit  from shipSize s1 left outer join shipHit s2 on s1.id = s2.id order by 2;
     
     close shipLocationCur;
     
     
     insert into outcome
     SELECT shipsize as size, 
     case 
        when hits = 0 then 1
        else 0
     end as undamaged,
     case 
        when hits > 0 and (shipSize > hits) then 1
        else 0
     end as partly_damaged, 
     case 
        when hits > 0 and (shipSize = hits) then 1
        else 0
     end as sunk
    FROM shipResultData;
    
    select ship_size as size, 
    sum(undamaged) as undamaged,
    sum(partly_damaged) as partly_damaged,
    sum(sunk) as sunk
    from outcome 
    group by ship_size order by 1;
       
END