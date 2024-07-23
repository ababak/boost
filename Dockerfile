#
# Author:
# Andriy Babak <ababak@gmail.com>
#
# Build the docker image:
# docker build --rm -t ababak/boost .
# docker run --rm -it ababak/boost powershell
# See README.md for details

# Chocolatey now requires .NET Framework 4.8
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-ltsc2019 as base

LABEL maintainer="ababak@gmail.com"

SHELL ["powershell", "-ExecutionPolicy", "RemoteSigned", "-Command"]

# Install BuildTools
RUN Invoke-WebRequest "https://aka.ms/vs/16/release/vs_buildtools.exe" -OutFile vs_buildtools.exe; \
    Start-Process vs_buildtools.exe -Wait -ArgumentList '\
    --quiet \
    --wait \
    --norestart \
    --nocache \
    --installPath C:/BuildTools \
    --add Microsoft.VisualStudio.Workload.MSBuildTools \
    --add Microsoft.VisualStudio.Workload.VCTools \ 
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 \ 
    --add Microsoft.VisualStudio.Component.Windows10SDK.18362 \ 
    --add Microsoft.VisualStudio.Component.VC.CMake.Project \ 
    --add Microsoft.VisualStudio.Component.TestTools.BuildTools \ 
    --add Microsoft.VisualStudio.Component.VC.ASAN \ 
    --add Microsoft.VisualStudio.Component.VC.140'; \
    Remove-Item c:/vs_buildtools.exe

# Install Chocolatey package manager
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    iex (New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')

# Install Chocolatey packages
RUN choco install -y \
    7zip \
    nasm \
    openssh \
    git \
    vim

# Install Python
RUN choco install -y \
    python39
RUN choco install -y \
    python310
RUN choco install -y \
    python311
RUN choco install -y \
    python312

ENV PYTHONIOENCODING UTF-8

ENV CMAKE_GENERATOR "NMake Makefiles"
RUN setx /M PATH $( \
    'c:/cmake' + ';' + \
    $env:PATH + ';' + \
    $env:PROGRAMFILES + '/NASM' \
    )

RUN Invoke-WebRequest "https://archives.boost.io/release/1.76.0/source/boost_1_76_0.7z" -OutFile boost_1_76_0.7z; \
    7z x boost_1_76_0.7z; \
    Remove-Item boost_1_76_0.7z
RUN Invoke-WebRequest "https://archives.boost.io/release/1.80.0/source/boost_1_80_0.7z" -OutFile boost_1_80_0.7z; \
    7z x boost_1_80_0.7z; \
    Remove-Item boost_1_80_0.7z
RUN Invoke-WebRequest "https://archives.boost.io/release/1.82.0/source/boost_1_82_0.7z" -OutFile boost_1_82_0.7z; \
    7z x boost_1_82_0.7z; \
    Remove-Item boost_1_82_0.7z
RUN Invoke-WebRequest "https://archives.boost.io/release/1.85.0/source/boost_1_85_0.7z" -OutFile boost_1_85_0.7z; \
    7z x boost_1_85_0.7z; \
    Remove-Item boost_1_85_0.7z

WORKDIR /build
ENTRYPOINT [ "C:/BuildTools/Common7/Tools/VsDevCmd.bat", "-arch=amd64", "&&" ]
