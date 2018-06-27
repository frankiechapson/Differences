
# Difference Package

## Oracle PL/SQL solution to compare data

## Why?

Because in Oracle not easy to check data equalency. For me two data are differ if the following condition is true:

    ( A_Value IS NOT NULL AND B_Value IS     NULL ) OR
    ( A_Value IS     NULL AND B_Value IS NOT NULL ) OR
    ( A_Value IS NOT NULL AND B_Value IS NOT NULL AND A_Value <> B_Value ) 

So, I wrote this for every native data types, plus for lists and table data as well.

The **PKG_DIFF** package uses two functions to manage Lists:
**F_CSV_TO_LIST** which parses a string and returns with a list, and **F_SELECT_ROWS_TO_CSV** what makes a string from column value list specified by a select command. See the detailed descriptions in the functions!
These functions uses **T_STRING_LIST** data type.

## How?
The **PKG_DIFF** package contains a **VALUES_ARE_DIFFER** function(s) for VARCHAR2, NUMBER, DATE and TIMESTAMPs data types.

Contains a **LISTS_ARE_DIFFER** function which can compare two strings what are "any" separated value lists. The lists (sets) are identical if they contain same elements. So the following lists are NOT DIFFER:

    'cat,dog,cow,cat,cat,horse'
    'cow,horse,dog,cat'

And contains **DATA_ARE_DIFFER** function(s) for VARCHAR2, NUMBER, DATE and TIMESTAMPs data types. This function(s) can compare table data with a variable value. The first parameter of the function is an SQL select command. Eg:

    PKG_DIFF.DATA_ARE_DIFFER( 'select 1223 from dual', 1234 )

returns TRUE.

This function is very useful in APEX to compare stored data with the current ITEM value.
