CREATE PROCEDURE solution()
BEGIN
    DECLARE oType varchar(45);
    DECLARE vName varchar(45);
    DECLARE vType varchar(45);
    DECLARE vBase varchar(45);
    DECLARE iCtr INTEGER default 1;
    DECLARE finished INTEGER DEFAULT 0;
    
DECLARE variable_cur CURSOR for 
    select var_name, type 
    from variables 
    where var_name is NOT NULL 
    and type IS NOT NULL;
    
    DECLARE CONTINUE HANDLER 
    FOR NOT FOUND SET finished = 1;
    
    DROP TABLE IF EXISTS numberTypes;
    CREATE TEMPORARY TABLE numberTypes 
    ( 
        var_name VARCHAR(45),
        var_type VARCHAR(45)
    );
    
   open variable_cur;            
   
   getVariables: LOOP
    
    FETCH variable_cur
    INTO vName, vType;
      
     IF finished = 1 THEN 
        LEAVE getVariables;
     END IF;
     
    set oType = vType;
    set iCtr = 1;
        
    getData: WHILE iCtr > 0 DO
    
    SELECT count(1) into iCtr 
    from numberTypes 
    where var_type = oType;
    
    IF iCtr > 0 THEN
            insert into numberTypes 
        values (vName, oType);
            set iCtr = 0;
            leave getData;
    END if;
    
    select count(1) into iCtr 
    from inheritance where 
    derived = vType;
       
       IF iCtr > 0 THEN 
        select base into vBase 
        from inheritance  
        where derived = vType;
    
        IF vBase = 'Number' then 
            insert into numberTypes 
        values (vName, oType);
            set iCtr = 0;
            leave getData;
        ELSE 
            set vType = vBase;
        END IF;
        
       END IF;
       
    END WHILE getData;
     
END LOOP getVariables;

select var_name, var_type from numberTypes;

CLOSE variable_cur;

END