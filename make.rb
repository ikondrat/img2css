#!/usr/bin/ruby
require 'base64'
$logEnabled = false
$oldieSupported = true
$resDir=""
$resName="icons-base64"
$cssName=".b-ico-"
$maxSize = 32000
$sourceDir = false
# generate combo file (png and svg)
$useComboData = false
def log( txt )
    if $logEnabled
        print "\n#{txt}\n"
    end
end

def getCSSFromDir( dir )
    data = {}
    # mind the start dir
    Dir.chdir( dir ) do
        log("Parsing dir: [ #{dir} ]")
        result = ""
        Dir["*.{png,gif,svg}"].sort.each { | f |

            d = getDataByImage( f )

            if d
                item = data[ d["name"] ]
                if item
                    d.each {|key, value|
                        item[key] = value
                    }
                else
                    data[ d["name"] ] = d
                end
            end
        }
    end 
    puts Dir.pwd
    return data
end

def getBase64Content( file )
    log("Get content of: [ #{file} ]")

    return Base64.encode64(File.open(file ,'r'){ |f| f.read }).gsub(/\n/,'') 
end

def write2file( file, content )
    File.open( file, 'w+' ){|i| i.write(content)}
end

def getDataByImage( file )

    # get extension
    ext = File.extname( file )

    # get basename of file
    baseName = File.basename( file, ext)

    # gettype of file
    type = ext.slice(1, ext.length - 1)
    isSVG = type == "svg"

    data = {
        "name" => baseName,
        "type" => ext.slice(1, ext.length - 1)
    };

    if !isSVG 
        data["bin-type"] = data["type"]
    end

    data[ isSVG ? "vector" : "binary" ] = getBase64Content( file )

    return data

end

def getContent(key, data, type, degradationType)

    cssClass = "#{$cssName}#{key}"

    dataURL = data ? "data:image/#{type};base64,#{data}": ""

    if (dataURL.length > 1 )
        if dataURL.length < $maxSize
            baseStyle = "#{cssClass} {background-image:url(#{dataURL});}"

            if degradationType

                path = "../../#{$sourceDir}/#{key}.#{degradationType}"
                degradationStyle = "\n.no-data-url #{cssClass} {background-image: url(#{path});}"
                if $oldieSupported
                    degradationStyleIE = "\n* html #{cssClass} {background: none !important;-filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='#{path}');}"
                end

            end
            
            return "#{baseStyle}#{degradationStyle}#{degradationStyleIE}\n\n"
        else
            raise "Max DataURI length was exceeded on file #{key}.#{type}"
        end
    end

end

def main()
   
    if !$sourceDir
        raise "Please define location of icons by parameter --source-dir="   
    end 

    res = getCSSFromDir( $sourceDir )

    if( res )
        resBinary = ""
        resVector = ""
        resCombo= ""

        res.each {|key, value| 

            _resB = getContent(key, value['binary'], value['type'], value['type'])
            _resV = value['vector'] ? getContent(
                key, 
                value['vector'], 
                "svg+xml", 
                _resB ? value['bin-type'] : nil
            ) : ""

            if value['binary'] 
                resBinary += _resB
            else
                puts "WARNING!!!! Where is no degradation image file for #{key}.#{value['type']}"
            end

            resVector += _resV

            if $useComboData
                resCombo += value['vector'] ? _resV : _resB
            end
            
        }

        if $useComboData || resVector.length > 1
            cssFileVector = "#{$resDir}#{$resName}.css"
            vectorData = resCombo.length > 1 ? resCombo : resVector
            write2file( cssFileVector, vectorData );
            log "Result was written to #{cssFileVector}\n"
        end

        if !$useComboData && resBinary.length > 1
            cssFileBinary = "#{$resDir}#{$resName}.b.css"
            write2file( cssFileBinary, resBinary );
            log "Result was written to #{cssFileBinary}\n"
        end

    end

end

$helpMod = false
ARGV.each do|a|
    case a

    when "--except-oldie"
      $oldieSupported = false

    when "--verbose"
      $logEnabled = true

    when "--make-combo"
      $useComboData = true

    when "--help"
        $helpMod = true
        space = "\t\t"
        puts "Ruby script to generate css files with dataURLed images from directory"
        puts "Usage options: --source-dir=path [OPTIONS..]"
        puts "\nOPTIONS:"
        puts "--make-combo #{space} Append dataURL from png to css with svg images if required svg file doesn't exist"
        puts "--verbose #{space} Show detailed output"
        puts "--except-oldie #{space} Don't append '-filter' degradation styles for old IE"
        puts "--result-dir #{space} Folder where generated files will be stored"
        puts "--result-name #{space} Base name for generated files"
        puts "--css-name #{space} Base name for generated css rule"
        puts "--help #{space}\t HELP"
        break
    end

    sourceDir = a.match(/--source-dir=(\S+)\/?$/)
    if sourceDir 
        if !File.directory?( sourceDir[1] )
            raise "Directory [ #{sourceDir[1]} ] doesn't exist" 
        else
            $sourceDir = sourceDir[1]
        end
    end

    resDir = a.match(/--result-dir=(\S+)$/)
    if resDir 
        if !File.directory?( resDir[1] )
            raise "Directory [ #{resDir[1]} ] doesn't exist" 
        else
            $resDir = resDir[1]
        end 
        
    end

    cssName = a.match(/--css-name=(\S+)$/)
    if cssName 
        $cssName = cssName[1]
    end

    resName = a.match(/--result-name=(\S+)$/)
    if resName 
        $resName = resName[1]
    end
end

if !$helpMod
    main()
end
