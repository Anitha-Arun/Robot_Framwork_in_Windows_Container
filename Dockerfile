# Use the Windows Server Core image as the base
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install Chocolatey
RUN powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command `iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) ; `choco install -y git

# Install Android SDK and other packages using Chocolatey
RUN choco install -y android-sdk adb android-ndk androidstudio

# Copy pre-accepted license files into the container
COPY ["tools/android-licenses/", "C:/Android/android-sdk/licenses/"]

# Install Android SDK components and accept licenses
RUN powershell -NoProfile -Command `& 'C:\Android\android-sdk\tools\bin\sdkmanager.bat' "platforms;android-26" "platforms;android-25" "build-tools;25.0.3" "build-tools;26.0.2" ; `& 'C:\Android\android-sdk\tools\bin\sdkmanager.bat' --licenses

# Set environment variables
ENV ANDROID_HOME=C:\Android\android-sdk
ENV PATH=$PATH;C:\Android\android-sdk\tools;C:\Android\android-sdk\build-tools;C:\Android\android-sdk\platform-tools

# Set the working directory
WORKDIR /app

# Optional: copy any required files or perform additional setup
# COPY . /app

# Default command (adjust as needed)
CMD ["powershell"]
