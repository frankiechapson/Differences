
/* PKG DIFF uses these */ 

create or replace type T_STRING_LIST as table of varchar2( 32000 );
/

create or replace function F_CSV_TO_LIST ( I_CSV_STRING    in varchar2
                                         , I_SEPARATOR     in varchar2   := ','
                                         , I_ENCLOSED_BY   in varchar2   := null
                                         ) return T_STRING_LIST PIPELINED is
/* *****************************************************************************************************

    The F_CSV_TO_LIST is a "smart" string list separated by strings, optionally enclosed by string parser.    
    if the separator/delimiter is between enclosers, then the separator will be the part of the field.
    if the encloser is not closed or not started then the encloser will be the part of the field.

    Parameters:
    -----------
    I_CSV_STRING        the ( delimited and optionally enclosed ) string to parse
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)

    Samples:
    -------
    select * from table( F_CSV_TO_LIST ( '1,2,3,1415', ',' ) )

    select * from table( F_CSV_TO_LIST ( '"1,2","3,1415"', ',' ) )

    select * from table( F_CSV_TO_LIST ( '"1,2","3,1415"', ',', '"' ) )


    Results:
    -------
    1
    2
    3
    1415

    "1
    2"
    "3
    1415"

    1,2 
    3,1415

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

******************************************************************************************************* */

    V_INSIDE            boolean           := false;
    V_CSV               varchar2( 32000 ) := I_CSV_STRING;
    V_FIELD             varchar2( 32000 );
    V_SEPARATOR         varchar2(   300 ) := nvl( I_SEPARATOR, ',' );

begin

    loop

        if V_CSV is null then
            PIPE ROW( V_FIELD );
            exit;
        end if;

        if not V_INSIDE then

            -- did we reach a separator outside?
            if substr( V_CSV , 1 , length( V_SEPARATOR ) ) = V_SEPARATOR  then
                V_CSV    := substr( V_CSV, length( V_SEPARATOR ) + 1 );
                PIPE ROW( V_FIELD );
                V_FIELD  := '';

            -- a new field starts with "enclosed by"
            elsif substr( V_CSV, 1 , length( I_ENCLOSED_BY ) ) = I_ENCLOSED_BY then

                V_CSV    := substr( V_CSV, length( I_ENCLOSED_BY ) + 1 );
                V_INSIDE := true;
                V_FIELD  := I_ENCLOSED_BY;

            -- a new field starts
            else
                V_FIELD  := substr( V_CSV, 1 , 1 );
                V_CSV    := substr( V_CSV, 2 );
                V_INSIDE := true;
            end if;
        
        else  -- inside

            -- did we reach the end of field 
            if ( I_ENCLOSED_BY is null or substr( V_FIELD, 1, length( I_ENCLOSED_BY ) ) != I_ENCLOSED_BY )
                 and substr( V_CSV, 1, length( V_SEPARATOR ) ) = V_SEPARATOR then

                V_CSV    := substr( V_CSV, length( V_SEPARATOR ) + 1 );
                PIPE ROW( V_FIELD );
                V_INSIDE := false;
                V_FIELD  := '';

            -- did we reach the end of field with an "enclosed by"
            elsif      substr( V_CSV , 1                          , length( I_ENCLOSED_BY ) )                = I_ENCLOSED_BY and 
                  nvl( substr( V_CSV , length( I_ENCLOSED_BY ) + 1, length( V_SEPARATOR   ) ), V_SEPARATOR ) = V_SEPARATOR   then

                V_CSV    := substr( V_CSV, length( I_ENCLOSED_BY ) + 1 );
                V_FIELD  := V_FIELD||I_ENCLOSED_BY;
                -- if the field is really enclosed, then we remove the enclose strings
                if substr( V_FIELD, 1, length( I_ENCLOSED_BY ) ) = I_ENCLOSED_BY and
                   substr( V_FIELD, -length( I_ENCLOSED_BY )   ) = I_ENCLOSED_BY then
                    V_FIELD := substr( V_FIELD, length( I_ENCLOSED_BY ) + 1, length( V_FIELD ) - 2 * length( I_ENCLOSED_BY ) );
                end if;
                V_INSIDE := false;
            
            -- just add it to the field
            else
                V_FIELD  := V_FIELD || substr( V_CSV, 1 , 1 );
                V_CSV    := substr( V_CSV, 2 );
            end if;

        end if;

    end loop;

    return;

end;
/



create or replace function F_SELECT_ROWS_TO_CSV ( I_SELECT              in varchar2  
                                                , I_SEPARATOR           in varchar2   := ','
                                                , I_ENCLOSED_BY         in varchar2   := null
                                                ) return varchar2 is
/* *******************************************************************************************************

    The F_SELECT_ROWS_TO_CSV function returns with a CSV generated from the exactly one column of the select statement.
    Similar to LISTAGG function.

    Parameters:
    -----------
    I_SELECT            the select to transform to CSV string
    I_SEPARATOR         the field separator/delimiter
    I_ENCLOSED_BY       the optional encloser (both left and right)


    Sample:
    -------
    select CODE, F_SELECT_ROWS_TO_CSV( 'select NAME from CA_WEEK_DAYS where CALENDAR_TYPE_CODE='''||CALENDAR_TYPE_CODE||'''' ) as WEEK_DAYS from CA_CALENDARS

    Result:
    -------
    CODE        WEEK_DAYS
    AMERICAN	Friday,Monday,Saturday,Sunday,Thursday,Tuesday,Wednesday
    HUNGARIAN	Friday,Monday,Saturday,Sunday,Thursday,Tuesday,Wednesday
    SAUIDI	    Gathering day,Second day,Day of Rest,First day,Fifth day,Third day,Fourth day

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

******************************************************************************************************* */


    V_CURSOR            sys_refcursor;
    V_STRING            varchar2( 32000 ) := '';
    V_CSV_STRING        varchar2( 32000 ) := '';
    V_SEPARATOR         varchar2( 32000 );

begin

    open V_CURSOR for I_SELECT;
    loop

        fetch V_CURSOR into V_STRING;
        exit when V_CURSOR%notfound;

        V_CSV_STRING := V_CSV_STRING || V_SEPARATOR || I_ENCLOSED_BY || V_STRING || I_ENCLOSED_BY;
        V_SEPARATOR  := nvl(I_SEPARATOR,',');

    end loop;

    close V_CURSOR;

    return V_CSV_STRING;

end;
/




create or replace package PKG_DIFF as


/* *******************************************************************************************************

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

******************************************************************************************************* */


    ------------------------------------------------------------------------------------

    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN VARCHAR2                   , i_new_value IN VARCHAR2                   ) RETURN BOOLEAN;
    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN NUMBER                     , i_new_value IN NUMBER                     ) RETURN BOOLEAN;
    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN DATE                       , i_new_value IN DATE                       ) RETURN BOOLEAN;
    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN TIMESTAMP                  , i_new_value IN TIMESTAMP                  ) RETURN BOOLEAN;
    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN TIMESTAMP WITH TIME ZONE   , i_new_value IN TIMESTAMP WITH TIME ZONE   ) RETURN BOOLEAN;

    ------------------------------------------------------------------------------------

    FUNCTION  LISTS_ARE_DIFFER ( i_old_list    IN VARCHAR2 , i_new_list  IN VARCHAR2 
                               , i_separator   IN VARCHAR2   := ':'
                               , i_enclosed_by IN VARCHAR2   := NULL
                               ) RETURN BOOLEAN;
  
    ------------------------------------------------------------------------------------
 
    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN VARCHAR2                    ) RETURN BOOLEAN;
    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN NUMBER                      ) RETURN BOOLEAN;
    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN DATE                        ) RETURN BOOLEAN;
    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN TIMESTAMP                   ) RETURN BOOLEAN;
    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN TIMESTAMP WITH TIME ZONE    ) RETURN BOOLEAN;

    ------------------------------------------------------------------------------------

end;
/



create or replace package body PKG_DIFF as

/* *******************************************************************************************************

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

******************************************************************************************************* */

    ------------------------------------------------------------------------------------

    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN VARCHAR2, i_new_value IN VARCHAR2 ) RETURN BOOLEAN IS
    BEGIN
        IF (i_old_value IS NOT NULL AND i_new_value IS     NULL) OR
           (i_old_value IS     NULL AND i_new_value IS NOT NULL) OR
           (i_old_value IS NOT NULL AND i_new_value IS NOT NULL  AND i_old_value <> i_new_value ) THEN
          RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;
   
    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN NUMBER, i_new_value IN NUMBER ) RETURN BOOLEAN IS
    BEGIN
        IF (i_old_value IS NOT NULL AND i_new_value IS     NULL) OR
           (i_old_value IS     NULL AND i_new_value IS NOT NULL) OR
           (i_old_value IS NOT NULL AND i_new_value IS NOT NULL  AND i_old_value <> i_new_value ) THEN
          RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;
   
    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN DATE, i_new_value IN DATE ) RETURN BOOLEAN IS
    BEGIN
        IF (i_old_value IS NOT NULL AND i_new_value IS     NULL) OR
           (i_old_value IS     NULL AND i_new_value IS NOT NULL) OR
           (i_old_value IS NOT NULL AND i_new_value IS NOT NULL  AND i_old_value <> i_new_value ) THEN
          RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;
   
    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN TIMESTAMP, i_new_value IN TIMESTAMP ) RETURN BOOLEAN IS
    BEGIN
        IF (i_old_value IS NOT NULL AND i_new_value IS     NULL) OR
           (i_old_value IS     NULL AND i_new_value IS NOT NULL) OR
           (i_old_value IS NOT NULL AND i_new_value IS NOT NULL  AND i_old_value <> i_new_value ) THEN
          RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;

    FUNCTION  VALUES_ARE_DIFFER ( i_old_value IN TIMESTAMP WITH TIME ZONE, i_new_value IN TIMESTAMP WITH TIME ZONE ) RETURN BOOLEAN IS
    BEGIN
        IF (i_old_value IS NOT NULL AND i_new_value IS     NULL) OR
           (i_old_value IS     NULL AND i_new_value IS NOT NULL) OR
           (i_old_value IS NOT NULL AND i_new_value IS NOT NULL  AND i_old_value <> i_new_value ) THEN
          RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;

    ------------------------------------------------------------------------------------

    FUNCTION  LIST_DIFFS ( i_list_1      IN VARCHAR2 , i_list_2  IN VARCHAR2 
                         , i_separator   IN VARCHAR2   := ':'
                         , i_enclosed_by IN VARCHAR2   := NULL
                         ) RETURN VARCHAR2 IS
    BEGIN
        RETURN F_SELECT_ROWS_TO_CSV( 'SELECT * FROM TABLE( F_CSV_TO_LIST ( '''||i_list_1||''', '''||i_separator||''', '''||i_enclosed_by||''')) MINUS SELECT * FROM TABLE( F_CSV_TO_LIST ( '''||i_list_2||''', '''||i_separator||''', '''||i_enclosed_by||''')) order by 1', i_separator, i_enclosed_by);
    END;


    FUNCTION  LISTS_ARE_DIFFER ( i_old_list    IN VARCHAR2 , i_new_list  IN VARCHAR2 
                               , i_separator   IN VARCHAR2   := ':'
                               , i_enclosed_by IN VARCHAR2   := NULL
                               ) RETURN BOOLEAN IS
    BEGIN
        IF LIST_DIFFS( i_old_list, i_new_list, i_separator, i_enclosed_by ) IS NULL AND 
           LIST_DIFFS( i_new_list, i_old_list, i_separator, i_enclosed_by ) IS NULL THEN
            RETURN FALSE;
        END IF; 
        RETURN TRUE;
    END;
   
    ------------------------------------------------------------------------------------

    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN VARCHAR2 ) RETURN BOOLEAN IS
        V_RETVAL    VARCHAR2( 32000 );
    BEGIN
        EXECUTE IMMEDIATE i_select_old INTO V_RETVAL;
        RETURN VALUES_ARE_DIFFER ( i_new_value, V_RETVAL );
    EXCEPTION WHEN OTHERS THEN
        RETURN TRUE;
    END;

    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN NUMBER ) RETURN BOOLEAN IS
        V_RETVAL    NUMBER;
    BEGIN
        EXECUTE IMMEDIATE i_select_old INTO V_RETVAL;
        RETURN VALUES_ARE_DIFFER ( i_new_value, V_RETVAL );
    EXCEPTION WHEN OTHERS THEN
        RETURN TRUE;
    END;

    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN DATE ) RETURN BOOLEAN IS
        V_RETVAL    DATE;
    BEGIN
        EXECUTE IMMEDIATE i_select_old INTO V_RETVAL;
        RETURN VALUES_ARE_DIFFER ( i_new_value, V_RETVAL );
    EXCEPTION WHEN OTHERS THEN
        RETURN TRUE;
    END;

    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN TIMESTAMP ) RETURN BOOLEAN IS
        V_RETVAL    TIMESTAMP;
    BEGIN
        EXECUTE IMMEDIATE i_select_old INTO V_RETVAL;
        RETURN VALUES_ARE_DIFFER ( i_new_value, V_RETVAL );
    EXCEPTION WHEN OTHERS THEN
        RETURN TRUE;
    END;

    FUNCTION  DATA_ARE_DIFFER ( i_select_old IN VARCHAR2, i_new_value IN TIMESTAMP WITH TIME ZONE ) RETURN BOOLEAN IS
        V_RETVAL    TIMESTAMP WITH TIME ZONE ;
    BEGIN
        EXECUTE IMMEDIATE i_select_old INTO V_RETVAL;
        RETURN VALUES_ARE_DIFFER ( i_new_value, V_RETVAL );
    EXCEPTION WHEN OTHERS THEN
        RETURN TRUE;
    END;

    ------------------------------------------------------------------------------------

end;
/
