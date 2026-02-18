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
