if [ -z "$1" ] ; then
    echo "Please pass the name of the virtual resource table name. For example:"
    echo "       ./delete-virtual-resource.sh TABLE_NAME"
else
	read -sp 'Policy Engine Postgres DB Password: ' PGPASSWORD
	echo ""
	HAS_RULE=0
	virtual_resource_table="$1"
	virtual_column_list=$(psql -h 127.0.0.1 -p 5433 -d btuirepo -U btuiuser -P "footer=off" -t -c "select distinct split_part(mappedname, '.', 2) from arcnamesmapext where split_part(mappedname, '.', 1) = upper('$virtual_resource_table');")

	for value in $virtual_column_list
	do
	    check_policies_on_column=$(curl --silent -u btadminuser:P@ssw0rd --header "Content-type:application/json" --request GET "http://localhost:8111/PolicyManagement/1.0/resources/btdefault.PUBLIC.$virtual_resource_table.$value/policies")
		# Are you only looking for global policies,if yes, than you could ignore this comment.
		if echo "$check_policies_on_column" | grep -q "policySetName"; then
		    echo "* The below policy still has rule(s) on the resource $virtual_resource_table.$value:"
		    echo $check_policies_on_column | grep -Po '"policySetName":.*?[^\\]"'
		    HAS_RULE=1
		else
		    echo "The resource $virtual_resource_table.$value has no rule so it's OK to delete"
		fi
	done

	check_policies_on_table=$(curl --silent -u btadminuser:P@ssw0rd --header "Content-type:application/json" --request GET http://localhost:8111/PolicyManagement/1.0/resources/btdefault.PUBLIC.$virtual_resource_table.*/policies)
	if echo "$check_policies_on_table" | grep -q "policySetName"; then
	    echo "* The below policy still has rule(s) on the resource $virtual_resource_table.*"
	    echo $check_policies_on_table | grep -Po '"policySetName":.*?[^\\]"'
	    HAS_RULE=1
	else
	    echo "The resource $virtual_resource_table.* has no rule so it's OK to delete"
	fi

	if [ "$HAS_RULE" == 1 ] ; then
		echo "ERROR: Please remove all associated rules on $virtual_resource_table before deleting!"
	    exit 1
	fi

	delete_sql="delete from arcnamesmapext where split_part(mappedname, '.', 1) = upper('$virtual_resource_table');\
	
	# delete from arcnamesmap where table_name=upper('$virtual_resource_table'); # use this query
	delete from arcnamesmap where mappedname=upper('$virtual_resource_table');\
	
	# add a check to fetch sequence of table only. dstc table will have entry for all D,S,T and C. use this:
	# delete from arccompositschema where dstcseqt=(select dstcseq from arccompositdstc where atype='T' and arcdstcname=upper('$virtual_resource_table'));\
	delete from arccompositschema where dstcseqt=(select dstcseq from arccompositdstc where arcdstcname=upper('$virtual_resource_table'));\
	
	# Add a check to delete table only.
	# delete from arccompositdstc where atype='T' and arcdstcname=upper('$virtual_resource_table');
	delete from arccompositdstc where arcdstcname=upper('$virtual_resource_table');
	"

	psql -h 127.0.0.1 -p 5433 -d btuirepo -U btuiuser -c "$delete_sql"
fi
