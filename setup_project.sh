#!/usr/bin/env bash

handler() {
    echo ""
    echo "   SCRIPT INTERRUPTED by user (Ctrl+C)!"
    echo " Creating backup archive before cleanup..."

    # Create archive with user's name
    if [ -d "YourProjectDirectory" ]; then
        tar -czf "attendance_tracker_${name}_archive" YourProjectDirectory
        echo " Archive created: attendance_tracker_${name}_archive.tar.gz"

        # Delete incomplete directory
        rm -rf YourProjectDirectory
        echo "  Unfinished folder deleted."
    else
        echo "   No project directory to archive."
    fi

    echo "Cleanup complete. Exiting..."
    exit 1
}


# Setup Attendance Tracker


echo "Enter input name:"
read name

BASE_DIR="attendance_tracker_${name}"

# Create directory structure
mkdir -p "$BASE_DIR/Helpers" "$BASE_DIR/reports"

# Create empty files
touch "$BASE_DIR/Helpers/assets.csv"
touch "$BASE_DIR/Helpers/config.json"
touch "$BASE_DIR/reports/reports.log"

cat << 'EOF' > "$BASE_DIR/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
HELPERS_DIR = os.path.join(BASE_DIR, "Helpers")
REPORTS_DIR = os.path.join(BASE_DIR, "reports")

def run_attendance_check():
    # Load config
    with open(os.path.join(HELPERS_DIR, "config.json"), "r") as f:
        config = json.load(f)

    report_path = os.path.join(REPORTS_DIR, "reports.log")

    # Archive old report if it exists
    if os.path.exists(report_path):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename(
            report_path,
            os.path.join(REPORTS_DIR, f"reports_{timestamp}.log.archive")
        )

    # Process CSV data
    with open(os.path.join(HELPERS_DIR, "assets.csv"), "r") as f, \
         open(report_path, "w") as log:

        reader = csv.DictReader(f)
        total_sessions = config["total_sessions"]

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row["Names"]
            email = row["Email"]
            attended = int(row["Attendance Count"])

            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config["thresholds"]["failure"]:
                message = (
                    f"URGENT: {name}, your attendance is "
                    f"{attendance_pct:.1f}%. You will fail this class."
                )
            elif attendance_pct < config["thresholds"]["warning"]:
                message = (
                    f"WARNING: {name}, your attendance is "
                    f"{attendance_pct:.1f}%. Please be careful."
                )

            if message:
                if config["run_mode"] == "live":
                    log.write(
                        f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n"
                    )
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat << 'EOF' > "$BASE_DIR/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
# Config file
cat << 'EOF' > "$BASE_DIR/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_session":15
}
EOF
cat << 'EOF' > "$BASE_DIR/reports/reports.log"
-- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class

EOF

echo "Directory structure created successfully!"


echo "SYSTEM HEALTH CHECK"

# 1. Check Python 3 installation
echo " Checking if  Python 3 is installed"
if command -v python3 &> /dev/null; then
    python_version=$(python3 --version 2>&1)
    echo " $python_version is installed"
else
    echo "      WARNING: python3 is NOT installed!"
    echo "      The attendance checker requires Python 3 to run."
    echo "      Please install Python 3 to use this application."
fi

echo " Verifying project structure"
errors=0

if [ -d "attendance_tracker_$name" ]; then
    echo "Main directory: attendance_tracker_$name"
else
    echo "  Missing: attendance_tracker_$name"
    errors=$((errors+1))
fi

if [ -f "attendance_tracker_$name/attendance_checker.py" ]; then
    echo " File: attendance_checker.py"
else
    echo " Missing: attendance_checker.py"
    errors=$((errors+1))
fi

if [ -d "attendance_tracker_$name/Helpers" ]; then
    echo " Directory: Helpers/"
else
    echo " Missing: Helpers/"
    errors=$((errors+1))
fi

if [ -f "attendance_tracker_$name/Helpers/config.json" ]; then
    echo " File: Helpers/config.json"
else
    echo " Missing: Helpers/config.json"
    errors=$((errors+1))
fi

if [ -f "attendance_tracker_$name/Helpers/assets.csv" ]; then
    echo " File: Helpers/assets.csv"
else
    echo " Missing: Helpers/assets.csv"
    errors=$((errors+1))
fi

if [ -d "attendance_tracker_$name/reports" ]; then
    echo " Directory: reports/"
else
    echo "  Missing: reports/"
    errors=$((errors+1))
fi

if [ -f "attendance_tracker_$name/reports/reports.log" ]; then
    echo "  File: reports/reports.log"
else
    echo "  Missing: reports/reports.log"
    errors=$((errors+1))
fi

echo ""
if [ $errors -eq 0 ]; then
    echo " HEALTH CHECK PASSED All files and folders are present"
else
    echo "   HEALTH CHECK FAILED  $errors items are missing"
    echo "   Please check the errors above."
    exit 1
fi
#task 2
echo "Insert a new warning value:"
read warning

echo "Insert a new failure value:"
read failure

sed -i "s/\"warning\": [0-9]\+/\"warning\": $warning/" "$BASE_DIR/Helpers/config.json"
sed -i "s/\"failure\": [0-9]\+/\"failure\": $failure/" "$BASE_DIR/Helpers/config.json"

echo " nice work Benitha"
echo "Setup complete"

echo " Configuration updated: Warning=$warn%, Failure=$fail%"

echo " Creating working directory..."
mkdir -p YourProjectDirectory

echo "   Press Ctrl+C to test the interrupt handler"



for i in {1..10}; do
    echo "   Processing... $i seconds"
    sleep 1
done

echo ""
echo "Work completed successfully!"
echo " All files are ready in: attendance_tracker_$name/"
echo ""
echo "To run the attendance checker:"
echo "  cd attendance_tracker_$name/"
echo "  python3 attendance_checker.py"
echo "SETUP COMPLETE!"


# Remove the trap for normal completion
trap - SIGINT
