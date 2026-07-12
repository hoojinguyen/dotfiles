#!/bin/bash
# bootstrap.sh - Universal installer for the development environment

# Exit immediately if a command exits with a non-zero status
set -e

# Resolve script directory first
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd)

# Check if running standalone (e.g. via curl without a cloned repository)
if [ ! -d "./install" ] || [ ! -f "./install/symlinks.sh" ]; then
    echo "=================================================="
    echo "   Installer running in Remote/Standalone mode   "
    echo "=================================================="
    echo "Cloning the dotfiles repository to ~/dotfiles..."
    echo ""

    # Ensure git is installed
    if ! command -v git &> /dev/null; then
        if [ "$(uname -s)" = "Darwin" ]; then
            echo "Git is not installed. Installing Xcode Command Line Tools..."
            xcode-select --install
            echo "Please re-run this command once Xcode Command Line Tools are installed."
        else
            echo "Git is not installed. Attempting to install git..."
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y git
            else
                echo "Error: git is required. Please install git manually and re-run."
            fi
        fi
        
        if ! command -v git &> /dev/null; then
            exit 1
        fi
    fi

    # Clone or update the repository
    if [ ! -d "$HOME/dotfiles" ]; then
        git clone https://github.com/hoojinguyen/dotfiles.git "$HOME/dotfiles"
    else
        echo "Directory ~/dotfiles already exists. Pulling latest changes..."
        cd "$HOME/dotfiles"
        git pull
    fi

    # Execute the local bootstrapped script
    echo ""
    echo "Restarting installer from cloned repository..."
    exec bash "$HOME/dotfiles/bootstrap.sh" "$@"
fi

export DOTFILES="$DOTFILES_ROOT"

# Colors for rich output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Create logs directory
LOG_DIR="$DOTFILES_ROOT/logs"
mkdir -p "$LOG_DIR"

# Track statuses of all steps
# Format: "Step Name:SUCCESS/FAILED:Log File Path"
STEP_STATUSES=()

# Helper to run a step and log output
run_step() {
    local step_num="$1"
    local step_name="$2"
    local script_path="$3"
    
    local log_name=$(echo "$step_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr '/' '_')
    local log_file="$LOG_DIR/${step_num}_${log_name}.log"
    
    echo -e "\n${BLUE}==================================================${NC}"
    echo -e "${BLUE}--> $step_num. Running $step_name...${NC}"
    echo -e "${BLUE}==================================================${NC}"
    
    # Initialize log file
    echo "=== Installation Log for $step_name ===" > "$log_file"
    echo "Started at: $(date)" >> "$log_file"
    echo "Script: $script_path" >> "$log_file"
    echo "--------------------------------------------------" >> "$log_file"
    
    # Disable exit-on-error during script run
    set +e
    (
        export DOTFILES="$DOTFILES_ROOT"
        bash "$script_path"
    ) 2>&1 | tee -a "$log_file"
    local exit_code=${PIPESTATUS[0]}
    set -e
    
    echo "--------------------------------------------------" >> "$log_file"
    echo "Finished at: $(date)" >> "$log_file"
    echo "Exit Code: $exit_code" >> "$log_file"
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}--> $step_name completed successfully.${NC}"
        STEP_STATUSES+=("$step_name:SUCCESS:$log_file")
        return 0
    else
        echo -e "${RED}--> ERROR: $step_name failed with exit code $exit_code.${NC}"
        echo -e "${RED}--> Log captured at: $log_file${NC}"
        STEP_STATUSES+=("$step_name:FAILED:$log_file")
        return 1
    fi
}

echo "=================================================="
echo "   Starting Universal Dotfiles Bootstrap Script   "
echo "=================================================="

# Ensure all scripts are executable
chmod +x install/*.sh scripts/* sync.sh

# Run steps
# Disable exit-on-error to allow all steps to run and report
set +e
run_step "1" "Symlinks Setup" "./install/symlinks.sh"
run_step "1b" "Interactive Onboarding Wizard" "./install/onboarding.sh"
run_step "2" "OS Packages Installer" "./install/os-packages.sh"
run_step "3" "Oh My Zsh Installer" "./install/ohmyzsh.sh"
run_step "4" "Language/Runtime Setup" "./install/runtimes.sh"
set -e

# Generate report content
generate_report() {
    echo ""
    echo "=================================================="
    echo "          INSTALLATION SUMMARY REPORT             "
    echo "=================================================="
    echo ""
    
    local any_failed=false
    for status_entry in "${STEP_STATUSES[@]}"; do
        local name=$(echo "$status_entry" | cut -d':' -f1)
        local status=$(echo "$status_entry" | cut -d':' -f2)
        local log_path=$(echo "$status_entry" | cut -d':' -f3)
        
        if [ "$status" = "SUCCESS" ]; then
            echo -e "  ${GREEN}✓${NC} $name: ${GREEN}SUCCESS${NC}"
        else
            echo -e "  ${RED}✗${NC} $name: ${RED}FAILED${NC}"
            echo -e "     Log file: ${CYAN}$log_path${NC}"
            any_failed=true
        fi
    done
    echo ""
    echo "=================================================="
    
    if [ "$any_failed" = true ]; then
        echo ""
        echo "=================================================="
        echo "                  FAILURE DETAILS                 "
        echo "=================================================="
        for status_entry in "${STEP_STATUSES[@]}"; do
            local name=$(echo "$status_entry" | cut -d':' -f1)
            local status=$(echo "$status_entry" | cut -d':' -f2)
            local log_path=$(echo "$status_entry" | cut -d':' -f3)
            
            if [ "$status" = "FAILED" ]; then
                echo -e "\n${RED}--> Last 10 lines of log for $name:${NC}"
                echo "--------------------------------------------------"
                tail -n 10 "$log_path"
                echo "--------------------------------------------------"
            fi
        done
        echo ""
    fi
}

# Run report and save to file
REPORT_FILE="$LOG_DIR/install_report.txt"
generate_report | tee "$REPORT_FILE.tmp"

# Strips ANSI color codes portably
strip_colors() {
    sed "s/$(printf '\033')\[[0-9;]*m//g"
}
cat "$REPORT_FILE.tmp" | strip_colors > "$REPORT_FILE"
rm "$REPORT_FILE.tmp"

# Check if any step failed
any_failed=false
for status_entry in "${STEP_STATUSES[@]}"; do
    status=$(echo "$status_entry" | cut -d':' -f2)
    if [ "$status" = "FAILED" ]; then
        any_failed=true
    fi
done

if [ "$any_failed" = true ]; then
    echo ""
    echo -e "${RED}==================================================${NC}"
    echo -e "${RED}Universal Dotfiles Bootstrap finished with errors.${NC}"
    echo -e "Please check the logs listed above for debugging."
    echo -e "${RED}==================================================${NC}"
    exit 1
fi

# Finalize path settings
export PATH="$HOME/bin:$PATH"

echo ""
echo "=================================================="
echo "Universal Dotfiles Bootstrap Complete!"
echo "--------------------------------------------------"
echo "Next Steps:"
echo "1. Source or restart your terminal: source ~/.zshrc"
echo "2. Edit ~/.secrets to fill in your API keys."
echo "3. Run 'dotfiles help' to see management commands."
echo "=================================================="
