FROM mcr.microsoft.com/windows/servercore:ltsc2019
    
    # Restore the default Windows shell for correct batch processing.
 SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
    
    #Install 7Zip
 RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
        Invoke-WebRequest -UseBasicParsing https://www.7-zip.org/a/7z1805-x64.msi -OutFile 7z.msi; `
        Start-Process msiexec -ArgumentList '/i 7z.msi', '/quiet', '/norestart' -NoNewWindow -Wait; `
        Remove-Item -Force 7z.msi;
    
    SHELL ["cmd", "/S", "/C"]
    
    # Install Android SDK 28 using cmdline tools for Android 
RUN curl -SL --output cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-win-8512546_latest.zip && "C:\Program Files\7-Zip\7z.exe" e cmdline-tools.zip -o"C:\Program Files (x86)\Android\android-sdk" && cd "C:\Program Files (x86)\Android\android-sdk\tools\bin" && echo y|sdkmanager "platform-tools" "platforms;android-28"
