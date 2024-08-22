# Use a Windows Server Core base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set PowerShell as the default shell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install necessary tools
RUN choco install -y wget 7zip curl nodejs-lts openjdk11 python3 git

# Install Node.js 22.5.1 (or the latest LTS version available)
RUN choco install nodejs-lts -y

# Install Appium globally
RUN npm install -g appium@1.22.3 --unsafe-perm=true

# Install appium-doctor
RUN npm install -g @appium/doctor

# Install Google Chrome
RUN choco install googlechrome -y

# Install ChromeDriver
RUN $ChromeVersion = (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo.FileVersion; \
    $ChromeDriverVersion = (Invoke-WebRequest "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$($ChromeVersion.Split('.')[0])").Content; \
    Invoke-WebRequest "https://chromedriver.storage.googleapis.com/$ChromeDriverVersion/chromedriver_win32.zip" -OutFile "$env:TEMP\chromedriver.zip"; \
    Expand-Archive "$env:TEMP\chromedriver.zip" -DestinationPath $env:SystemRoot; \
    Remove-Item "$env:TEMP\chromedriver.zip"

# Set up Android SDK
ENV ANDROID_HOME C:\Android\android-sdk
ENV PATH ${PATH};${ANDROID_HOME}\tools;${ANDROID_HOME}\platform-tools;${ANDROID_HOME}\cmdline-tools\latest\bin

# Install Android SDK command line tools and platform-tools
RUN New-Item -Path $env:ANDROID_HOME\cmdline-tools -ItemType Directory -Force; \
    Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip' -OutFile 'android-sdk.zip'; \
    Expand-Archive -Path 'android-sdk.zip' -DestinationPath $env:ANDROID_HOME\cmdline-tools; \
    Move-Item -Path $env:ANDROID_HOME\cmdline-tools\cmdline-tools -Destination $env:ANDROID_HOME\cmdline-tools\latest; \
    Remove-Item -Path 'android-sdk.zip' -Force

RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'platform-tools.zip'; \
    Expand-Archive -Path 'platform-tools.zip' -DestinationPath $env:ANDROID_HOME; \
    Remove-Item -Path 'platform-tools.zip' -Force

# Install Build Tools and SDK Packages
RUN echo y | & $env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat --licenses --sdk_root=$env:ANDROID_HOME; \
    & $env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat 'platform-tools' 'build-tools;30.0.3' 'emulator' --verbose

# Verify Build Tools Installation
RUN Get-ChildItem -Path $env:ANDROID_HOME\build-tools\30.0.3; \
    Get-ChildItem -Path $env:ANDROID_HOME\cmdline-tools\latest\bin

# Set PYTHONPATH
ENV PYTHONPATH C:\app\PartnerDevices_Automation\Libraries;C:\app\PartnerDevices_Automation\resources\keywords;C:\app\PartnerDevices_Automation;C:\Python38\Lib

# Copy the requirements file and install Python packages
COPY requirements.txt C:\requirements.txt
RUN pip3 install -r C:\requirements.txt

# Set working directory
WORKDIR C:\app

# Set the entry point
ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
