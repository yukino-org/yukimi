<p align="center">
    <img src="https://github.com/yukino-org/media/blob/main/images/subbanners/gh-yukimi-banner.png?raw=true">
</p>

# Yukimi

☄ Anime/Manga command-line interface backed up by Tenka.

By using this project, you agree to the [usage policy](https://yukino-org.github.io/wiki/tenka/disclaimer/).

[![Version](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/yukino-org/yukimi/dist-data/badge-endpoint.json)](https://github.com/yukino-org/yukimi/)
[![Platforms](https://img.shields.io/static/v1?label=platforms&message=windows%20|%20linux%20|%20macos&color=lightgrey)](https://github.com/yukino-org/yukimi/)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Code Analysis](https://github.com/yukino-org/yukimi/actions/workflows/code-analysis.yml/badge.svg)](https://github.com/yukino-org/yukimi/actions/workflows/code-analysis.yml)
[![Build (Artifacts)](https://github.com/yukino-org/yukimi/actions/workflows/build-artifacts.yml/badge.svg)](https://github.com/yukino-org/yukimi/actions/workflows/build-artifacts.yml)
[![Release](https://github.com/yukino-org/yukimi/actions/workflows/release.yml/badge.svg)](https://github.com/yukino-org/yukimi/actions/workflows/release.yml)

## Installation

Pre-built binaries are released in `dist-*` branches. To use these, you need to have [git](https://git-scm.com/) installed.

### Clone this repository

For Windows:

```bash
git clone https://github.com/yukino-org/yukimi.git -b dist-windows
```

For Linux:

```bash
git clone https://github.com/yukino-org/yukimi.git -b dist-linux
```

For MacOS:

```bash
git clone https://github.com/yukino-org/yukimi.git -b dist-macos
```

### Usage

You can use `<path/to/executable> -t` to open a nested terminal. It is recommended to use commands within it for better performance.

-   Do:

```bash
yukimi -t
> help
> tenka installed
```

-   Don't:

```bash
yukimi help
yukimi tenka installed
```

## Technology

-   [Dart](https://dart.dev/) (Language)
-   [Pub](https://pub.dev/) (Dependency Manager)
-   [Git](https://git-scm.com/) (Version Manager)

## Code structure

-   [./cli](./cli) - Contains the local command-line tool.
-   [./src](./src) - Contains the source code of the server.

## Contributing

Ways to contribute to this project:

-   Submitting bugs and feature requests at [issues](https://github.com/yukino-org/yukimi/issues).
-   Opening [pull requests](https://github.com/yukino-org/yukimi/pulls) containing bug fixes, new features, etc.

## License

[![AGPL-3.0](https://github.com/yukino-org/media/blob/main/images/license-logo/agplv3.png?raw=true)](./LICENSE)
