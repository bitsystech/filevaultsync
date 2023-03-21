#!/bin/sh
# Laeeq H
# March 2023
# To ease the work for secure toke transfer
# exit 420 refers to wrong password attempt

######## VERSIONING ########
# Version 2.0 - Adding Cancel Handling
# Added exit codes: 101 for user pass, 102 for adminID, 103 for adminpass
#### END OF VERSIONING ####

# Get the login name of the current user, even when running as root
##Consoleuser=$(logname) ## Commented out but need to test for future. 
Consoleuser=$(/usr/sbin/scutil <<<"show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ && ! /root/ && ! /_mbsetupuser/ { print $3 }' | /usr/bin/awk -F '@' '{print $1}') 
# Print out the current username (for testing purposes)
echo "Currently logged-in user: $Consoleuser"
echo "-----------------------------------------"
# Display popup dialog and prompt user for password
userPassword=$(osascript <<EOD
tell application "System Events"
    activate
    set thePassword to text returned of (display dialog "Please enter the latest password in AD for $Consoleuser:" default answer "" with title "Password Prompt" with hidden answer)
end tell
return thePassword
EOD
)
if [ -z "$userPassword" ]; then
    echo "Oh snap! you clicked on Cancel. Exiting the script, see you later."
    echo "exit 101 - Click on Quit to close the app"
    exit 101
fi

dscl . -authonly $Consoleuser $userPassword  &> /dev/null

# Check the exit code of the previous command
if [ $? -eq 0 ]; then
    #echo "Password is correct for user $userPassword "
    # Print out the password for testing purposes (remove this line in production!)
    echo "The password entered was: 🙈🙊🙉 "
    echo "-----------------------------------------"
else
    echo "Password Mismatch 💀💀💀 - you have entered $userPassword. This does not match with the login password. Test it by typing in portal.office.com & see if it works."
    echo "If you want to be adventurous, use Terminal window to validate the password. Try su userID and enter the password. Remember that password will be invisible in Terminal. "
    echo "-----------------------------------------\
    "
    echo "App Stopped, please try later with correct password. Click on Quit to close the log window. 😌"
exit 420
fi

# Prompt user to enter username and password using AppleScript popup dialog
adminUsername=$(osascript <<EOD
tell application "System Events"
    activate
    set thePassword to text returned of (display dialog "Please enter local admin ID on this Mac:" default answer "HMIT or DEIT or USIT etc..." with title "Password Prompt")
end tell
return thePassword
EOD
)

if [ -z "$adminUsername" ]; then
    echo "Oh, you seem busy, Local Admin ID was cancelled. You clicked on Cancel hence exiting the script."
    echo "exit 102 - Click on Quit to close the app"
    exit 102
fi

echo "Your admin ID was $adminUsername"

adminPassword=$(osascript <<EOD
tell application "System Events"
    activate
    set thePassword to text returned of (display dialog "Please enter local admin password on this Mac:" default answer "" with title "Password Prompt" with hidden answer)
end tell
return thePassword
EOD
)

if [ -z "$adminPassword" ]; then
    echo "Oh, you seem busy, Local Admin password was cancelled. You clicked on Cancel hence exiting the script."
    echo "exit 103 - Click on Quit to close the app"
    exit 103
fi

#echo "Your password was $adminPassword"


sysadminctl -secureTokenOn $Consoleuser -password $Password -adminUser $adminUserName -adminPassword $adminPassword
echo "The output listed above tells if it successful or not. Kindly keep a screenshot."
echo "-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-🔺-"
sleep 1

echo "CONCLUSION:📣"
echo "If you get an error above - "Operation is not permitted without secure token unlock", then restart and check if they sync worked. If it is not yet, then escalate to next level."
echo "-----------------------------------------"
echo "If the output is something that's not documented by Mac team, kindly connect with a screenshot to discuss it."
exit 0