FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS base

# Restore the default Windows shell for correct batch processing.
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install 7-Zip
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `Invoke-WebRequest -UseBasicParsing https://www.7-zip.org/a/7z1805-x64.msi -OutFile 7z.msi; `Start-Process msiexec -ArgumentList '/i 7z.msi', '/quiet', '/norestart' -NoNewWindow -Wait; `Remove-Item -Force 7z.msi

# Switch to cmd for SDK installation
SHELL ["cmd", "/S", "/C"]

# Install Android SDK 28 using cmdline tools
RUN curl -SL --output cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-win-8512546_latest.zip && `"C:\Program Files\7-Zip\7z.exe" x cmdline-tools.zip -o"C:\Android\Sdk" && `del cmdline-tools.zip && `move "C:\Android\Sdk\cmdline-tools" "C:\Android\Sdk\cmdline-tools\latest" && `"C:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" --licenses && `"C:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "platforms;android-28"

# Set environment variables
ENV ANDROID_HOME=C:\Android\Sdk
ENV PATH="$PATH;$ANDROID_HOME\cmdline-tools\latest\bin;$ANDROID_HOME\platform-tools"

# Verify SDK installation
RUN dir "%ANDROID_HOME%\cmdline-tools\latest\bin" && dir "%ANDROID_HOME%\platform-tools"
