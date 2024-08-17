create or replace
package oddgen_apex_forms
    authid current_user
as
    /* Generate a `VIEW` on an APEX Collection
    *  and display the results to `DBMS_OUTPUT`
    *
    *    
    *   @param src_table_name      Table name to model the VIEW
    *   @param target_table_name   VIEW name
    *   @param src_owner           Owner of the souce table
    *   @param target_owner        Owner of the target VIEW (The workspace schema)
    */
    procedure output_code( src_table in varchar2
                          ,target_table_name in varchar2 default null
                          ,src_owner in varchar2 default USER
                          ,target_owner in varchar2 default '#OWNER#'
                         );
    procedure create_search_table;
    procedure add_search_table( table_name in varchar, owner in varchar2 default user);


end;
/