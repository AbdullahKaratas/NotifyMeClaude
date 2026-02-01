#!/bin/bash
#
# NotifyMe Reminder Script
# Usage: remind "Your reminder text" [time] [description]
#        remind "Your reminder text" [time] --desc-file /path/to/file
#        echo "description" | remind "Your reminder text" [time] --stdin
#
# Time formats:
#   - "tomorrow 9am" (default if no time specified)
#   - "today 14:00"
#   - "2024-01-27 10:00"
#   - "+2h" (in 2 hours)
#   - "+30m" (in 30 minutes)
#   - "+1d" (in 1 day)
#   - "now" (immediate)
#
# Examples:
#   remind "Call mom"                                    # Tomorrow 9:00
#   remind "Meeting prep" "today 14:00"                  # Today at 14:00
#   remind "Review PR" "+2h"                             # In 2 hours
#   remind "Analysis" "now" "Full markdown description"  # With description
#   remind "Report" "+1h" --desc-file report.md          # From file
#   echo "$ANALYSIS" | remind "Silver Analysis" "now" --stdin  # From stdin
#

# ============================================================
# CONFIGURATION
# ============================================================
SUPABASE_URL="https://zeisrosiohbnasvinlmp.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InplaXNyb3Npb2hibmFzdmlubG1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1MTg2NTEsImV4cCI6MjA4NTA5NDY1MX0.viQcx3dO9J9WWmnnH4gt4_S0DzXNbeRBENy5Es5jOIw"
# ============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if title is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide a reminder title${NC}"
    echo "Usage: remind \"Your reminder\" [time] [description]"
    echo "       remind \"Your reminder\" [time] --desc-file /path/to/file"
    echo "       echo \"desc\" | remind \"Your reminder\" [time] --stdin"
    exit 1
fi

TITLE="$1"
TIME_INPUT="${2:-tomorrow 9:00}"
DESCRIPTION=""

# Parse optional description arguments
shift 2 2>/dev/null || shift 1 2>/dev/null || true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --stdin)
            # Read description from stdin
            DESCRIPTION=$(cat)
            shift
            ;;
        --desc-file)
            # Read description from file
            if [ -f "$2" ]; then
                DESCRIPTION=$(cat "$2")
            else
                echo -e "${RED}Error: File not found: $2${NC}"
                exit 1
            fi
            shift 2
            ;;
        *)
            # Assume it's a direct description
            DESCRIPTION="$1"
            shift
            ;;
    esac
done

# Function to parse time input and convert to ISO format
parse_time() {
    local input="$1"
    local result=""

    # Check for "now"
    if [[ "$input" == "now" ]]; then
        result=$(date "+%Y-%m-%dT%H:%M:%S")

    # Check for relative time formats (+2h, +30m, +1d)
    elif [[ "$input" =~ ^\+([0-9]+)([hmd])$ ]]; then
        local amount="${BASH_REMATCH[1]}"
        local unit="${BASH_REMATCH[2]}"

        case "$unit" in
            h) result=$(date -d "+${amount} hours" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -v+${amount}H "+%Y-%m-%dT%H:%M:%S") ;;
            m) result=$(date -d "+${amount} minutes" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -v+${amount}M "+%Y-%m-%dT%H:%M:%S") ;;
            d) result=$(date -d "+${amount} days" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || date -v+${amount}d "+%Y-%m-%dT%H:%M:%S") ;;
        esac

    # Check for "today HH:MM"
    elif [[ "$input" =~ ^today[[:space:]]+([0-9]{1,2}):?([0-9]{2})?$ ]]; then
        local hour="${BASH_REMATCH[1]}"
        local min="${BASH_REMATCH[2]:-00}"
        local today=$(date "+%Y-%m-%d")
        result="${today}T${hour}:${min}:00"

    # Check for "tomorrow HH:MM"
    elif [[ "$input" =~ ^tomorrow[[:space:]]+([0-9]{1,2}):?([0-9]{2})?$ ]]; then
        local hour="${BASH_REMATCH[1]}"
        local min="${BASH_REMATCH[2]:-00}"
        local tomorrow=$(date -d "+1 day" "+%Y-%m-%d" 2>/dev/null || date -v+1d "+%Y-%m-%d")
        result="${tomorrow}T${hour}:${min}:00"

    # Check for ISO-ish format "YYYY-MM-DD HH:MM"
    elif [[ "$input" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2})[[:space:]]+([0-9]{1,2}):([0-9]{2})$ ]]; then
        local date_part="${BASH_REMATCH[1]}"
        local hour="${BASH_REMATCH[2]}"
        local min="${BASH_REMATCH[3]}"
        result="${date_part}T${hour}:${min}:00"

    # Default: try to let date parse it
    else
        # Try GNU date first, then macOS date
        result=$(date -d "$input" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null)
        if [ -z "$result" ]; then
            # Fallback to tomorrow 9:00
            local tomorrow=$(date -d "+1 day" "+%Y-%m-%d" 2>/dev/null || date -v+1d "+%Y-%m-%d")
            result="${tomorrow}T09:00:00"
            echo -e "${YELLOW}Warning: Could not parse time '$input', using tomorrow 9:00${NC}"
        fi
    fi

    echo "$result"
}

# Parse the time
DUE_AT=$(parse_time "$TIME_INPUT")

# Check configuration
if [ "$SUPABASE_URL" = "YOUR_SUPABASE_URL" ]; then
    echo -e "${RED}Error: Please configure SUPABASE_URL in this script${NC}"
    exit 1
fi

if [ "$SUPABASE_KEY" = "YOUR_SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}Error: Please configure SUPABASE_KEY in this script${NC}"
    exit 1
fi

# Escape special characters for JSON
escape_json() {
    local str="$1"
    str="${str//\\/\\\\}"     # Backslash
    str="${str//\"/\\\"}"     # Double quote
    str="${str//$'\n'/\\n}"   # Newline
    str="${str//$'\r'/\\r}"   # Carriage return
    str="${str//$'\t'/\\t}"   # Tab
    echo "$str"
}

ESCAPED_TITLE=$(escape_json "$TITLE")
ESCAPED_DESC=$(escape_json "$DESCRIPTION")

# Build JSON payload
if [ -n "$DESCRIPTION" ]; then
    JSON_PAYLOAD="{
        \"title\": \"${ESCAPED_TITLE}\",
        \"description\": \"${ESCAPED_DESC}\",
        \"due_at\": \"${DUE_AT}\"
    }"
else
    JSON_PAYLOAD="{
        \"title\": \"${ESCAPED_TITLE}\",
        \"due_at\": \"${DUE_AT}\"
    }"
fi

# Send to Supabase
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${SUPABASE_URL}/rest/v1/reminders" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=minimal" \
    -d "$JSON_PAYLOAD")

# Parse response
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ]; then
    # Format the time for display
    DISPLAY_TIME=$(date -d "$DUE_AT" "+%a, %d.%m. %H:%M" 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$DUE_AT" "+%a, %d.%m. %H:%M" 2>/dev/null || echo "$DUE_AT")
    echo -e "${GREEN}✓ Reminder created:${NC} $TITLE"
    echo -e "${BLUE}  Due:${NC} $DISPLAY_TIME"
    if [ -n "$DESCRIPTION" ]; then
        DESC_PREVIEW="${DESCRIPTION:0:50}"
        if [ ${#DESCRIPTION} -gt 50 ]; then
            DESC_PREVIEW="${DESC_PREVIEW}..."
        fi
        echo -e "${BLUE}  Description:${NC} $DESC_PREVIEW"
    fi
else
    echo -e "${RED}Error creating reminder (HTTP $HTTP_CODE):${NC}"
    echo "$BODY"
    exit 1
fi
