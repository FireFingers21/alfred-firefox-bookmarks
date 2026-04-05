#!/bin/zsh --no-rcs

# Automatically Get History Database for Default Profile
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
readonly history_file="file://${HOME}/Library/Application Support/Firefox/${defaultProfile}/places.sqlite?immutable=1"

query="${1}"
query="${query//\%/\\%}"
query="${query//_/\_}"
query="${query//'/''}"
titleQuery="%${query// /%' ESCAPE '\\' AND p.title LIKE '%}%"
urlQuery="%${query// /%' ESCAPE '\\' AND p.url LIKE '%}%"

readonly sqlQuery="SELECT p.url, p.title, h.visit_date
FROM moz_places p
JOIN moz_historyvisits h ON h.place_id = p.id
WHERE (p.url LIKE '${urlQuery}' ESCAPE '\') OR (p.title LIKE '${titleQuery}' ESCAPE '\')
ORDER BY visit_date DESC
LIMIT 500;"

# Load History
sqlite3 -json ${history_file} ${sqlQuery} | jq -cs \
--arg releaseChannel "$releaseChannel" \
--arg useQL "$useQL" \
'{
    "items": (if (length > 0) then map(unique_by(.url) | sort_by(.visit_date) | reverse | .[] |
    	{
    		"title": (.title // (.url | if (startswith("file://")) then .[7:] else capture("^((?<scheme>[^:/?#]+):)?(//(?<authority>(?<domain>[^/?#:]*)(:(?<port>[0-9]*))?))?").authority end)),
    		"subtitle": "[\(.visit_date/1000000 | strflocaltime("%Y-%m-%d"))] \(.url)",
    		"arg": .url,
    		"quicklookurl": "\(if $useQL == "1" then .url else "" end)",
            "text": { "largetype": "[\(.visit_date/1000000 | strflocaltime("%Y-%m-%d, %I:%M %p"))]\n\n\(.url)" },
            "icon": { "path": "images/\($releaseChannel)History.png" },
    		"mods": {
    			"cmd": {
    				"subtitle": "⌘↩ Open in secondary browser",
    				"arg": .url,
    				"variables": { "bSecondary": true }
    			}
    		}
    	}
    ) else
        [{
			"title": "Search History...",
			"subtitle": "No matching history entries",
			"valid": "false"
		}]
	end)
}'