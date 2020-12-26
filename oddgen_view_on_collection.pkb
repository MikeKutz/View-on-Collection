create or replace
package body oddgen_view_on_collection
as
    function generate return clob
    as
        return_variable CLOB;
        p_vars           teplsql.t_assoc_array;
        
    begin
        p_vars( teplsql.g_set_indention_string )  := '    ';

        p_vars( 'src_owner' )        := user;
        p_vars( 'src_table_name' )   := 'TE_TEMPLATES';
        p_vars( 'schema' )           := '#OWNER#'; -- target owner
        p_vars( 'view_name' )        := 'table_name';
        p_vars( 'package_name' )     := 'pkg_name';
        
        return_variable := teplsql.process_build( p_vars, 'v2c' , $$PLSQL_UNIT, 'PACKAGE' );

        return return_variable;
    end generate;

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
<%@ template( template_name=v2c ) %>
<%@ extends( build, view_build )  %>
<%@ extends( package, v2c ) %>
  <%@ block( name ) %>${package_name}<%@ enblock %>
  <%@ extends( plsql-type, collection_name_t ) %>
    <%@ block( data-type ) %>varchar2(30)<%@ enblock %>
  <%@ enextends %>
  <%@ extends( plsql-type, rcd_t ) %>
    <%@ block( record ) %><% teplsql.set_tab(1); %>(<% for curr in "Columns"( '${src_owner}', '${src_table_name}', '' ) loop %>
<% teplsql.goto_tab(1); %><%= curr.comma_first || curr.column_name_rpad %>apex_collections.c001%type
<% end loop; %>
<% teplsql.goto_tab(1); %>)<%@ enblock %>
  <%@ enextends %>
  <%@ extends( variable, g_collection_name ) %>
    <%@ block( data-type ) %><%@ include( ${super.super}.plsql-type.collection_name_t.name ) %><%@ enblock %>
    <%@ block( constant-value ) %>'<%= dbms_random.string( 'X', 10 ) %>${view_name}'<%@ enblock %>
  <%@ enextends %>
  <%@ extends( procedure, 01_collection_name ) %>
    <%@ block( name ) %>collection_name<%@ enblock %>
    <%@ block( return-variable-type ) %><%@ include( ${super.super}.plsql-type.collection_name_t.name ) %><%@ enblock %>
    <%@ block( bdy ) %>return_variable := <%@ include( ${super.super}.variable.g_collection_name.name ) %>;<%@ enblock %>
  <%@ enextends %>
  <%@ extends( procedure, 02_assert_collection ) %>
    <%@ block( name ) %>assert_collection<%@ enblock %>
    <%@ block( bdy ) %>if not apex_collection.collection_exists( <%@ include( ${super.super}.variable.g_collection_name.name ) %> )
then
    apex_debug.message( 'Collection for view does not exist. "%s"', '' );
    apex_collection.create_collection( <%@ include( ${super.super}.variable.g_collection_name.name ) %> );
end if;<%@ enblock %>
  <%@ enextends %>
  <%@ extends( procedure, 03_page2rcd ) %>
    <%@ block( name ) %>page2rcd<%@ enblock %>
    <%@ block( return-variable-type ) %><%@ include( ${super.super}.plsql-type.rcd_t.name ) %><%@ enblock %>
    <%@ block( return-variable-name ) %>rcd<%@ enblock %>
    <%@ block( bdy ) %>apex_debug.message( 'Workspace "%s", app="%s", page="%s"', v('WORKSPACE_ID'), v('APP_ID'), v('APP_PAGE_ID') );

for curr in common_apex_utils."Page Items"()
loop
    apex_debug.message(  '..Item "%s" is for column "%s" format "%s" has the value "%s"', curr.item_name, curr.column_name, curr.format_mask, substr( v( curr.item_name ), 1, 128 ) );

    case curr.column_name
<% for c1 in "Columns"( '${src_owner}', '${src_table_name}', '' ) loop %>
        when '<%= c1.column_name %>'
            rcd.<%= c1.column_name %> := v( curr.item_name );
<% end loop; %>
        else
            apex_debug.message( 'Column "%s" is not part of this view.', curr.column_name );
    end case;
end loop;
    <%@ enblock %>
  <%@ enextends %>
  <%@ extends( procedure, 04_automaticdml ) %>
    <%@ block( name ) %>automaticdml<%@ enblock %>
  <%@ enextends %>
  <%@ extends( procedure, 05_multirow_dml ) %>
    <%@ block( name ) %>multirow_dml<%@ enblock %>
  <%@ enextends %>
  <%@ extends( procedure, 10_ins ) %>
    <%@ block( name ) %>ins<%@ enblock %>
    <%@ block( parameters ) %>rcd in <%@ include( ${super.super}.plsql-type.rcd_t.name ) %><%@ enblock %>
    <%@ block( decl ) %>seq_id apex_collections.seq_id%type;<%@ enblock %>
<%@ block( bdy ) %>seq_id := apex_collection.add_member(<% teplsql.set_tab(1); %>p_collection_name => <%@ include( ${super.super}.variable.g_collection_name.name ) %>\\\\n
<% for curr in "Columns"( '${src_owner}', '${src_table_name}', '' ) loop %>
<% case curr.data_type
    when 'CLOB' then %>
<% teplsql.goto_tab(1); %>,p_clob001 => rcd.<%= curr.column_name %>\\\\n
<% when 'BLOB' then %>
<% teplsql.goto_tab(1); %>,p_blob001 => rcd.<%= curr.column_name %>\\\\n
<% when 'XMLTYPE' then %>
<% teplsql.goto_tab(1); %>,p_xmltype001 => rcd.<%= curr.column_name %>\\\\n
<% else %>
<% teplsql.goto_tab(1); %>,p_c<%= lpad( curr.column_id, '3', '0') %> => rcd.<%= curr.column_name %>\\\\n
<% end case; %>
<% end loop; %>
<% teplsql.goto_tab(1); %>);

rcd.item_id := seq_id;<%@ enblock %>
  <%@ enextends %>
  <%@ extends( procedure, 11_upd ) %>
    <%@ block( name ) %>upd<%@ enblock %>
    <%@ block( parameters ) %>rcd in out <%@ include( ${super.super}.plsql-type.rcd_t.name ) %><%@ enblock %>
<%@ block( bdy ) %>
<% for curr in "Columns"( '${src_owner}', '${src_table_name}', '' ) loop %>
-- Updating Collection Column C<%= lpad( curr.column_id, 3, '0' ) %> to <%= curr.column_name %>.
if UPDATING( '<%= curr.column_name %>' ) or ( not UPDATING and (p_col_list.exists( '<%= curr.column_name %>' ) or p_col_list.count = 0))
then
    apex_collection.update_member_attribute(
                         p_collection_name  => <%@ include( ${super.super}.variable.g_collection_name.name ) %>\\\\n
                        ,p_seq              => rcd.ITEM_ID
                        ,p_attr_number      => <%= curr.column_id %> -- VARCHAR2
                        ,p_attr_value       => rcd.ITEM_DESC 
                    );
end if;

<% end loop; %>
<%@ enblock %>

  <%@ enextends %>
  <%@ extends( procedure, 12_del ) %>
    <%@ block( name ) %>del<%@ enblock %>
    <%@ block( parameters ) %>rcd in out <%@ include( ${super.super}.plsql-type.rcd_t.name ) %><%@ enblock %>
    <%@ block( bdy ) %>apex_collection.delete_member(
    p_collection_name => <%@ include( ${super.super}.variable.g_collection_name.name ) %>\\\\n
    ,p_seq => p_rcd.item_id
    );<%@ enblock %>
  <%@ enextends %>

<%@ enextends %>
<%@ extends( select, v2c ) %>
  <%@ block( name ) %>${view_name}<%@ enblock %>
  <%@ block( SQL ) %>select <% teplsql.set_tab(1); %>
<% for curr in "Columns"( '${src_owner}', '${src_table_name}', '' ) loop %>
<% case curr.data_type
    when 'VARCHAR2' then %>
<% teplsql.goto_tab(1); %><%= curr.comma_first %>a.C<%= lpad( curr.order_by, '3','0') %> as <%= curr.column_name %>\\\\n
<%  when 'DATE' then %>
<% teplsql.goto_tab(1); %><%= curr.comma_first %>to_date( a.C<%= lpad( curr.order_by, '3','0') %>, 'yyyy-mm-dd hh24:mi:ss' ) as <%= curr.column_name %>\\\\n
<%  when 'NUMBER' then %>
<% teplsql.goto_tab(1); %><%= curr.comma_first %>to_number( a.C<%= lpad( curr.order_by, '3','0') %> ) as <%= curr.column_name %>\\\\n
<%  when 'CLOB' then %>
<% teplsql.goto_tab(1); %><%= curr.comma_first %>a.CLOB001 as <%= curr.column_name %>\\\\n
<%  when 'BLOB' then %>
<% teplsql.goto_tab(1); %><%= curr.comma_first %>a.BLOB001 as <%= curr.column_name %>\\\\n
<%  when 'XMLTYPE' then %>
<% teplsql.goto_tab(1); %><%= curr.comma_first %>a.XMLTYPE001 as <%= curr.column_name %>\\\\n
<% else %>
<% teplsql.goto_tab(1); %><%= curr.comma_first %>cast( a.C<%= lpad( curr.order_by, '3','0') %> as <%= curr.data_type %> ) as <%= curr.column_name %>\\\\n
<% end case; %>
<% end loop; %>
from apex_collections a
where a.collecection_name = ${schema}.<%@ include( ${super.super}.package.v2c.name ) %>.<%@ include( ${super.super}.package.v2c.procedure.01_collection_name.name ) %>
<%@ enblock %>
<%@ enextends %>
<%@ enextends %>
$end

end;
/