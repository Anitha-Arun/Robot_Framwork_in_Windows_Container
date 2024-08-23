FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Use PowerShell as the default shell
SHELL ["powershell", "-Command"]

# Install Chocolatey
RUN Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1' -OutFile 'install.ps1'; \
    & .\install.ps1



# Install Android SDK using Chocolatey
RUN choco install android-sdk  --yes

# Set environment variables
ENV ANDROID_HOME="C:\\ProgramData\\chocolatey\\lib\\android-sdk\\tools"
ENV PATH="${PATH};${ANDROID_HOME}\\bin;${ANDROID_HOME}\\platform-tools"

# Manually create license files to accept licenses
RUN $env:ANDROID_HOME = 'C:\\ProgramData\\chocolatey\\lib\\android-sdk'; \
    New-Item -Path "$env:ANDROID_HOME\\licenses" -ItemType Directory -Force; \
    $license1 = '8933bad161af4178b1185d1a37fbf41ea5269c55'; \
    $license2 = '84831b9409646a918e30573bab4c9c91346d8abd'; \
    Set-Content -Path "$env:ANDROID_HOME\\licenses\\android-sdk-license" -Value "`n$license1" -Force; \
    Set-Content -Path "$env:ANDROID_HOME\\licenses\\android-sdk-preview-license" -Value "`n$license2" -Force

# Install specific SDK components using Command Prompt
SHELL ["cmd", "/S", "/C"]

RUN echo yes | %ANDROID_HOME%\\cmdline-tools\\latest\\bin\\sdkmanager.bat "build-tools;34.0.0" && \
    echo yes | %ANDROID_HOME%\\cmdline-tools\\latest\\bin\\sdkmanager.bat "platforms;android-33"

# Verify installation
RUN if exist "%ANDROID_HOME%\\cmdline-tools\\latest\\bin\\sdkmanager.bat" ( \
    echo sdkmanager found; \
    ) else ( \
    echo sdkmanager not found; exit 1; \
    )
