#!/bin/bash
#
# NotifyMe Reminder Script
# Usage: remind "Your reminder text" [time]
#
# Time formats:
#   - "tomorrow 9am" (default if no time specified)
#   - "today 14:00"
#   - "2024-01-27 10:00"
#   - "+2h" (in 2 hours)
#   - "+30m" (in 30 minutes)
#   - "+1d" (in 1 day)
#
# Examples:
#   remind "Call mom"                     # Tomorrow 9:00
#   remind "Meeting prep" "today 14:00"   # Today at 14:00
#   remind "Review PR" "+2h"              # In 2 hours
#

# ============================================================
# CONFIGURATION - Replace these with your Supabase credentials
# ============================================================
SUPABASE_URL="YOUR_SUPABASE_URL"
SUPABASE_KEY="YOUR_SUPABASE_ANON_KEY"
# ============================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if title is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide a reminder title${NC}"
    echo "Usage: remind \"Your reminder\" [time]"
    exit 1
fi

TITLE="$1"
TIME_INPUT="${2:-tomorrow 9:00}"

# Function to parse time input and convert to ISO format
parse_time() {
    local input="$1"
    local result=""

    # Check for relative time formats (+2h, +30m, +1d)
    if [[ "$input" =~ ^\+([0-9]+)([hmd])$ ]]; then
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

# Send to Supabase
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${SUPABASE_URL}/rest/v1/reminders" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=minimal" \
    -d "{
        \"title\": \"${TITLE}\",
        \"due_at\": \"${DUE_AT}\"
    }")

# Parse response
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ]; then
    # Format the time for display
    DISPLAY_TIME=$(date -d "$DUE_AT" "+%a, %d.%m. %H:%M" 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$DUE_AT" "+%a, %d.%m. %H:%M" 2>/dev/null || echo "$DUE_AT")
    echo -e "${GREEN}Reminder created:${NC} $TITLE"
    echo -e "${GREEN}Due:${NC} $DISPLAY_TIME"
else
    echo -e "${RED}Error creating reminder (HTTP $HTTP_CODE):${NC}"
    echo "$BODY"
    exit 1
fi
