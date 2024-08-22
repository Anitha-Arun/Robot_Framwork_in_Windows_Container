# Use a base image with Windows Server Core or Nano Server
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install necessary tools
RUN powershell -Command \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri https://chocolatey.org/install.ps1 -UseBasicP -OutFile install.ps1; \
    & .\install.ps1; \
    choco install -y openjdk11

# Set environment variables
ENV JAVA_HOME="C:\Program Files\Java\jdk-11"
ENV ANDROID_SDK_ROOT="C:\Android\Sdk"
ENV PATH="${PATH};${ANDROID_SDK_ROOT}\tools;${ANDROID_SDK_ROOT}\platform-tools"

# Install Android SDK
RUN powershell -Command \
    Invoke-WebRequest -Uri https://dl.google.com/android/repository/commandlinetools-win-8512546_latest.zip -OutFile cmdline-tools.zip; \
    Expand-Archive -Path cmdline-tools.zip -DestinationPath C:\Android; \
    Remove-Item cmdline-tools.zip -Force; \
    cd C:\Android; \
    Move-Item -Path 'cmdline-tools' -Destination 'sdk' -Force; \
    cd sdk\cmdline-tools; \
    mkdir bin; \
    Rename-Item -Path 'bin' -NewName 'cmdline-tools'; \
    cd ..; \
    & .\cmdline-tools\bin\sdkmanager.bat --sdk_root=${ANDROID_SDK_ROOT} --update; \
    & .\cmdline-tools\bin\sdkmanager.bat --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "platforms;android-30" "build-tools;30.0.3" "cmdline-tools;latest"; \
    & .\cmdline-tools\bin\sdkmanager.bat --licenses | Out-Null

# Accept all licenses
RUN powershell -Command \
    & "${ANDROID_SDK_ROOT}\cmdline-tools\bin\sdkmanager.bat" --licenses | Out-Null; \
    & "${ANDROID_SDK_ROOT}\cmdline-tools\bin\sdkmanager.bat" --list

# Set the working directory
WORKDIR /app

# Copy your application code into the container (if needed)
# COPY . /app

# Define the entry point (modify as needed)
ENTRYPOINT ["cmd.exe"]
