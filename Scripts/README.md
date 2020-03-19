Files Description
-----------------

check_existing_host.sh :- To check whether the hostIP or hostname given in the buildsheet already allocated or not. It will trigger the powershell script " get_existing_host.ps1 " and getting the list of resources already allocted in the given vcenter. Then it will compare the same with the given host.