# Windows Container Setup
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Update packages and install necessary tools
RUN powershell -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools; \
    Invoke-WebRequest -Uri "https://aka.ms/vs/16/release/vs_buildtools.exe" -OutFile "C:\vs_buildtools.exe"; \
    Start-Process -FilePath "C:\vs_buildtools.exe" -ArgumentList "--quiet --wait --norestart" -NoNewWindow; \
    Remove-Item -Force C:\vs_buildtools.exe

# Install Chocolatey
RUN powershell -NoProfile -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Node.js and Appium
RUN choco install -y nodejs-lts; \
    npm install -g appium@1.22.3 --unsafe-perm=true; \
    npm install -g @appium/doctor

# Install Google Chrome
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile "C:\chrome_installer.exe"; \
    Start-Process -FilePath "C:\chrome_installer.exe" -ArgumentList "/silent /install" -NoNewWindow -Wait; \
    Remove-Item -Force C:\chrome_installer.exe

# Install ChromeDriver
RUN powershell -Command \
    $latestVersion = (Invoke-WebRequest -Uri "https://chromedriver.storage.googleapis.com/LATEST_RELEASE").Content; \
    Invoke-WebRequest -Uri "https://chromedriver.storage.googleapis.com/$latestVersion/chromedriver_win32.zip" -OutFile "C:\chromedriver.zip"; \
    Expand-Archive -Path "C:\chromedriver.zip" -DestinationPath "C:\"; \
    Remove-Item -Force C:\chromedriver.zip; \
    Move-Item -Path "C:\chromedriver.exe" -Destination "C:\Windows\System32"

# Set up Android SDK
ENV ANDROID_HOME=C:\android-sdk
ENV PATH=%PATH%;%ANDROID_HOME%\cmdline-tools\latest\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\build-tools\latest

# Install Android SDK command line tools and platform-tools
RUN mkdir C:\android-sdk\cmdline-tools; \
    Invoke-WebRequest -Uri "https://dl.google.com/android/repository/commandlinetools-win-6609378_latest.zip" -OutFile "C:\android-sdk.zip"; \
    Expand-Archive -Path "C:\android-sdk.zip" -DestinationPath "C:\android-sdk\cmdline-tools"; \
    Remove-Item -Force C:\android-sdk.zip; \
    Rename-Item -Path "C:\android-sdk\cmdline-tools\cmdline-tools" -NewName "latest"

RUN Invoke-WebRequest -Uri "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -OutFile "C:\platform-tools.zip"; \
    Expand-Archive -Path "C:\platform-tools.zip" -DestinationPath "C:\android-sdk"; \
    Remove-Item -Force C:\platform-tools.zip

# Install Build Tools and SDK Packages
RUN yes | C:\android-sdk\cmdline-tools\latest\bin\sdkmanager --licenses --sdk_root=%ANDROID_HOME%; \
    C:\android-sdk\cmdline-tools\latest\bin\sdkmanager "platform-tools" "build-tools;30.0.3" "emulator" --verbose

# Set PYTHONPATH to include necessary directories
ENV PYTHONPATH=C:\app\PartnerDevices_Automation\Libraries;C:\app\PartnerDevices_Automation\resources\keywords;C:\app\PartnerDevices_Automation;C:\Python38\Lib\site-packages

# Install Python 3.8
RUN Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe" -OutFile "C:\python_installer.exe"; \
    Start-Process -FilePath "C:\python_installer.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -NoNewWindow -Wait; \
    Remove-Item -Force C:\python_installer.exe

# Copy the requirements file and install Python packages
COPY requirements.txt C:\tmp\requirements.txt
RUN C:\Python38\python.exe -m pip install -r C:\tmp\requirements.txt

# Ensure these commands are in the system PATH
ENV PATH="C:\Python38;C:\Python38\Scripts;%PATH%"

WORKDIR C:\app

# Run the startup script
CMD ["cmd.exe"]
