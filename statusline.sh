# Read JSON data that Claude Code sends to stdin
input=$(cat)

# Extract fields using jq
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
INTOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0' | cut -d. -f1)
OUTTOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Function to format numbers to 1 decimal place with K/M
format_number() {
  num=$1

  if [ "$num" -ge 1000000 ]; then
    awk -v n="$num" 'BEGIN {
      val = n/1000000;
      printf (val == int(val)) ? "%dM\n" : "%.1fM\n", val
    }'
  elif [ "$num" -ge 1000 ]; then
    awk -v n="$num" 'BEGIN {
      val = n/1000;
      printf (val == int(val)) ? "%dK\n" : "%.1fK\n", val
    }'
  else
    echo "$num"
  fi
}

# Formating the numbers
INTOKENS_FMT=$(format_number "$INTOKENS")
OUTTOKENS_FMT=$(format_number "$OUTTOKENS")
COST_FMT=$(printf '$%.2f' "$COST")

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
BAR=$(printf "%${FILLED}s" | tr ' ' '█')$(printf "%${EMPTY}s" | tr ' ' '░')


# Output the status line
echo "${CYAN}[$MODEL]${RESET} context:${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${INTOKENS_FMT}↓ ${OUTTOKENS_FMT}↑ (in/out)"
# echo "${YELLOW}${COST_FMT}${RESET}"
# echo "[$MODEL] | ${PCT}% context | ${INTOKENS_FMT} in ${OUTTOKENS_FMT} out | 💰 $COST_FMT"%
