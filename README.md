# From image to plain css converter
Converts svg/png files to inline dataURLs
with naming style as b-ico-%filename%

It creates css file with images represented as dataURL with to options:
 1. "make-combo mode" includes either svg and binary images(png/gif) in one file
 2. "default mode" converts images into two files one with svg images only and another with binary images only.

## Repo
https://github.com/ikondrat/img2css

## Usage
```shell
ruby make.rb --source-dir=path [OPTIONS..]

OPTIONS:
--make-combo             Append dataURL from png to css with svg images if required svg file doesn't exist
--verbose                Show detailed output
--except-oldie           Don't append '-filter' degradation styles for old IE
--result-dir             Folder where generated files will be stored
--result-name            Base name for generated files
--css-name               Base name for generated css rule
--help                   HELP
```
