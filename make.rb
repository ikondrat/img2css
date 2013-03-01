#!/usr/bin/ruby
require 'base64'
$logEnabled = false
$maxSize = 32000

def log( txt )
    if $logEnabled
        print "\n#{txt}\n"
    end
end

def getCSSFromDir( dir )
    # mind the start dir
#    puts Dir.pwd
    Dir.chdir( dir ) do
        log("Parsing dir: [ #{dir} ]")
        result = ""
        Dir["*.png"].sort.each { | f |
            baseName = File.basename( f, File.extname( f ) )

            type = File.file?( "#{baseName}.svg" ) ? "svg" : "png";

            result += getCssFromImage( f, type )
        }
        return result
    end 
    puts Dir.pwd
end

def getBase64Content( file )
    log("Get content of: [ #{file} ]")

    return Base64.encode64(File.open(file ,'r'){ |f| f.read }).gsub(/\n/,'') 
end

def write2file( file, content )
    prevContent = ""
    if File.exists?(file) 
        prevContent = File.open( file,'r'){|f| f.read}
    end
    File.open( file, 'w+' ){|i| i.write(prevContent + content)}
end

def getCssFromImage( file, type )
    isSVG = type === "svg"
    bName = File.basename( file, File.extname( file ))
    base64line = getBase64Content( isSVG ? "#{bName}.svg" : file )
    resType = isSVG ? "svg+xml" : type

    res = "data:image/#{resType};base64,#{base64line}"

    if res.length < $maxSize
        c = ".b-ico-#{bName}"
        fPath = "../../static/i/icons/#{file}"
        baseStyle = "#{c} {background-image:url(#{res});}"
        degradationStyle = ".no-data-url #{c} {background-image: url(#{fPath});}"
        degradationStyleIE = "* html #{c} {background: none !important;-filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='#{fPath}');}"
        return "\n\n#{baseStyle}\n#{degradationStyle}\n#{degradationStyleIE}"
    else
        raise "Max DataURI length was exceeded on file #{file}"
    end

end

def main(path, cssFile)
   
    if !File.directory?( path )
        raise "Directory [ #{path} ] doesn't exist"   
    end 

    if File.exists?( cssFile )
        File.delete( cssFile )
    end

    res = getCSSFromDir( path )

    if( res )
        write2file( cssFile, res )
        log "Result was written to #{cssFile}\n"
    end

end

main(ARGV[0], ARGV[1]);
