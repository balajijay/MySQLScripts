CREATE PROCEDURE solution()
BEGIN
    DECLARE finished INTEGER DEFAULT 0;       
    DECLARE zeroPos INTEGER DEFAULT 0;
    DECLARE xPos INTEGER DEFAULT 0;
    DECLARE tCount INTEGER DEFAULT 0;
    DECLARE tNameNaughts VARCHAR(100);
    DECLARE tNameCrosses VARCHAR(100);
    DECLARE tBoard VARCHAR(9);
    DECLARE tName VARCHAR(100);
    DECLARE tPlayed INTEGER DEFAULT 0;
    DECLARE tPoints INTEGER DEFAULT 0;
    DECLARE tWon INTEGER DEFAULT 0;
    DECLARE tDraw INTEGER DEFAULT 0;
    DECLARE tLost INTEGER DEFAULT 0;
    
    DECLARE result_Cur CURSOR FOR
    SELECT name_naughts, name_crosses, board 
    FROM results;
    
    DECLARE CONTINUE HANDLER 
    FOR NOT FOUND SET finished = 1;
    
    DROP TEMPORARY TABLE IF EXISTS winPositions;
    CREATE TEMPORARY TABLE winPositions (
        winningBoard    VARCHAR(9)
    );
    
    DROP TEMPORARY TABLE IF EXISTS outcome;
    CREATE TEMPORARY TABLE outcome (
        name VARCHAR(100),
        points INTEGER DEFAULT 0,
        played INTEGER DEFAULT 0,
        won  INTEGER DEFAULT 0,
        draw INTEGER DEFAULT 0,
        lost INTEGER DEFAULT 0
    );
    
    INSERT INTO winPositions values ('www......');
    INSERT INTO winPositions values ('...www...');
    INSERT INTO winPositions values ('......www');
    
    INSERT INTO winPositions values ('w..w..w..');
    INSERT INTO winPositions values ('.w..w..w.');
    INSERT INTO winPositions values ('..w..w..w');
    
    INSERT INTO winPositions values ('w...w...w');
    INSERT INTO winPositions values ('..w.w.w..');
    
    INSERT INTO outcome (name)
    select distinct name from (
        select name_naughts as name from results group by name_naughts
        union 
        select name_crosses as name from results group by name_crosses
    ) t1 ;
    
    open result_Cur;

getResults: LOOP
       FETCH result_Cur INTO 
       tNameNaughts, tNameCrosses, tBoard;
       
       IF finished = 1 THEN 
            LEAVE getResults;
        END IF;
       
       set tCount = 0;
       
       SELECT count(*) into tCount from winPositions 
       WHERE tBoard REGEXP replace(winningBoard, 'w', 'X');
       
       IF tCount > 0 THEN

           SELECT points, played, won into tPoints, 
           tPlayed, tWon from outcome where name = tNameCrosses; 
           
      update outcome
            set 
            points = tPoints + 2,
            played = tPlayed + 1,
            won = tWon + 1
            where name = tNameCrosses;
            
            SELECT points, played, lost into tPoints, 
            tPlayed, tLost from outcome where name = tNameNaughts;

            update outcome
            set 
            played = tPlayed + 1,
            lost = tLost + 1
            where name = tNameNaughts;
     
            
       ELSE 
       SELECT count(*) into tCount from winPositions 
       WHERE tBoard REGEXP replace(winningBoard, 'w', 'O');
       IF tCount > 0 THEN

       SELECT points, played, won into tPoints, 
       tPlayed, tWon from outcome where name = tNameNaughts;
            
            update outcome
            set 
            points = tPoints + 2,
            played = tPlayed + 1,
            won = tWon + 1
            where name = tNameNaughts;
            
            SELECT points, played, lost into tPoints, 
            tPlayed, tLost from outcome where name = tNameCrosses;

            update outcome
            set 
            played = tPlayed + 1,
            lost = tLost + 1
            where name = tNameCrosses;

        ELSE 
        
        SELECT points, played, draw into tPoints, 
            tPlayed, tDraw from outcome where 
            name = tNameCrosses;
            
            update outcome
            set 
            points = tPoints + 1,
            played = tPlayed + 1,
            draw = tDraw + 1
            where name = tNameCrosses;
        
        SELECT points, played, draw into tPoints, 
            tPlayed, tDraw from outcome where 
            name = tNameNaughts;
            
            update outcome
            set 
            points = tPoints + 1,
            played = tPlayed + 1,
            draw = tDraw + 1
            where name = tNameNaughts;

       END IF;   
       
       END IF;

    END LOOP getResults;
      
    close result_Cur;
    
    select name, points, played, won, draw, lost 
    from outcome 
    order by points desc, played, won desc, name;
END