#
# Put this script to C:\build
#
$python_boost = @{
    "3.9" = "1_76_0";
    "3.10" = "1_80_0";
    "3.11" = "1_82_0";
    "3.12" = "1_85_0";
}

Write-Host "Current dir: $(pwd)"

foreach ($pb in $python_boost.getEnumerator() | Sort-Object) {
    $BOOST_VER = $pb.Value
    Write-Host "Boost: $BOOST_VER"
    
    # Prepare python versions
    $PY_DOT_VER = $pb.Name
    $PY_VER = $PY_DOT_VER.Split(".") -join "" 
    
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
    Write-Host $user_config

    $python = "C:\Python$PY_VER\python.exe"
    Write-Host "Python: $PY_DOT_VER ($PY_VER) $python"

    # build boost
    $boost_source = "/boost_$BOOST_VER"
    Push-Location $boost_source
    # activate virtual environment
    & $python -m venv "venv"
    & .\venv\scripts\Activate.ps1
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
        # --with-mpi `
        --with-nowide `
        --with-program_options `
        --with-python `
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
            runtime-link=static `
            install
    & deactivate
    Pop-Location
    Remove-Item $boost_source
}
