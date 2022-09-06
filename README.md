<!--suppress HtmlDeprecatedAttribute -->
<h1 align="center">SVG-to-(Windows)-Ico</h1>

<p align="center">
  <a href="https://opensource.org/licenses/MIT" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-9C0000.svg?labelColor=ebdbb2&style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxNCIgaGVpZ2h0PSIxNCI+PHBhdGggdmVjdG9yLWVmZmVjdD0ibm9uLXNjYWxpbmctc3Ryb2tlIiBkPSJNMCAyLjk5NWgxLjI4djguMDFIMHpNMi41NCAzaDEuMjh2NS4zNEgyLjU0em0yLjU1LS4wMDVoMS4yOHY4LjAxSDUuMDl6bTIuNTQuMDA3aDEuMjh2MS4zMzZINy42M3oiIGZpbGw9IiM5YzAwMDAiLz48cGF0aCB2ZWN0b3ItZWZmZWN0PSJub24tc2NhbGluZy1zdHJva2UiIGQ9Ik03LjYzIDUuNjZoMS4yOFYxMUg3LjYzeiIgZmlsbD0iIzdjN2Q3ZSIvPjxwYXRoIHZlY3Rvci1lZmZlY3Q9Im5vbi1zY2FsaW5nLXN0cm9rZSIgZD0iTTEwLjE3NyAzLjAwMmgzLjgyNnYxLjMzNmgtMy44MjZ6bS4wMDMgMi42NThoMS4yOFYxMWgtMS4yOHoiIGZpbGw9IiM5YzAwMDAiLz48L3N2Zz4=" />
  </a>
  <a href="https://twitter.com/WalterWoshid" target="_blank">
    <img alt="Twitter: WalterWoshid" src="https://img.shields.io/twitter/follow/WalterWoshid.svg?style=flat&logo=twitter&color=458588&logoColor=458588&labelColor=ebdbb2&label=@WalterWoshid" />
  </a>
</p>

<p>
  SVG-to-(Windows)-ICO is a simple script to convert SVG images to ICO files which can be used as icons on Windows
</p>



## Installation

- Download the `svg-to-ico.sh` script file.
- Run it with `./svg-to-ico.sh` and see the help section for more information


# Usage

`svg-to-ico.sh [options] input [output]`

### Convert single image

`. svg-to-ico.sh icon.svg`

### Convert single image with custom output name

`. svg-to-ico.sh icon.svg my-icon.ico`

### Convert directory with images

`. svg-to-ico.sh icons`

### Convert directory with custom output name

`. svg-to-ico.sh icons my-icons`

### Convert image with 20 pixels padding

`. svg-to-ico.sh icon.svg -p 20`

### Convert directory with 20 tasks in parallel

`. svg-to-ico.sh icons -t 20`

### Convert directory by running all tasks in parallel

`. svg-to-ico.sh icons -t 0`


## Testing

- Run `./tests/run-tests.sh` to run all tests



## Show your support

Give a ⭐️ if this project helped you!



## 📝 License

Copyright © 2022 [Valentin Wotschel](https://github.com/WalterWoshid).<br />
This project is [MIT](https://opensource.org/licenses/MIT) licensed.
