//%attributes = {}
/*
 Method: _Internal_BuildFieldTree
 User name (OS): Lee Hinde 
 Date and time: 06/04/26, 12:50:19
 ----------------------------------------------------
 Description 

 Parameters
*/

// ----------------------------------------------------
// Project method : _Internal_BuildFieldTree
// ----------------------------------------------------
#DECLARE($parent_list : Integer; $table_id : Integer; $filter : Text; $id_pointer : Pointer)


var $i : Integer
var $field_id : Integer
var $field_type : Integer
var $related_table_id : Integer
var $related_field_id : Integer
var $child_node : Integer
var $field : Pointer
var $icon : Picture

ARRAY LONGINT:C221($_field_id; 0)
ARRAY TEXT:C222($_field_names; 0)

// 1. Extract the Field Titles for the current table context
If (boo_useVirtualStructure)
	GET FIELD TITLES:C804((Table:C252($table_id))->; $_field_names; $_field_id)
Else 
	var $count_fields : Integer
	var $int : Integer
	var $bool; $is_invisible; $in_design : Boolean
	
	$in_design:=((Process info:C1843(Current process:C322).type)<0)
	ARRAY TEXT:C222($_field_names; 0)
	ARRAY LONGINT:C221($_field_id; 0)
	$count_fields:=Last field number:C255($table_id)
	
	For ($i; 1; $count_fields)
		If (Is field number valid:C1000($table_id; $i))
			GET FIELD PROPERTIES:C258($table_id; $i; $int; $int; $bool; $bool; $is_invisible)
			If (Not:C34($is_invisible) | $in_design)
				APPEND TO ARRAY:C911($_field_names; Field name:C257($table_id; $i))
				APPEND TO ARRAY:C911($_field_id; $i)
			End if 
		End if 
	End for 
End if 

// 2. Loop through all fields on this level
For ($i; 1; Size of array:C274($_field_id))
	$field_id:=$_field_id{$i}
	$field:=Field:C253($table_id; $field_id)
	
	// Get relational mapping for the current field
	GET RELATION PROPERTIES:C686($field; $related_table_id; $related_field_id)
	
	// Filter check
	If ($_field_names{$i}=$filter) | (($related_table_id#0) & ($related_field_id#0))
		$field_type:=Type:C295($field->)
		
		Case of 
			: ($field_type=Is BLOB:K8:12) | ($field_type=Is subtable:K8:11) | ($field_type=Is object:K8:27)
				// Skip fields that cannot be used in reports/labels
				
			Else 
				// Check if this field points to a related table
				If ($related_table_id#0) & ($related_field_id#0)
					
					// RECURSION HAPPENS HERE: 
					// Instead of writing a fixed loop, create a new sublist container
					$child_node:=New list:C375
					
					// Go down another level deep!
					_Internal_BuildFieldTree($child_node; $related_table_id; $filter; $id_pointer)
					
					// If the sub-table actually contained viewable fields, append the node
					If (Count list items:C380($child_node)>0)
						$id_pointer->:=$id_pointer->+1
						APPEND TO LIST:C376($parent_list; $_field_names{$i}; $id_pointer->; $child_node; True:C214)
						SET LIST ITEM PARAMETER:C986($parent_list; 0; "tableId"; $table_id)
						SET LIST ITEM PARAMETER:C986($parent_list; 0; "fieldId"; $field_id)
						SET LIST ITEM PARAMETER:C986($parent_list; 0; "fieldType"; $field_type)
						SET LIST ITEM PROPERTIES:C386($parent_list; 0; False:C215; Bold:K14:2; 0)
						$icon:=db_Get_field_icon($field_type)
						SET LIST ITEM ICON:C950($parent_list; 0; $icon)
					Else 
						CLEAR LIST:C377($child_node)
						
						If ($_field_names{$i}=$filter)
							$id_pointer->:=$id_pointer->+1
							APPEND TO LIST:C376($parent_list; $_field_names{$i}; $id_pointer->)
							SET LIST ITEM PARAMETER:C986($parent_list; 0; "tableId"; $table_id)
							SET LIST ITEM PARAMETER:C986($parent_list; 0; "fieldId"; $field_id)
							SET LIST ITEM PARAMETER:C986($parent_list; 0; "fieldType"; $field_type)
							$icon:=db_Get_field_icon($field_type)
							SET LIST ITEM ICON:C950($parent_list; 0; $icon)
						End if 
					End if 
					
				Else 
					// Standard leaf node field (No relations)
					$id_pointer->:=$id_pointer->+1
					APPEND TO LIST:C376($parent_list; $_field_names{$i}; $id_pointer->)
					SET LIST ITEM PARAMETER:C986($parent_list; 0; "tableId"; $table_id)
					SET LIST ITEM PARAMETER:C986($parent_list; 0; "fieldId"; $field_id)
					SET LIST ITEM PARAMETER:C986($parent_list; 0; "fieldType"; $field_type)
					$icon:=db_Get_field_icon($field_type)
					SET LIST ITEM ICON:C950($parent_list; 0; $icon)
				End if 
		End case 
	End if 
End for 