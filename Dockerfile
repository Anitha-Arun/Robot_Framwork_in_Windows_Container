# Use a Windows Server Core image with .NET Framework pre-installed
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-ltsc2019

# Set shell to PowerShell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Download and install OpenJDK
RUN Invoke-WebRequest -Uri https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_windows_hotspot_11.0.11_9.zip -OutFile openjdk.zip; \
    Expand-Archive openjdk.zip -DestinationPath C:\Java; \
    Remove-Item openjdk.zip; \
    $javaPath = (Get-ChildItem -Path C:\Java -Filter 'jdk*' -Directory).FullName; \
    [Environment]::SetEnvironmentVariable('JAVA_HOME', $javaPath, [EnvironmentVariableTarget]::Machine); \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';' + $javaPath + '\bin', [EnvironmentVariableTarget]::Machine);

# Install Chocolatey
RUN Invoke-WebRequest -Uri 'https://community.chocolatey.org/install.ps1' -OutFile 'C:\\install.ps1'; \
    & 'C:\\install.ps1'

# Install Node.js using Chocolatey
RUN choco install nodejs-lts -y

# Download and install Python 3.8.5
RUN Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.8.5/python-3.8.5-amd64.exe' -OutFile 'C:\\python-3.8.5-amd64.exe'; \
    Start-Process -FilePath 'C:\\python-3.8.5-amd64.exe' -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -NoNewWindow -Wait; \
    Remove-Item -Path 'C:\\python-3.8.5-amd64.exe'


# Install pip explicitly using ensurepip
RUN python -m ensurepip --default-pip; \
    python -m pip install --upgrade pip

# Install Appium 1.22.3 and appium-doctor using npm
RUN npm install -g appium@1.22.3 appium-doctor --unsafe-perm=true

# Install Android SDK command-line tools
RUN mkdir C:\android-sdk; \
    Invoke-WebRequest -Uri https://dl.google.com/android/repository/commandlinetools-win-8512546_latest.zip -OutFile C:\android-sdk-tools.zip; \
    Expand-Archive C:\android-sdk-tools.zip -DestinationPath C:\android-sdk; \
    Remove-Item C:\android-sdk-tools.zip; \
    Move-Item C:\android-sdk\cmdline-tools C:\android-sdk\latest; \
    mkdir C:\android-sdk\cmdline-tools; \
    Move-Item C:\android-sdk\latest C:\android-sdk\cmdline-tools\latest;

# Set environment variables
RUN [Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\android-sdk', [EnvironmentVariableTarget]::Machine); \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';C:\android-sdk\cmdline-tools\latest\bin;C:\android-sdk\platform-tools', [EnvironmentVariableTarget]::Machine);

# Install Google Chrome
RUN choco install googlechrome -y 

# Manually download and install ChromeDriver
RUN Invoke-WebRequest -Uri 'https://storage.googleapis.com/chrome-for-testing-public/127.0.6533.99/win32/chromedriver-win32.zip' -OutFile 'C:\\chromedriver.zip'; \
    if (Test-Path 'C:\\chromedriver.zip') { \
        Write-Output 'ChromeDriver zip file downloaded.'; \
        Expand-Archive -Path 'C:\\chromedriver.zip' -DestinationPath 'C:\\chromedriver-temp'; \
        Write-Output 'Contents of C:\\chromedriver-temp:'; \
        Get-ChildItem -Path 'C:\\chromedriver-temp' -Recurse; \
        Write-Output 'Attempting to move chromedriver.exe...'; \
        if (-Not (Test-Path 'C:\\Program Files\\chromedriver')) { \
            New-Item -Path 'C:\\Program Files\\chromedriver' -ItemType Directory; \
        } \
        if (Test-Path 'C:\\chromedriver-temp\\chromedriver-win32\\chromedriver.exe') { \
            Move-Item -Path 'C:\\chromedriver-temp\\chromedriver-win32\\chromedriver.exe' -Destination 'C:\\Program Files\\chromedriver\\chromedriver.exe'; \
            Remove-Item -Path 'C:\\chromedriver.zip'; \
            Remove-Item -Path 'C:\\chromedriver-temp' -Recurse; \
        } else { \
            Write-Output 'Extraction successful, but chromedriver.exe not found.'; \
            exit 1; \
        } \
    } else { \
        Write-Output 'ChromeDriver zip file download failed.'; \
        exit 1; \
    }

# Verify ChromeDriver installation
RUN if (Test-Path 'C:\\Program Files\\chromedriver\\chromedriver.exe') { \
        & 'C:\\Program Files\\chromedriver\\chromedriver.exe' --version; \
    } else { \
        Write-Output 'ChromeDriver executable not found.'; \
        exit 1; \
    }

# Copy the requirements.txt file and Python script to the container
COPY requirements.txt C:\\app\\requirements.txt
COPY accept_licenses.py C:\\app\\accept_licenses.py

# Install the required Python packages using python -m pip
RUN python -m pip install --no-cache-dir -r C:\\app\\requirements.txt

# Set the working directory
WORKDIR C:\\app

# Run Python script to accept licenses
RUN python C:\\app\\accept_licenses.py

# Run Appium Doctor
RUN appium-doctor
# Set the PYTHONPATH environment variable
RUN [Environment]::SetEnvironmentVariable('PYTHONPATH', 'C:\\app\\PartnerDevices_Automation\\Libraries;C:\\app\\PartnerDevices_Automation\\resources\\keywords;C:\\app\\PartnerDevices_Automation', [EnvironmentVariableTarget]::Machine);
# Copy the PartnerDevices_Automation folder to the container
COPY PartnerDevices_Automation C:\\app\\PartnerDevices_Automation

CMD ["powershell"]
