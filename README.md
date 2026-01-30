# homebrew-esbmc

A [Homebrew](https://brew.sh) tap to install [ESBMC](https://esbmc.org) (the Efficient SMT-based Context-Bounded Model Checker) on macOS.

**Simplest setup:** Rename this repo to **`homebrew-esbmc`** on GitHub (Settings → General → Repository name). Then Homebrew’s default tap URL works and users only need:

## Installation

### Stable Version (ESBMC 8.0 published)

```bash
brew tap LukeW1999/homebrew-esbmc
brew install esbmc
```

### Development Version (Master Branch)

To install the latest code from the master branch:

```bash
brew tap LukeW1999/homebrew-esbmc
brew install --HEAD esbmc
```

### Upgrade

For stable version:
```bash
brew upgrade esbmc
```

For development version (master branch):
```bash
brew upgrade --HEAD esbmc
```

## Usage

```bash
# Verify a C file
esbmc program.c

# Verify a Python file
esbmc program.py

esbmc --help
```

## License and Copyright

**This tap** is not affiliated with the official ESBMC project.

**ESBMC** is by the [ESBMC project](https://github.com/esbmc/esbmc): Apache-2.0 for ESBMC code; CBMC (BSD 4-clause). Copyright holders: Lucas Cordeiro, Jeremy Morse, Bernd Fischer, Mikhail Ramalho. See [ESBMC COPYING](https://github.com/esbmc/esbmc/blob/master/COPYING). This formula uses Z3 (MIT); check solver licenses for distribution/commercial use.
