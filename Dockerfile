FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]

# Set environment variables
ENV ANDROID_HOME=C:\\Android\\Sdk
ENV PATH=%PATH%;%ANDROID_HOME%\\cmdline-tools\\latest\\bin;%ANDROID_HOME%\\platform-tools;%ANDROID_HOME%\\build-tools\\30.0.3

# Create Android SDK directories
RUN New-Item -Path $env:ANDROID_HOME -ItemType Directory -Force; `
    New-Item -Path "$env:ANDROID_HOME\\cmdline-tools" -ItemType Directory -Force

# Download and install Android command line tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip' -OutFile 'C:\\commandlinetools.zip'; `
    Expand-Archive -Path 'C:\\commandlinetools.zip' -DestinationPath "$env:ANDROID_HOME\\cmdline-tools"; `
    Remove-Item -Path 'C:\\commandlinetools.zip' -Force; `
    Rename-Item -Path "$env:ANDROID_HOME\\cmdline-tools\\cmdline-tools" -NewName 'latest'

# Download and install Android platform tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'C:\\platform-tools.zip'; `
    Expand-Archive -Path 'C:\\platform-tools.zip' -DestinationPath "$env:ANDROID_HOME"; `
    Remove-Item -Path 'C:\\platform-tools.zip' -Force

# Install Build Tools and SDK Packages
RUN & "$env:ANDROID_HOME\\cmdline-tools\\latest\\bin\\sdkmanager.bat" --licenses; `
    & "$env:ANDROID_HOME\\cmdline-tools\\latest\\bin\\sdkmanager.bat" "platform-tools" "build-tools;30.0.3" "emulator" --verbose

# Verify installation
RUN if (Test-Path "$env:ANDROID_HOME\\build-tools\\30.0.3") { Write-Host 'Build Tools installed'; } else { Write-Host 'Build Tools not found'; exit 1; }
RUN if (Test-Path "$env:ANDROID_HOME\\cmdline-tools\\latest\\bin\\sdkmanager.bat") { Write-Host 'sdkmanager found'; } else { Write-Host 'sdkmanager not found'; exit 1; }
