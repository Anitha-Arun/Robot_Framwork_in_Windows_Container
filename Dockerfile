# Use the Windows Server Core 2019 as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set up PowerShell as the default shell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install 7-Zip for extracting files
RUN Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7z1805-x64.msi' -OutFile 'C:\7z.msi'; \
    Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i C:\7z.msi /quiet /norestart' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\7z.msi' -Force

# Set environment variables for the Android SDK
ENV ANDROID_HOME=C:\Android\Sdk
ENV PATH=%PATH%;%ANDROID_HOME%\cmdline-tools\latest\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\build-tools\latest

# Install Android SDK Command Line Tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-8512546_latest.zip' -OutFile 'C:\commandlinetools.zip'; \
    & "C:\Program Files\7-Zip\7z.exe" x 'C:\commandlinetools.zip' -o'C:\Android\Sdk\cmdline-tools'; \
    Remove-Item -Path 'C:\commandlinetools.zip' -Force; \
    Rename-Item -Path 'C:\Android\Sdk\cmdline-tools\cmdline-tools' -NewName 'latest'

# Install Android platform-tools
RUN Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'C:\platform-tools.zip'; \
    & "C:\Program Files\7-Zip\7z.exe" x 'C:\platform-tools.zip' -o'C:\Android\Sdk'; \
    Remove-Item -Path 'C:\platform-tools.zip' -Force

# Install Java JDK 17
RUN Invoke-WebRequest -Uri 'https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe' -OutFile 'C:\jdk-17_windows-x64_bin.exe'; \
    Start-Process -FilePath 'C:\jdk-17_windows-x64_bin.exe' -ArgumentList '/s' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\jdk-17_windows-x64_bin.exe' -Force

# Set JAVA_HOME environment variable
ENV JAVA_HOME="C:\Program Files\Java\jdk-17"

# Install Appium
RUN Invoke-WebRequest -Uri 'https://nodejs.org/dist/v16.19.1/node-v16.19.1-x64.msi' -OutFile 'C:\nodejs.msi'; \
    Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i C:\nodejs.msi /quiet /norestart' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\nodejs.msi' -Force; \
    npm install -g appium@1.22.3 --unsafe-perm=true --allow-root

# Accept Android SDK licenses
RUN & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" --licenses

# Install Android SDK build tools and platforms
RUN & "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat" "build-tools;30.0.3" "platforms;android-30" --verbose

# Verify installations
RUN if (Test-Path "$env:ANDROID_HOME\build-tools\30.0.3") { \
    Write-Host 'Build tools installed'; \
    } else { \
    Write-Host 'Build tools not installed'; exit 1; \
    }

# Expose Appium port
EXPOSE 4723

# Set the default command to run Appium
ENTRYPOINT ["C:\\Program Files\\nodejs\\node.exe", "C:\\Users\\ContainerAdministrator\\AppData\\Roaming\\npm\\node_modules\\appium\\build\\lib\\appium.js", "--address", "0.0.0.0"]
