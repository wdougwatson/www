require 'webrick'
require 'fileutils'

if ARGV.length != 0
   root = ARGV.first.gsub('\\', '/')
else
   root = '.'
end
BACKUP_DIR = 'bak'

module WEBrick
   module HTTPServlet

      class FileHandler
         alias do_PUT do_GET
      end

      class DefaultFileHandler
         def do_PUT(req, res)
            file = "#{@config[:DocumentRoot]}#{req.path}"
            res.body = ''
            unless Dir.exists? BACKUP_DIR
               Dir.mkdir BACKUP_DIR
            end
            FileUtils.cp(file, "#{BACKUP_DIR}/#{File.basename(file, '.html')}.#{Time.now.to_i.to_s}.html")
            File.open(file, "w+") {|f| f.puts(req.body)}
         end

         def do_OPTIONS(req, res)
            res['allow'] = "GET,HEAD,POST,OPTIONS,CONNECT,PUT,DAV,dav"
            res['x-api-access-type'] = 'file'
            res['dav'] = 'tw5/put'
         end

      end
   end
end

server = WEBrick::HTTPServer.new({:Port => 8000, :DocumentRoot => root})

trap "INT" do
   puts "Shutting down..."
   server.shutdown
end

server.start
