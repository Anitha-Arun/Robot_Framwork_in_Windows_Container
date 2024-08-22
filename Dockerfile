# Use Windows Server Core as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set PowerShell as the shell
SHELL ["powershell", "-Command"]

# Install Chocolatey
RUN Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -OutFile 'C:\\install.ps1'; \
    & 'C:\\install.ps1' | Out-Null

# Install Node.js using Chocolatey
RUN choco install nodejs-lts -y

# Install Python 3.8.5
RUN Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe' -OutFile 'C:\\python-3.8.5-amd64.exe'; \
    Start-Process -FilePath 'C:\\python-3.8.5-amd64.exe' -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\\python-3.8.5-amd64.exe'

# Install Appium 1.22.3 and appium-doctor using npm
RUN npm install -g appium@1.22.3 appium-doctor --unsafe-perm=true

# Install Android SDK and NDK using Chocolatey
RUN choco install android-sdk -y; \
    choco install android-ndk -y

# Set environment variables for Android SDK and NDK
ENV ANDROID_HOME=C:\Android\android-sdk
ENV PATH=%PATH%;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\build-tools\30.0.3;%ANDROID_HOME%\ndk\25.2.0

# Check the contents of cmdline-tools
RUN dir "$env:ANDROID_HOME\cmdline-tools\latest\bin"

# Install SDK components and accept licenses
RUN cmd /C "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat --licenses --sdk_root=$env:ANDROID_HOME" & \
    cmd /C "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat platform-tools platforms;android-30 build-tools;30.0.3 --verbose" & \
    cmd /C "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat ndk;25.2.0 --verbose"

# Verify installations
RUN node -v; \
    npm -v; \
    python --version; \
    appium --version; \
    appium-doctor --version; \
    appium-doctor; \
    adb --version

# Default command to keep the container running
CMD ["cmd"]
