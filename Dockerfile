# Use Windows Server Core as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set PowerShell as the shell for some operations
SHELL ["powershell", "-Command"]

# Set up Android SDK environment variables
ENV ANDROID_HOME=C:\Android
ENV PATH=$env:PATH;$ANDROID_HOME\cmdline-tools\latest\bin;$ANDROID_HOME\platform-tools;$ANDROID_HOME\build-tools\30.0.3

# Switch to CMD shell for directory operations and file handling
SHELL ["cmd", "/S", "/C"]

# Create Android SDK directory
RUN mkdir %ANDROID_HOME%

# Switch to PowerShell for remaining operations
SHELL ["powershell", "-Command"]

# Install Android SDK command line tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip' -OutFile 'C:\android-sdk-tools.zip'; \
    Expand-Archive -Path 'C:\android-sdk-tools.zip' -DestinationPath "$env:ANDROID_HOME\cmdline-tools" -Force; \
    Remove-Item -Path 'C:\android-sdk-tools.zip'; \
    Rename-Item -Path "$env:ANDROID_HOME\cmdline-tools\cmdline-tools" -NewName "latest"

# Install platform tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'C:\platform-tools.zip'; \
    Expand-Archive -Path 'C:\platform-tools.zip' -DestinationPath "$env:ANDROID_HOME" -Force; \
    Remove-Item -Path 'C:\platform-tools.zip'

# Install Build Tools and SDK Packages
RUN & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --licenses --sdk_root=$env:ANDROID_HOME; \
    & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "build-tools;30.0.3" "emulator" --verbose

# Verify Build Tools Installation
RUN Get-ChildItem -Path "$env:ANDROID_HOME\build-tools\30.0.3"; \
    Get-ChildItem -Path "$env:ANDROID_HOME\cmdline-tools\latest\bin"
