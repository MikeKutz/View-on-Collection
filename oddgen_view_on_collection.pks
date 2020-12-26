create or replace
package oddgen_view_on_collection
    authid current_user
as
    /**
    * Provides an oddgen Generator and Build Template
    * ======
    *
    * Requires
    * - tePLSQL v2.0.0
    * - oddgen v0.3
    *
    *  Code generated
    *  ---
    *  Object Type | name | Description
    *  ------------|------|--------------
    *  VIEW | ${target_table_name} | View on APEX Collection
    *  PACKAGE | ${target_table_name}$PKG | Provides `automaticdml` and IG code
    *
    *  Package Contents
    *  -----
    *  Function/Procedure | Returns | Description
    *  -------------------|---------|-------------
    *  automaticdml | n/a | Replace default "Automatic DML" process with a PL/SQL Process that calls this
    *   ??? | n/a | Use this in "Custom IG Process"
    *  
    */
    
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
end;
/