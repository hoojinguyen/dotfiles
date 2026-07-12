#!/bin/bash
# install/secrets-setup.sh - Interactively configures local secrets

SECRETS_FILE="$HOME/.secrets"
TEMPLATE_FILE="$(dirname "$0")/../templates/.secrets.example"

echo "=================================================="
echo "Configuring local environment secrets..."
echo "=================================================="

# Ensure ~/.secrets exists
if [ ! -f "$SECRETS_FILE" ]; then
    if [ -f "$TEMPLATE_FILE" ]; then
        echo "Creating $SECRETS_FILE from template..."
        cp "$TEMPLATE_FILE" "$SECRETS_FILE"
    else
        echo "Error: Secrets template not found at $TEMPLATE_FILE."
        exit 1
    fi
fi

# Check if we are running in an interactive shell
if [ ! -t 0 ]; then
    echo "Non-interactive terminal detected. Skipping interactive secrets configuration."
    echo "You can edit ~/.secrets manually later."
    exit 0
fi

# We will read each line of ~/.secrets, find variables with empty strings,
# prompt the user, and write to a temporary file.
TEMP_SECRETS=$(mktemp)

echo "Please fill in the following API keys (press Enter to skip/keep current empty value):"
echo ""

while IFS= read -r line || [ -n "$line" ]; do
    # Match export VAR="VALUE"
    if [[ "$line" =~ ^export[[:space:]]+([A-Za-z0-9_]+)=\"(.*)\"$ ]]; then
        var_name="${BASH_REMATCH[1]}"
        current_val="${BASH_REMATCH[2]}"
        
        # Friendly description formatting (e.g. GEMINI_API_KEY -> Gemini Api Key)
        friendly_name=$(echo "$var_name" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
        
        # Check if it is a placeholder or empty
        is_placeholder=false
        if [ -z "$current_val" ] || \
           [ "$current_val" = "your_token_here" ] || \
           [ "$current_val" = "your_api_key_here" ] || \
           [ "$current_val" = "..." ] || \
           [ "$current_val" = "your_api_key" ] || \
           [ "$current_val" = "your_token" ]; then
            is_placeholder=true
        fi
        
        if [ "$is_placeholder" = true ]; then
            if [ -z "$current_val" ]; then
                display_val="empty"
            else
                display_val="$current_val"
            fi
        else
            # Mask the value for security
            len=${#current_val}
            if [ $len -le 8 ]; then
                display_val="********"
            else
                display_val="${current_val:0:4}...${current_val: -4}"
            fi
        fi
        
        read -r -p "Enter $friendly_name [$display_val]: " user_val
        
        if [ -n "$user_val" ]; then
            echo "export $var_name=\"$user_val\"" >> "$TEMP_SECRETS"
            echo "-> Configured $var_name."
        else
            echo "export $var_name=\"$current_val\"" >> "$TEMP_SECRETS"
        fi
    else
        echo "$line" >> "$TEMP_SECRETS"
    fi
done < "$SECRETS_FILE"

mv "$TEMP_SECRETS" "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"
echo ""
echo "Secrets configuration completed! Saved to $SECRETS_FILE (permissions set to 600)."
