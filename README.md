# deploy_agent_benithaAnny
This project contains a shell script called setup_project.sh that automatically creates and configures a Student Attendance Tracker workspace.

The script:

Creates the required directory structure

Generates all necessary files

Performs a system health check

Updates configuration values

Handles Ctrl+C interruptions using a signal trap

if Python 3 installed

To check Python version I typed code: python3 --version


I Make the script executable by using this code below:

chmod +x setup_project.sh


i Run the script:

bash setup_project.sh


Enter a name when prompted.

The script will create a folder named:

attendance_tracker_<your_input>

How to Trigger the Archive Feature

During execution, the script will display:

Press Ctrl+C to test the interrupt handler


To trigger the archive feature:

Press Ctrl + C

When triggered, the script will:

Create a compressed archive:

attendance_tracker_<input>_archive.tar.gz


Delete the unfinished project folder.

Exit safely.

This ensures the workspace stays clean.

How to Run the Attendance Checker

After setup completes successfully:

cd attendance_tracker_<input>
python3 attendance_checker.py

