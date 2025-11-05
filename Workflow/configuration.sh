#!/bin/zsh --no-rcs

# Get filepath for Default Profile
case "${releaseChannel}" in
	"firefox")
		readonly versionCode="2656FF1E876E9973"
		;;
	"firefoxDeveloperEdition")
		readonly versionCode="1F42C145FFDD4120"
		;;
	"firefoxNightly")
		readonly versionCode="31210A081F86E80E"
		;;
esac
readonly defaultProfile=$(awk -v versionCode="$versionCode" 'BEGIN {FS="="} $0 ~ versionCode {flag=1} flag && /^Default=Profiles/ {print $2; exit}' "${HOME}/Library/Application Support/Firefox/installs.ini")
defaultProfilePath="/Library/Application Support/Firefox/${defaultProfile}"

if [[ -z ${defaultProfile} ]]; then
	defaultProfileSubtext="❌ No Profiles Found in ~/Library/Application Support/Firefox ❌"
	defaultProfileArg="${HOME}/Library/Application Support/Firefox"
else
	defaultProfileSubtext="~${defaultProfilePath}"
	defaultProfileArg="${HOME}/${defaultProfilePath}"
fi

cat << EOB
{"items": [
	{
		"title": "Open Firefox Profile Manager",
		"icon": { "path": "images/${releaseChannel}Logo.png" },
		"variables": { "pref_id": "profileManager" }
	},
	{
		"title": "Open Default Profile in Finder",
		"subtitle": "${defaultProfileSubtext}",
		"arg": "${defaultProfileArg}",
		"icon": { "path": "images/${releaseChannel}Logo.png" },
		"variables": { "pref_id": "profilePath" }
	},
	{
	    "title": "Configure Workflow...",
		"subtitle": "Open the configuration window for ${alfred_workflow_name}",
		"icon": { "path": "images/${releaseChannel}Logo.png" },
		"variables": { "pref_id": "configure" }
	},
]}
EOB