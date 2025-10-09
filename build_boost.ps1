# Build the following Boost versions with Python:
$boost_python = [ordered]@{
    "1_76_0" = @("3.9");
    "1_80_0" = @("3.10");
    "1_82_0" = @("3.11");
    "1_85_0" = @("3.11", "3.12");
    "1_88_0" = @("3.13");
}

foreach ($bp in $boost_python.getEnumerator()) {
    $BOOST_VER = $bp.Name
    Write-Host "Building Boost: $BOOST_VER"
    
    $boost_source = "/boost_$BOOST_VER"
    
    # First, build all Python-agnostic libraries once
    Write-Host "Building Boost $BOOST_VER"
    Push-Location $boost_source
    & .\bootstrap.bat
    & .\b2 `
        --with-atomic `
        --with-chrono `
        --with-container `
        --with-context `
        --with-contract `
        --with-coroutine `
        --with-date_time `
        --with-exception `
        --with-fiber `
        --with-filesystem `
        --with-graph `
        --with-graph_parallel `
        --with-headers `
        --with-iostreams `
        --with-json `
        --with-locale `
        --with-log `
        --with-math `
        --with-nowide `
        --with-program_options `
        --with-random `
        --with-regex `
        --with-serialization `
        --with-stacktrace `
        --with-system `
        --with-test `
        --with-thread `
        --with-timer `
        --with-type_erasure `
        --with-wave `
        --prefix="/local/boost_$BOOST_VER" `
        --build-dir="./build" `
        --layout=versioned `
        --build-type=minimal `
        toolset=msvc `
        architecture=x86 `
        address-model=64 `
        variant=release `
        threading=multi `
        link=static `
        install
    
    # For each Python version, build only the Python-specific libraries
    foreach ($PY_DOT_VER in $bp.Value) {
        $PY_VER = $PY_DOT_VER.Split(".") -join ""
        $python = "C:\Python$PY_VER\python.exe"
        
        # Prepare user-config.jam
        $user_config = @"
using python
    : $PY_DOT_VER
    : C:\\Python$PY_VER\\python.exe
    : C:\\Python$PY_VER\\include
    : C:\\Python$PY_VER\\libs
    ;
"@
        $user_config | Set-Content $env:USERPROFILE\user-config.jam
        
        Write-Host "Building Python library for Boost $BOOST_VER with Python: $PY_DOT_VER ($PY_VER) $python"
        Write-Host $user_config

        # Build only Python libraries
        # activate virtual environment
        & $python -m venv "venv"
        & .\venv\scripts\Activate.ps1
        & .\b2 `
            --with-python `
            --prefix="/local/boost_$BOOST_VER" `
            --build-dir="./build_py$PY_VER" `
            --layout=versioned `
            --build-type=minimal `
            toolset=msvc `
            architecture=x86 `
            address-model=64 `
            variant=release `
            threading=multi `
            link=static `
            install
        & deactivate
    }
    Pop-Location
    
    # Clean up after all Python versions are built
    Remove-Item $boost_source -Force -Recurse
}
