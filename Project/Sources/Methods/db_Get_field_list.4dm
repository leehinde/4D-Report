//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project method : db_Get_field_list
// ----------------------------------------------------

#DECLARE($table_id : Integer; $filter : Text; $ordered : Boolean)->$list : Integer

var $count_parameters : Integer
var $id : Integer  // Keep tracking node IDs globally across recursion passes

$count_parameters:=Count parameters:C259
If ($count_parameters>=2)
	$filter:=Replace string:C233($filter; "@"; ""; *)
End if 
$filter:=Choose:C955(Length:C16($filter)#0; "@"+$filter+"@"; "@")

$list:=New list:C375
$id:=0

If ($table_id#0)
	// Call our new recursive worker function to build the root level
	// We pass the list handle, target table, and current global ID counter
	_Internal_BuildFieldTree($list; $table_id; $filter; ->$id)
	
	If ($ordered)
		SORT LIST:C391($list)
	End if 
End if 