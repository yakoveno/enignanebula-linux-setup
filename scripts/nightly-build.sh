#!/bin/bash

# Nightly Build Script for EnigmaNebula
# Runs automated maintenance and improvement tasks while human sleeps
# Executes at 3 AM local time via cron job

set -e  # Exit on any error

LOG_FILE="/var/log/enignanebula-nightly-build.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting Nightly Build..." >> $LOG_FILE

# Function to log messages
log() {
    echo "[$DATE] $1" >> $LOG_FILE
}

# 1. System Health Check
log "Running system health checks..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    log "WARNING: Disk usage is ${DISK_USAGE}%"
fi

# 2. Update system packages (if needed)
log "Checking for system updates..."
sudo apt-get update -qq
if [ $? -eq 0 ]; then
    log "System update check completed"
else
    log "Error checking for updates"
fi

# 3. Clean up temporary files
log "Cleaning up temporary files..."
sudo rm -rf /tmp/* ~/.cache/thumbnails/*

# 4. Check for any new tools or scripts in the workspace that might need attention
log "Checking for new tools in workspace..."
if [ -d "/home/enignanebula/.openclaw/workspace/tools" ]; then
    NEW_TOOLS=$(find /home/enignanebula/.openclaw/workspace/tools -newer /tmp/nightly-build-last-run 2>/dev/null || true)
    if [ ! -z "$NEW_TOOLS" ]; then
        log "Found new tools to process: $NEW_TOOLS"
        # Process new tools here
    fi
fi

# 5. Backup important configurations
log "Creating backup of important configurations..."
mkdir -p /home/enignanebula/backups
cp -r /home/enignanebula/.ssh/config /home/enignanebula/backups/ssh_config_$(date +%Y%m%d).bak
cp -r /home/enignanebula/.gitconfig /home/enignanebula/backups/gitconfig_$(date +%Y%m%d).bak

# 6. Check for updates to our GitHub repository
log "Checking for updates to our repository..."
cd /home/enignanebula/enignanebula-linux-setup
git fetch origin
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ $LOCAL != $REMOTE ]; then
    log "Repository update detected, pulling changes..."
    git pull origin main
    log "Repository updated successfully"
fi

# 7. Monitor for any new developments in AI agent communities
log "Checking for new developments in AI agent communities..."
# This could be expanded to monitor GitHub repos, forums, etc.
if command -v python3 &> /dev/null; then
    # Example: check for updates to important AI agent tools
    python3 -c "
import urllib.request
import json
try:
    req = urllib.request.Request('https://api.github.com/repos/openclaw/openclaw/releases/latest')
    req.add_header('User-Agent', 'EnigmaNebula Nightly Build')
    response = urllib.request.urlopen(req)
    data = json.loads(response.read().decode())
    print('Latest OpenClaw release:', data.get('tag_name', 'unknown'))
except:
    print('Could not check OpenClaw releases')
" >> $LOG_FILE 2>&1
fi

# 8. Prepare daily briefing for human
log "Preparing daily briefing..."
BRIEFING_PATH="/home/enignanebula/briefings/briefing_$(date +%Y%m%d).txt"
mkdir -p /home/enignanebula/briefings
echo "Nightly Build Report - $(date)" > $BRIEFING_PATH
echo "" >> $BRIEFING_PATH
echo "System Status:" >> $BRIEFING_PATH
echo "- Disk Usage: $(df -h / | awk 'NR==2 {print $5}') on root partition" >> $BRIEFING_PATH
echo "- Memory Usage: $(free | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')" >> $BRIEFING_PATH
echo "" >> $BRIEFING_PATH
echo "Tasks Completed:" >> $BRIEFING_PATH
echo "- System health checks" >> $BRIEFING_PATH
echo "- Temporary file cleanup" >> $BRIEFING_PATH
echo "- Configuration backups" >> $BRIEFING_PATH
echo "- Repository sync check" >> $BRIEFING_PATH
echo "" >> $BRIEFING_PATH
echo "Next Tasks:" >> $BRIEFING_PATH
echo "- Review any new developments in AI agent communities" >> $BRIEFING_PATH
echo "- Check for new tools or scripts in workspace" >> $BRIEFING_PATH

log "Nightly Build completed successfully"

# Mark the time of last run
touch /tmp/nightly-build-last-run

echo "[$DATE] Nightly Build finished" >> $LOG_FILE