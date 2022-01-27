#!/bin/bash


# Pulls the current logged in user and their UID
currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")

fvPass=$(
# Prompts the user to input their FileVault password using Applescript. This password is used for a SecureToken into the startosinstall.
/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript <<APPLESCRIPT
set validatedPass to false
repeat while (validatedPass = false)
-- Prompt the user to enter their filevault password
display dialog "Enter your macOS password to start the macOS upgrade" with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" default answer "" buttons {"Continue"} with text and hidden answer default button "Continue"
set fvPass to (text returned of result)
display dialog "Re-enter your macOS password to verify it was entered correctly" with text and hidden answer buttons {"Continue"} with icon file "System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:FileVaultIcon.icns" default answer "" default button "Continue"
if text returned of result is equal to fvPass then
set validatedPass to true
fvPass
else
display dialog "The passwords you have entered do not match. Please enter matching passwords." with title "FileVault Password Validation Failed" buttons {"Re-Enter Password"} default button "Re-Enter Password" with icon file messageIcon
end if
end repeat
APPLESCRIPT
)

echo $fvPass | /Applications/Install\ macOS\ Monterey.app/Contents/Resources/startosinstall --agreetolicense --forcequitapps --nointeraction --user $currUser --stdinpass

exit 0
