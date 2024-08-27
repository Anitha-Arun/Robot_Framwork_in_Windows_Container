import subprocess
import time

sdk_manager_path = r"C:\android-sdk\cmdline-tools\latest\bin\sdkmanager.bat"

def run_sdkmanager_command(command):
    try:
        process = subprocess.Popen(
            [sdk_manager_path] + command,
            stdout=subprocess.PIPE,
            stdin=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding='cp1252'  # Use 'cp1252' encoding for Windows
        )

        stdout, stderr = process.communicate(input='y\n' * 10)

        print("STDOUT:", stdout)
        print("STDERR:", stderr)

        if process.returncode != 0:
            print(f"Command {command} failed with return code {process.returncode}")
    except Exception as e:
        print(f"An error occurred: {e}")

run_sdkmanager_command(['--licenses'])
run_sdkmanager_command(['platform-tools', 'platforms;android-28', 'build-tools;28.0.3'])

time.sleep(30)

try:
    process = subprocess.Popen(
        ['C:\\android-sdk\\platform-tools\\adb.exe', 'version'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding='cp1252'  # Use 'cp1252' encoding for Windows
    )
    stdout, stderr = process.communicate()

    print("ADB Version Output:", stdout)
    print("ADB Version Error:", stderr)

    if process.returncode != 0:
        print(f"ADB version check failed with return code {process.returncode}")
except Exception as e:
    print(f"An error occurred while checking ADB version: {e}")
