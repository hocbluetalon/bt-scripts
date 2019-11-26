# BlueTalon Scripts
This is a collection of useful scripts which can help automate certain aspect of deploying and operationalizing BlueTalon. The scripts are provided as-is and not maintained as a part of BlueTalon product.

## delete-virtual-resource.sh
This script can be used to delete a global virtual resource (e.g. super logical) to complement BlueTalon API. 

### What the script **will** do
1. Check if there is any rule on the resource (table label or column level). If there is, it will stop and ask to have the rules deleted upfront. The reason is that the script will not interfere with how rules are defined.

2. Delete all mappings on the resource

3. Then finally delete the virtual resource itself

### What the script **will NOT** do
1. Delete rules or policies associcated with the virtual resource (as mentioned above)

2. Delete multiple virtual resources. It can only delete one at a time. You can write a script to loop through multiple virtual resources.

3. Trigger Deploy. The script won't do this since it is not aware of what are other changes coming with the deployment. The Adminstrator needs to perform deployment at the end of the script execution.

4. Delete the actual underlining physical resources. It only delete the virtual resource and unmap but will not interfere with existing physical resources.

### How to use it
1. Copy the script in the BlueTalon Policy Server and assign permission 755

2. Ensure you have some **test** virtual resource ready to test the delete script. You can use this API examples below to create: 
```
curl -u btadminuser:P@ssw0rd --header "Content-type: application/json" --request PUT http://localhost:8111/PolicyManagement/1.0/resource_domains/global/map --data '[{"name": "maptest1"}]'
 
 
curl -u btadminuser:P@ssw0rd --header "Content-type:application/json" --request PUT http://localhost:8111/PolicyManagement/1.0/resource_domains/cdh_hive/map --data '{"mapping":[{"virtualresource": "maptest1","physicalresource": ["sales.sales.accounts"]}]}'
curl -u btadminuser:P@ssw0rd --header "Content-type:application/json" --request PUT http://localhost:8111/PolicyManagement/1.0/resource_domains/cdh_hive/map --data '{"mapping":[{"virtualresource": "maptest1","physicalresource": ["acmehealth.acmehealth.members"]}]}'
 
 
curl -u btadminuser:P@ssw0rd --header "Content-type:application/json" --request PUT http://localhost:8111/PolicyManagement/1.0/resource_domains/cdh_hive/map --data '{"mapping":[{"virtualresource": "maptest1.ssn","physicalresource": ["sales.sales.accounts.SOC_SEC_NO"]}]}'
curl -u btadminuser:P@ssw0rd --header "Content-type:application/json" --request PUT http://localhost:8111/PolicyManagement/1.0/resource_domains/cdh_hive/map --data '{"mapping":[{"virtualresource": "maptest1.ssn","physicalresource": ["acmehealth.acmehealth.members.ssn"]}]}'


curl -u btadminuser:P@ssw0rd --header "Content-type:application/json" --request PUT http://localhost:8111/PolicyManagement/1.0/resource_domains/cdh_hive/map --data '{"mapping":[{"virtualresource": "maptest1.name","physicalresource": ["sales.sales.accounts.name"]}]}'
curl -u btadminuser:P@ssw0rd --header "Content-type:application/json" --request PUT http://localhost:8111/PolicyManagement/1.0/resource_domains/cdh_hive/map --data '{"mapping":[{"virtualresource": "maptest1.name","physicalresource": ["acmehealth.acmehealth.members.name"]}]}'
```
NOTE: The resources above in "physicalresource" must exist: `acmehealth.acmehealth.members` and `sales.sales.accounts` or you can change it to any physical resource

3. Access BlueTalon GUI to confirm the resource shows up under Add Rule > select Global resource > pick the name from the Resource list

4. In the BlueTalon Server terminal, execute below command to delete the virtual resource which is `maptest1` in above example:
```
./delete-virtual-resource.sh maptest1
```

5. Access BlueTalon GUI to confirm the resource has been deleted

6. Deploy in BlueTalon GUI if needed

