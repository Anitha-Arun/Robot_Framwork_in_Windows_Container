# Use Windows Server Core as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set PowerShell as the shell
SHELL ["powershell", "-Command"]

# Install Chocolatey and Node.js in a single step to minimize layers
RUN Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -OutFile 'C:\\install.ps1'; \
    & 'C:\\install.ps1'; \
    choco install nodejs-lts -y

# Download and install Python 3.8.5
RUN Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe' -OutFile 'C:\\python-3.8.5-amd64.exe'; \
    Start-Process -FilePath 'C:\\python-3.8.5-amd64.exe' -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\\python-3.8.5-amd64.exe'

# Install Appium and appium-doctor using npm
RUN npm install -g appium@1.22.3 appium-doctor --unsafe-perm=true

# Download and install Android Command Line Tools and Platform Tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-8512546_latest.zip' -OutFile 'C:\\cmdline-tools.zip'; \
    Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools_r34.0.1-windows.zip' -OutFile 'C:\\platform-tools.zip'; \
    Expand-Archive -Path 'C:\\cmdline-tools.zip' -DestinationPath 'C:\\cmdline-tools-temp'; \
    Expand-Archive -Path 'C:\\platform-tools.zip' -DestinationPath 'C:\\ProgramData\\android-sdk\\platform-tools'; \
    Remove-Item -Path 'C:\\cmdline-tools.zip', 'C:\\platform-tools.zip'; \
    if (-Not (Test-Path 'C:\\ProgramData\\android-sdk\\cmdline-tools\\latest')) { \
        New-Item -Path 'C:\\ProgramData\\android-sdk\\cmdline-tools\\latest' -ItemType Directory; \
    } \
    Move-Item -Path 'C:\\cmdline-tools-temp\\cmdline-tools\\*' -Destination 'C:\\ProgramData\\android-sdk\\cmdline-tools\\latest'; \
    Remove-Item -Path 'C:\\cmdline-tools-temp' -Recurse

# Download and install Android SDK Tools (optional, if needed)
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/sdk-tools-windows-4333796.zip' -OutFile 'C:\\sdk-tools.zip'; \
    Expand-Archive -Path 'C:\\sdk-tools.zip' -DestinationPath 'C:\\ProgramData\\android-sdk\\tools'; \
    Remove-Item -Path 'C:\\sdk-tools.zip'

# Ensure correct PATH and ANDROID_HOME for Android SDK
ENV ANDROID_HOME="C:\\ProgramData\\android-sdk" `ANDROID_SDK_ROOT="C:\\ProgramData\\android-sdk" `PATH="${PATH};C:\\ProgramData\\android-sdk\\platform-tools;C:\\ProgramData\\android-sdk\\cmdline-tools\\latest\\bin;C:\\ProgramData\\android-sdk\\tools;C:\\Program Files\\nodejs;C:\\ProgramData\\chocolatey\\bin"
# Install missing Android SDK components
RUN & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --licenses --sdk_root=$env:ANDROID_HOME; \
    & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "platforms;android-30" "build-tools;30.0.3" "emulator" "cmdline-tools;latest" "tools" --verbose
# Download and install Java JDK 17
RUN Invoke-WebRequest -Uri 'https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe' -OutFile 'C:\\jdk-17_windows-x64_bin.exe'; \
    Start-Process -FilePath 'C:\\jdk-17_windows-x64_bin.exe' -ArgumentList '/s' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\\jdk-17_windows-x64_bin.exe'

# Set JAVA_HOME environment variable
ENV JAVA_HOME="C:\\Program Files\\Java\\jdk-17"

# Verify installations and run appium-doctor
RUN Write-Output "PATH: $env:PATH"; \
    Write-Output "Checking platform-tools directory:"; \
    Get-ChildItem -Path 'C:\\ProgramData\\android-sdk\\platform-tools'; \
    Write-Output "Checking adb executable:"; \
    Get-Command adb -ErrorAction SilentlyContinue; \
    Write-Output "Node.js path: $(Get-Command node).Source"; \
    Write-Output "npm path: $(Get-Command npm).Source"; \
    Write-Output "Python path: $(Get-Command python).Source"; \
    Write-Output "Appium path: $(Get-Command appium).Source"; \
    Write-Output "Appium Doctor path: $(Get-Command appium-doctor).Source"; \
    Write-Output "Java path: $(Get-Command java).Source"; \
    node -v; \
    npm -v; \
    python --version; \
    appium --version; \
    appium-doctor --version; \
    appium-doctor; \
    adb --version; \
    java -version

# Default command to keep the container running
CMD [ "cmd" ]
