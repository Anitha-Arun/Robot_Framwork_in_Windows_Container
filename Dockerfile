FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]

# Set environment variable and create directories
RUN $env:ANDROID_HOME = 'C:\\Android\\Sdk'; \
    New-Item -Path $env:ANDROID_HOME -ItemType Directory -Force; \
    New-Item -Path "$env:ANDROID_HOME\cmdline-tools" -ItemType Directory -Force

# Download and install Android command line tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip' -OutFile 'C:\commandlinetools.zip'; \
    Expand-Archive -Path 'C:\commandlinetools.zip' -DestinationPath "$env:ANDROID_HOME\cmdline-tools"; \
    Remove-Item -Path 'C:\commandlinetools.zip' -Force; \
    Rename-Item -Path "$env:ANDROID_HOME\cmdline-tools\cmdline-tools" -NewName 'latest'

# Download and install Android platform tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'C:\platform-tools.zip'; \
    Expand-Archive -Path 'C:\platform-tools.zip' -DestinationPath "$env:ANDROID_HOME\platform-tools"; \
    Remove-Item -Path 'C:\platform-tools.zip' -Force

# Download and install Java JDK 17
RUN Invoke-WebRequest -Uri 'https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe' -OutFile 'C:\\jdk-17_windows-x64_bin.exe'; \
    Start-Process -FilePath 'C:\\jdk-17_windows-x64_bin.exe' -ArgumentList '/s' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\\jdk-17_windows-x64_bin.exe'

# Set JAVA_HOME environment variable
ENV JAVA_HOME="C:\\Program Files\\Java\\jdk-17"

# Set ANDROID_HOME and update PATH
ENV ANDROID_HOME="C:\\Android\\Sdk"
ENV PATH="${ANDROID_HOME}\\platform-tools;${PATH}"

# Accept SDK licenses and install SDK packages
RUN $sdkmanagerPath = "$env:ANDROID_HOME\\cmdline-tools\\latest\\bin\\sdkmanager.bat"; \
    Write-Host "SDKMANAGER_CMD: $sdkmanagerPath"; \
    & $sdkmanagerPath --licenses --sdk_root=$env:ANDROID_HOME; \
    Start-Process -FilePath $sdkmanagerPath -ArgumentList "--licenses", "--sdk_root=$env:ANDROID_HOME" -NoNewWindow -Wait; \
    & $sdkmanagerPath "platform-tools" "build-tools;30.0.3" "emulator" --verbose

# Verify Build Tools and ADB Installation
RUN Get-ChildItem -Path "$env:ANDROID_HOME\build-tools\30.0.3" -Recurse; \
    Get-ChildItem -Path "$env:ANDROID_HOME\cmdline-tools\latest\bin" -Recurse; \
    adb version
