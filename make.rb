#!/usr/bin/ruby
require 'base64'
fMask = '[a-zA-Z0-9]+\.\S+'
resFile = 'res.css'
$logEnabled = true
$maxSize = 32000

def log( txt )
    if $logEnabled
        print "\n#{txt}\n"
    end
end

def getCSSFromDir( dir )
    log("Call getCSSFromDir on folder #{dir}")
    res = ""
    Dir.foreach( dir ) { |item| 
        if item.match("[^\.]+")
            item = ( dir + "/" +item ).sub("\/\/", "\/")
            if File.file?( item )
                log "file: #{item}\n"
                res += getCssFromImage( item  )
            elsif File.directory?( item ) && item.match("[^\.]+")
                log "dir: #{item}\n"
                res += getCSSFromDir( item )
            else
                print "smth: #{item}\n"
            end 
        end
    }    
    return res
end

def getBase64Content( file )
    log("Call getBase64Content on file #{file}")

    return Base64.encode64(
        File.open( file ,'r'){ 
            |f| f.read
        }
    )

end

def write2file( file, content )
    prevContent = ""
    if File.exists?(file) 
        prevContent = File.open( file,'r'){|f| f.read}
    end
    File.open( file, 'w+' ){
        |i| i.write(prevContent + content )
    }
end

def getCssFromImage( file )

    res = "data:image/"+ File.extname( file ).tr('.','') + "png;base64," + getBase64Content( file )

    if res.length < $maxSize
        log("Call getCssFromImage on file #{file}")
        return "\n.b-" + file.tr('/','_').sub( File.extname( file ), "" ) + "{ background-image: url(" + res + ");}"
    elsif
        log("Max DataURI length was exceeded on file #{file}")
    end
end

res = ""
ARGV.each do|a|
    if a.match("[^\.]+")
        if File.directory?( a )
            res += getCSSFromDir( a )
        elsif File.file?( a ) 
            res += getCssFromImage( a )
        end
    end
end

if File.exists?( resFile )
    File.delete( resFile )
end

if( res )
    write2file( resFile , res.strip )
    log "Result was written to #{resFile}\n"
end

