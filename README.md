[![Docker Image CI](https://github.com/ababak/boost/actions/workflows/docker-image.yml/badge.svg)](https://github.com/ababak/boost/actions/workflows/docker-image.yml)


# boost
ltsc2022-based Docker image with Python and Boost

### Features
An up-to-date environment for building against popular DCC applications. The Python/Boost versions are matched as described at https://vfxplatform.com

- Python 3.9, Boost 1.76.0 on Windows (Maya 2023, Houdini 19.5, Nuke 14.0)
- Python 3.10, Boost 1.80.0 on Windows (Maya 2024, Houdini 20.0, Nuke 15.0)
- Python 3.11, Boost 1.82.0 on Windows (Maya 2025, Houdini 20.5, Nuke 16.0)
- Python 3.11, Boost 1.85.0 on Windows (Maya 2026, Houdini 21.0)
- Python 3.12, Boost 1.85.0 on Windows (future releases)
- Python 3.13, Boost 1.88.0 on Windows (future releases)


### Build

    docker build --rm -t ababak/boost .

### Pull

    docker pull ababak/boost
