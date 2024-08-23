FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]

# Set environment variables
ENV ANDROID_HOME=C:\Android\Sdk
ENV PATH="$PATH;$ANDROID_HOME\cmdline-tools\latest\bin;$ANDROID_HOME\platform-tools;$ANDROID_HOME\build-tools\latest"

# Install Android SDK command line tools and platform-tools
RUN New-Item -Path $env:ANDROID_HOME -ItemType Directory -Force; `
    New-Item -Path "$env:ANDROID_HOME\cmdline-tools" -ItemType Directory -Force; `
    Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip' -OutFile 'C:\commandlinetools.zip'; `
    Expand-Archive -Path 'C:\commandlinetools.zip' -DestinationPath "$env:ANDROID_HOME\cmdline-tools"; `
    Remove-Item -Path 'C:\commandlinetools.zip' -Force; `
    Rename-Item -Path "$env:ANDROID_HOME\cmdline-tools\cmdline-tools" -NewName 'latest'; `
    Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'C:\platform-tools.zip'; `
    Expand-Archive -Path 'C:\platform-tools.zip' -DestinationPath "$env:ANDROID_HOME"; `
    Remove-Item -Path 'C:\platform-tools.zip' -Force

# Install Build Tools and SDK Packages
RUN & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --licenses --sdk_root=$env:ANDROID_HOME; `
    & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "build-tools;30.0.3" "emulator" --verbose

# Verify Build Tools Installation
RUN Test-Path "$env:ANDROID_HOME\build-tools\30.0.3" -and Test-Path "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat"
