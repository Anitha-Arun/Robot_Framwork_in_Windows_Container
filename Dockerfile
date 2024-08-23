# Use a Windows Server Core base image with PowerShell
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install the Android SDK Command Line Tools
RUN powershell -Command \
    Invoke-WebRequest -Uri https://dl.google.com/android/repository/commandlinetools-win-8512546_latest.zip -OutFile cmdline-tools.zip; \
    Expand-Archive -Path cmdline-tools.zip -DestinationPath C:\Android; \
    Remove-Item -Path cmdline-tools.zip -Force; \
    [System.IO.Directory]::Move("C:\Android\cmdline-tools\latest", "C:\Android\cmdline-tools\tools"); \
    cd C:\Android\cmdline-tools\tools\bin; \
    .\sdkmanager.bat --licenses; \
    .\sdkmanager.bat "platform-tools" "platforms;android-30"

# Set environment variables
ENV ANDROID_HOME C:/Android
ENV PATH $PATH;C:/Android/platform-tools;C:/Android/tools

# Entry point or CMD if needed
# CMD ["powershell"]
