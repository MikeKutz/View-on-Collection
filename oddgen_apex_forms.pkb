create or replace
package body oddgen_apex_forms
as
    function generate return clob
    as
        return_variable CLOB;
        p_vars           teplsql.t_assoc_array;
        
    begin
        p_vars( teplsql.g_set_indention_string )  := '    ';

        p_vars( 'src_owner' )        := user;
        p_vars( 'src_table_name' )   := 'TE_TEMPLATES';
        p_vars( 'schema' )           := 'teplsql$sys'; -- target owner
        p_vars( 'view_name' )        := 'test_v2c';
        p_vars( 'package_name' )     := 'pkg_name';
        
        return_variable := teplsql.process_build( p_vars, 'apex.rcds' , $$PLSQL_UNIT, 'PACKAGE' );

        return return_variable;
    end generate;
    
    procedure create_search_table
    as
        table_exists exception;
        pragma exception_init( table_exists, -955 );
    begin
        execute immediate q'[
            create private temporary table ora$ptt_search_tables (
              owner varchar2(128 byte) ,
              table_name varchar2(128 byte)
            ) on commit PRESERVE definition]';
    exception
        when table_exists then
            execute immediate q'[truncate table ora$ptt_search_tables]';
    
    end;
    
    procedure add_search_table( table_name in varchar, owner in varchar2 default user)
    as --00942
        no_table exception;
        pragma exception_init(no_table, -942);
        
        procedure actual_add
        as
        begin
            execute immediate q'[
                insert into ora$ptt_search_tables (owner,table_name)
                values ( :owner, :table_name )]'
            using nvl(owner,user), table_name;
        end;
    begin
        actual_add;
    exception
        when no_table then
            create_search_table;
            actual_add;
    end;

    procedure output_code( src_table in varchar2
                          ,target_table_name in varchar2 default null
                          ,src_owner in varchar2 default USER
                          ,target_owner in varchar2 default '#OWNER#'
                         )
    as
    begin
        dbms_output.put_line( generate );
    end;

$if false $then
<%@ template( template_name=apex.rcds ) %>
<%@ extends( build, rcd_build, base=teplsql.helper.loop-tables )  %>
<%@ extends( package, bob, base=teplsql.helper.loop-tables ) %>
    <%@ extends( procedure, 01_test ) %>
        <%@ block( name ) %>page2rcd_<%= lower(current_table.table_name) %><%@ enblock %>
        <%@ block( return-variable-type ) %><%= lower(current_table.table_name) %>%ROWTYPE<%@ enblock %>
        <%@ block( return-variable-name ) %>rcd<%@ enblock %>
        <%@ block( decl ) %>cols common_apex_utils.col_list_t;<%@ enblock %>
        <%@ block( bdy ) %>cols := common_apex_utils.get_page_items();
        
<% for curr in "Columns"( current_table.owner, current_table.table_name, null ) loop %>
rcd.<%= curr.column_name_rpad %> := v( cols( '<%= curr.column_name %>' ));
<% end loop; %>
     <%@ enblock %>
    <%@ enextends %>
<%@ enextends %>
<%@ enextends %>
$end

end;
/