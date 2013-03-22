# From image to plain css converter
Converts svg/png files to css files with dataURLs
with naming style as b-ico-%filename%

## Repo
https://github.com/ikondrat/img2css

## Usage
ruby make.rb --source-dir=path [OPTIONS..]

OPTIONS:
--make-combo             Append dataURL from png to css with svg images if required svg file doesn't exist
--verbose                Show detailed output
--except-oldie           Don't append '-filter' degradation styles for old IE
--result-dir             Folder where generated files will be stored
--result-name            Base name for generated files
--css-name               Base name for generated css rule
--help                   HELP
