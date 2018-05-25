

create table DIFF_TEST ( ID             number primary key
                       , D_VARCHAR2     varchar2( 1000 )
                       , D_NUMBER       number
                       , D_DATE         date
                       , D_TIMESTAMP    timestamp
                       , D_TIMESTAMP_TZ timestamp with time zone
                       );

insert into DIFF_TEST values ( 1, 'Hello World!', 12345, sysdate, systimestamp, systimestamp );
commit;


declare

    V_VARCHAR2_1        varchar2( 1000 )  := 'cat'; 
    V_VARCHAR2_2        varchar2( 1000 )  := 'dog';

    V_NUMBER_1          number := 123;
    V_NUMBER_2          number := 123;

    V_DATE_1            date := sysdate;
    V_DATE_2            date := sysdate + 1;

    V_TIMESTAMP_1       timestamp := systimestamp;
    V_TIMESTAMP_2       timestamp := systimestamp + 1;

    V_TIMESTAMP_TZ_1    timestamp with time zone := systimestamp;
    V_TIMESTAMP_TZ_2    timestamp with time zone := systimestamp + 1;

    V_LIST_1            varchar2( 1000 )  := 'cat:dog:cow:horse'; 
    V_LIST_2            varchar2( 1000 )  := 'cow:horse:dog:cat';

    V_SELECT_VARCHAR2   varchar2( 1000 ) := 'select D_VARCHAR2     from DIFF_TEST where ID = 1';
    V_SELECT_NUMBER     varchar2( 1000 ) := 'select D_NUMBER       from DIFF_TEST where ID = 1';
    V_SELECT_DATE       varchar2( 1000 ) := 'select D_DATE         from DIFF_TEST where ID = 1';
    V_SELECT_TS         varchar2( 1000 ) := 'select D_TIMESTAMP    from DIFF_TEST where ID = 1';
    V_SELECT_TS_W_TZ    varchar2( 1000 ) := 'select D_TIMESTAMP_TZ from DIFF_TEST where ID = 1';

begin

    if PKG_DIFF.VALUES_ARE_DIFFER( V_VARCHAR2_1, V_VARCHAR2_2 ) then
        dbms_output.put_line( 'The '||nvl(V_VARCHAR2_1,'null')||' differs from '||nvl(V_VARCHAR2_2,'null') );
    else
        dbms_output.put_line( 'The '||nvl(V_VARCHAR2_1,'null')||' and '||nvl(V_VARCHAR2_2,'null')||' are identical' );
    end if;

    if PKG_DIFF.VALUES_ARE_DIFFER( V_NUMBER_1, V_NUMBER_2 ) then
        dbms_output.put_line( 'The '||nvl(to_char(V_NUMBER_1),'null')||' differs from '||nvl(to_char(V_NUMBER_2),'null') );
    else
        dbms_output.put_line( 'The '||nvl(to_char(V_NUMBER_1),'null')||' and '||nvl(to_char(V_NUMBER_2),'null')||' are identical' );
    end if;

    if PKG_DIFF.VALUES_ARE_DIFFER( V_DATE_1, V_DATE_2 ) then
        dbms_output.put_line( 'The '||nvl(to_char(V_DATE_1, 'yyyy.mm.dd hh24:mi:ss'),'null')||' differs from '||nvl(to_char(V_DATE_2, 'yyyy.mm.dd hh24:mi:ss'),'null') );
    else
        dbms_output.put_line( 'The '||nvl(to_char(V_DATE_1, 'yyyy.mm.dd hh24:mi:ss'),'null')||' and '||nvl(to_char(V_DATE_2, 'yyyy.mm.dd hh24:mi:ss'),'null')||' are identical' );
    end if;

    if PKG_DIFF.VALUES_ARE_DIFFER( V_TIMESTAMP_1, V_TIMESTAMP_2 ) then
        dbms_output.put_line( 'The '||nvl(to_char(V_TIMESTAMP_1, 'yyyy.mm.dd hh24:mi:ss.ff'),'null')||' differs from '||nvl(to_char(V_TIMESTAMP_2, 'yyyy.mm.dd hh24:mi:ss.ff'),'null') );
    else
        dbms_output.put_line( 'The '||nvl(to_char(V_TIMESTAMP_1, 'yyyy.mm.dd hh24:mi:ss.ff'),'null')||' and '||nvl(to_char(V_TIMESTAMP_2, 'yyyy.mm.dd hh24:mi:ss.ff'),'null')||' are identical' );
    end if;

    if PKG_DIFF.VALUES_ARE_DIFFER( V_TIMESTAMP_TZ_1, V_TIMESTAMP_TZ_2 ) then
        dbms_output.put_line( 'The '||nvl(to_char(V_TIMESTAMP_TZ_1, 'yyyy.mm.dd hh24:mi:ss.ff tzr'),'null')||' differs from '||nvl(to_char(V_TIMESTAMP_TZ_2, 'yyyy.mm.dd hh24:mi:ss.ff tzr'),'null') );
    else
        dbms_output.put_line( 'The '||nvl(to_char(V_TIMESTAMP_TZ_1, 'yyyy.mm.dd hh24:mi:ss.ff tzr'),'null')||' and '||nvl(to_char(V_TIMESTAMP_TZ_2, 'yyyy.mm.dd hh24:mi:ss.ff tzr'),'null')||' are identical' );
    end if;

    if PKG_DIFF.LISTS_ARE_DIFFER( V_LIST_1, V_LIST_2 ) then
        dbms_output.put_line( 'The '||nvl(V_LIST_1,'null')||' differs from '||nvl(V_LIST_2,'null') );
    else
        dbms_output.put_line( 'The '||nvl(V_LIST_1,'null')||' and '||nvl(V_LIST_2,'null')||' are identical' );
    end if;

    if PKG_DIFF.DATA_ARE_DIFFER( V_SELECT_VARCHAR2,  V_VARCHAR2_1 ) then
        dbms_output.put_line( 'The data selected by "'||V_SELECT_VARCHAR2||'" differs from '||nvl(V_VARCHAR2_1,'null') );
    else
        dbms_output.put_line( 'The data selected by "'||V_SELECT_VARCHAR2||'" and '||nvl(V_VARCHAR2_1,'null')||' are identical' );
    end if;

    if PKG_DIFF.DATA_ARE_DIFFER( V_SELECT_NUMBER,  V_NUMBER_1 ) then
        dbms_output.put_line( 'The data selected by "'||V_SELECT_NUMBER||'" differs from '||nvl(to_char(V_NUMBER_1),'null') );
    else
        dbms_output.put_line( 'The data selected by "'||V_SELECT_NUMBER||'" and '||nvl(to_char(V_NUMBER_1),'null')||' are identical' );
    end if;

    -- ...etc

end;
/


