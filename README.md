This the Automation setup where u can set the Automation  to run in Docker , This Automation framework is created in Docker
This Dockerfile provides a Windows Server Core-based container to set up an environment for mobile automation testing using Appium, Android SDK, Java (OpenJDK 11), Google Chrome, ChromeDriver, Node.js, and Python. It is designed to run in a Windows-based Docker container, ideal for automating mobile app testing on Android devices, managing testing environments, and integrating into CI/CD pipelines for continuous testing.

Key Features:
Windows Server Core Base Image: The setup uses a lightweight Windows Server Core image with .NET Framework 4.8 pre-installed. It provides a minimal base for running automation tasks and installing dependencies needed for testing mobile apps on Android.

OpenJDK (Java 11): Installs OpenJDK 11, which is essential for running Appium-based tests that require Java. The Java environment is properly set up with the necessary JAVA_HOME environment variable.

Chocolatey for Package Management: Chocolatey is installed to facilitate the installation of Node.js (LTS), Google Chrome, and other dependencies within the container.

Appium 1.22.3: The Dockerfile installs Appium 1.22.3, a popular automation framework for mobile and desktop applications. Appium is configured to use with Android SDK and ChromeDriver for testing web applications on mobile browsers.

Android SDK Command-Line Tools: Installs the Android SDK command-line tools that are required for managing Android emulators, devices, and app installations. The environment is properly set up for seamless interaction with Android devices.

Google Chrome & ChromeDriver: This setup includes the installation of Google Chrome and ChromeDriver, ensuring compatibility for running Appium tests on web views in Android apps. The ChromeDriver is manually downloaded and installed in the correct directory.

Python 3.8.5: Python 3.8.5 is installed, along with pip, for running Python-based automation scripts. The requirements.txt file is copied into the container to install necessary Python libraries.

Automation Scripts: A Python script accept_licenses.py is included to automate the acceptance of SDK licenses, ensuring that the Android SDK is ready for use.

Appium Doctor: The Dockerfile runs Appium Doctor to verify that the installation is correct and that all required dependencies are installed.

Python Path Configuration: The environment is configured with the PYTHONPATH to include the PartnerDevices_Automation folder for running Python-based test scripts.

CI/CD Integration: This Docker image is ideal for integration with CI/CD tools (like Jenkins, GitHub Actions, or Azure Pipelines) to run automated mobile tests on Android applications across different devices.

Installation Steps:
Clone the Repository:

bash
Copy
git clone https://github.com/your-username/appium-windows-docker.git
cd appium-windows-docker
Build the Docker Image:

bash
Copy
docker build -t appium-windows-sdk .
Run the Docker Container:

bash
Copy
docker run -it appium-windows-sdk
Run Mobile Tests:

Connect your Android device or emulator.
Run Appium tests or execute Python scripts inside the container.
Dependencies:
Appium 1.22.3
Node.js LTS
Python 3.8.5
OpenJDK 11
Android SDK
Google Chrome & ChromeDriver
Chocolatey (for package management)
CI/CD Pipeline Example (GitHub Actions):
To integrate the environment into a GitHub Actions pipeline, you can create a .github/workflows/test.yml file:

yaml
Copy
name: Run Mobile Tests

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  test:
    runs-on: windows-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Build Docker image
      run: |
        docker build -t appium-windows-sdk .
        docker run -it appium-windows-sdk

    - name: Run tests
      run: |
        # Run your Appium tests here
        python -m unittest discover -s tests/
This is a Python script written and maintained by Anitha.Damarla.
for Doubts please contant :Anithadamarla0313@gmail.com
