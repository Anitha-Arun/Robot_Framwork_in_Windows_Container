FROM mcr.microsoft.com/windows/servercore:ltsc2022
SHELL ["powershell", "-Command"]

# Install Chocolatey and wget
RUN Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -OutFile 'C:\\install.ps1'; \
    & 'C:\\install.ps1'; \
    choco install wget -y

# Set environment variables
ENV ANDROID_HOME=C:\Android\sdk
ENV PATH=$env:PATH;$ANDROID_HOME\cmdline-tools\latest\bin;$ANDROID_HOME\platform-tools;$ANDROID_HOME\build-tools\30.0.3

# Download and install Android SDK command-line tools and platform-tools
RUN wget https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip -O C:\android-sdk-tools.zip ; \
    Expand-Archive -Path C:\android-sdk-tools.zip -DestinationPath $env:ANDROID_HOME -Force ; \
    Remove-Item -Path C:\android-sdk-tools.zip ; \
    Rename-Item -Path "$env:ANDROID_HOME\cmdline-tools\cmdline-tools" -NewName "latest"

RUN wget https://dl.google.com/android/repository/platform-tools-latest-windows.zip -O C:\platform-tools.zip ; \
    Expand-Archive -Path C:\platform-tools.zip -DestinationPath $env:ANDROID_HOME -Force ; \
    Remove-Item -Path C:\platform-tools.zip

# Install SDK packages
RUN & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --licenses --sdk_root=$env:ANDROID_HOME; \
    & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "build-tools;30.0.3" "emulator"

# Verify installation
RUN Get-ChildItem -Path "$env:ANDROID_HOME\build-tools\30.0.3"; \
    Get-ChildItem -Path "$env:ANDROID_HOME\cmdline-tools\latest\bin"
