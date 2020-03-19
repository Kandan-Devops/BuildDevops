NO_OF_ROWS=`python Scripts/get_no_of_rows_in_buildsheet.py`
i=5
for((row=5; row<NO_OF_ROWS; row++))
do
  printf 'yes\n' | python Scripts/main_python.py $Vcenter_username $Vcenter_password $Domain_administrator_username $Domain_administrator_password $Local_administrator_password $ROOT_PASSWORD $NEW_ROOT_PASSWORD $NEW_ADMIN_PASSWORD $row $slack_token_url
  let i++
  if [ $i -lt $NO_OF_ROWS ]; then
     /usr/bin/sh Scripts/slack_webhook.sh $slack_token_url NEXT_ROW 
  fi
done