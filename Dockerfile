# Use Windows Server Core as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set PowerShell as the shell
SHELL ["powershell", "-Command"]

# Install Chocolatey
RUN Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -OutFile 'C:\\install.ps1'; \
    & 'C:\\install.ps1'

# Install Node.js using Chocolatey
RUN choco install nodejs-lts -y

# Download and install Java JDK 17
RUN Invoke-WebRequest -Uri 'https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe' -OutFile 'C:\\jdk-17_windows-x64_bin.exe'; \
    Start-Process -FilePath 'C:\\jdk-17_windows-x64_bin.exe' -ArgumentList '/s' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\\jdk-17_windows-x64_bin.exe'

# Install Python 3.8.5
RUN Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe' -OutFile 'C:\\python-3.8.5-amd64.exe'; \
    Start-Process -FilePath 'C:\\python-3.8.5-amd64.exe' -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\\python-3.8.5-amd64.exe'

# Install Appium 1.22.3 and appium-doctor using npm
RUN npm install -g appium@1.22.3 appium-doctor --unsafe-perm=true

# Install Android SDK and related tools using Chocolatey
RUN choco install android-sdk -y
RUN choco install android-ndk -y

# Set environment variables for Android SDK
ENV ANDROID_HOME=C:\ProgramData\chocolatey\lib\android-sdk\tools
ENV PATH=%PATH%;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\build-tools\30.0.3

# Install Android SDK components
RUN sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# Set JAVA_HOME environment variable
ENV JAVA_HOME="C:\\Program Files\\Java\\jdk-17"

# Verify installations and run appium-doctor
RUN node -v; \
    npm -v; \
    java -version; \
    python --version; \
    python3.8 --version; \
    appium --version; \
    appium-doctor --version; \
    appium-doctor

# Default command to keep the container running
CMD ["cmd"]
