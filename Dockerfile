FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set environment variables
ENV ANDROID_HOME=C:\Android\android-sdk
ENV PATH=$ANDROID_HOME\tools;$ANDROID_HOME\platform-tools;$PATH

# Install prerequisites
RUN powershell -Command \
    Invoke-WebRequest -Uri https://dl.google.com/android/repository/commandlinetools-win-8512546_latest.zip -OutFile cmdline-tools.zip; \
    Expand-Archive -Path cmdline-tools.zip -DestinationPath C:\Android; \
    Remove-Item -Path cmdline-tools.zip -Force; \
    [System.IO.File]::Move("C:\Android\cmdline-tools\latest", "C:\Android\cmdline-tools\tools"); \
    cd C:\Android\cmdline-tools\tools\bin; \
    .\sdkmanager.bat --licenses; \
    .\sdkmanager.bat "platform-tools" "platforms;android-30"

# Verify installation
RUN powershell -Command \
    & "$env:ANDROID_HOME\platform-tools\adb.exe --version"
