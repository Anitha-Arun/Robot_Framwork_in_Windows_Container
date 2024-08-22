FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]

# Install Chocolatey
RUN Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 -UseBasicP | Invoke-Expression

# Install Android SDK, JDK 17, and other necessary packages via Chocolatey
RUN choco install -y android-sdk jdk17

# Set environment variables
ENV JAVA_HOME="C:\\Program Files\\Java\\jdk-17"
ENV ANDROID_HOME="C:\\ProgramData\\chocolatey\\lib\\android-sdk\\tools\\bin"

# Accept licenses and install SDK components
RUN & "$env:ANDROID_HOME\\sdkmanager.bat" --licenses --sdk_root=$env:ANDROID_HOME; \
    & "$env:ANDROID_HOME\\sdkmanager.bat" "platform-tools" "build-tools;30.0.3" "emulator" --verbose

# Verify the installation
RUN Get-Command "$env:ANDROID_HOME\platform-tools\adb.exe"
