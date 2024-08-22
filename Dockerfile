# Use a base Windows image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Install PowerShell
SHELL ["powershell", "-Command"]

# Install Scoop
RUN iex (New-Object Net.WebClient).DownloadString('https://get.scoop.sh') ; \
    scoop bucket add extras

# Install Android SDK and NDK using Scoop
RUN scoop install android-sdk ; \
    scoop install android-ndk

# Accept licenses for Android SDK components
RUN & 'C:\ProgramData\scoop\apps\android-sdk\current\tools\bin\sdkmanager.bat' --licenses

# Verify installations
RUN Get-Command 'C:\ProgramData\scoop\apps\android-sdk\current\tools\bin\sdkmanager.bat' ; \
    Get-Command 'C:\ProgramData\scoop\apps\android-ndk\current\ndk-build.cmd'
