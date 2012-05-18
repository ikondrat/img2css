#!/usr/bin/ruby
require 'base64'

def getImagesFromDir( dir )

    Dir.foreach( dir ) { |x| 
        if File.extname(x).match('\.png')
            puts "hello"
            File.open( x ,'r'){|f| f.read}
            #puts File.absolute_path( "#{x}" )
            #b=Base64.encode64(File.open("#{x}",'r'){|f| f.read})
            #puts File.extname(x)
        end 
    }    

end

def getBase64Content( file )

    return Base64.encode64(
        File.open( file ,'r'){ 
            |f| f.read
        }
    )

end

def getCssFromImage( file )
    #File.open( x ,'r'){|f| f.read}
    if File.basename( file ).match('[a-zA-Z]+\.\S+') 
        case File.extname( file )
            when ".png"
                res =  "data:image/png;base64," + getBase64Content( file )
            when ".gif"
                res =  "data:image/gif;base64," + getBase64Content( file )
            when ".jpg"
                res =  "data:image/jpeg;base64," + getBase64Content( file )
        end


        return " .b-" + File.basename( file ).sub( File.extname( file ), "" ) + "{ background-image: url(" + res + ");}'"
    end 

    #puts File.extname( file )
    #b=Base64.encode64(File.open("#{ARGV[0]}",'r'){|f| f.read})
    #return b
end

ARGV.each do|a|
    if File.directory?( a )
        puts a + " Is directory, try to proceed images from here..."
        getImagesFromDir( a )
    elsif File.file?( a ) &&  File.readable?( a )
        res = getCssFromImage( a )
        if( res )
            puts res
        end
        #puts a + " Is file"
    end
end

