FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Suppress interaction with the package manager
ENV DEBIAN_FRONTEND=noninteractive

# Update packages and install necessary tools
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools; \
    Invoke-WebRequest -Uri "https://aka.ms/win32/7zip" -OutFile "C:\7zip.exe"; \
    Start-Process -FilePath "C:\7zip.exe" -ArgumentList "/S" -Wait; \
    Remove-Item -Force "C:\7zip.exe"

# Install Node.js 22.5.1 directly from the official repository
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v22.5.1/node-v22.5.1-x64.msi" -OutFile "C:\nodejs.msi"; \
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i C:\nodejs.msi /quiet" -Wait; \
    Remove-Item -Force "C:\nodejs.msi"

# Install Appium globally with unsafe-perm flag
RUN powershell -Command \
    npm install -g appium@1.22.3 --unsafe-perm=true

# Install appium-doctor
RUN powershell -Command \
    npm install -g @appium/doctor

# Install optional dependencies
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://ffmpeg.org/releases/ffmpeg-release-full.7z" -OutFile "C:\ffmpeg.7z"; \
    Start-Process -FilePath "C:\7z.exe" -ArgumentList "x C:\ffmpeg.7z -oC:\ffmpeg" -Wait; \
    Remove-Item -Force "C:\ffmpeg.7z"

# Install Google Chrome directly from the official repository
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile "C:\chrome_installer.exe"; \
    Start-Process -FilePath "C:\chrome_installer.exe" -ArgumentList "/silent /install" -Wait; \
    Remove-Item -Force "C:\chrome_installer.exe"

# Remove any old Chromedriver
RUN powershell -Command \
    Remove-Item -Force "C:\chromedriver.exe"

# Install ChromeDriver that matches the installed Chrome version
RUN powershell -Command \
    $LATEST_CHROMEDRIVER_VERSION = (Invoke-WebRequest -Uri "https://chromedriver.storage.googleapis.com/LATEST_RELEASE").Content; \
    Invoke-WebRequest -Uri "https://chromedriver.storage.googleapis.com/$LATEST_CHROMEDRIVER_VERSION/chromedriver_win32.zip" -OutFile "C:\chromedriver.zip"; \
    Expand-Archive -Path "C:\chromedriver.zip" -DestinationPath "C:\\"; \
    Remove-Item -Force "C:\chromedriver.zip"

# Set up Android SDK
ENV ANDROID_HOME=C:\opt\android-sdk
ENV PATH=$PATH;$ANDROID_HOME\cmdline-tools\latest\bin;$ANDROID_HOME\platform-tools;$ANDROID_HOME\build-tools\latest

# Install Android SDK command line tools and platform-tools
RUN powershell -Command \
    New-Item -ItemType Directory -Path "$ANDROID_HOME\cmdline-tools"; \
    Invoke-WebRequest -Uri "https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip" -OutFile "C:\android-sdk.zip"; \
    Expand-Archive -Path "C:\android-sdk.zip" -DestinationPath "$ANDROID_HOME\cmdline-tools"; \
    Move-Item -Path "$ANDROID_HOME\cmdline-tools\cmdline-tools" -Destination "$ANDROID_HOME\cmdline-tools\latest"; \
    Remove-Item -Force "C:\android-sdk.zip"

RUN powershell -Command \
    Invoke-WebRequest -Uri "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -OutFile "C:\platform-tools.zip"; \
    Expand-Archive -Path "C:\platform-tools.zip" -DestinationPath "$ANDROID_HOME"; \
    Remove-Item -Force "C:\platform-tools.zip"

# Install Build Tools and SDK Packages
RUN powershell -Command \
    yes | & "$ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager" --licenses --sdk_root="$ANDROID_HOME"; \
    & "$ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager" "platform-tools" "build-tools;30.0.3" "emulator" --verbose

# Verify Build Tools Installation
RUN powershell -Command \
    Get-ChildItem -Path "$ANDROID_HOME\build-tools\30.0.3"; \
    Get-ChildItem -Path "$ANDROID_HOME\cmdline-tools\latest\bin"

# Set PYTHONPATH to include necessary directories
ENV PYTHONPATH=C:\app\PartnerDevices_Automation\Libraries;C:\app\PartnerDevices_Automation\resources\keywords;C:\app\PartnerDevices_Automation;C:\usr\lib\python3.8

# Install Python 3.8 directly from the deadsnakes repository
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe" -OutFile "C:\python.exe"; \
    Start-Process -FilePath "C:\python.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait; \
    Remove-Item -Force "C:\python.exe"

# Copy the requirements file and install Python packages
COPY requirements.txt C:\tmp\requirements.txt
RUN powershell -Command \
    pip install -r C:\tmp\requirements.txt

# Ensure these commands are in the system PATH
ENV PATH="C:\Python38\Scripts;C:\Python38;${PATH}"

WORKDIR C:\app

# Run the startup script
CMD ["powershell.exe", "-NoLogo"]
