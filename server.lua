--[[ Web Server module 
--
-- really simple web server 
-- ability to use lua scripts as cgi backend
-- © 2019 tecdroid, c-base
--
  ]]-- 


-- globals for use inside the scripts
_GET = {}
_MIMETYPE = "text/text"
_RESPONSE = "200 OK"

--[[sending file ]]--
local function read_file (filename)
    local buf = '';
    f = file.open(filename, 'r');
    buf = f:read(4096);
    f:close();
    f = nil;
    
    return buf;
end

--[[get end of filename (.lua) ]]--
local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

--[[ set global mime type for sending data ]]--
local function set_mimetype(path) 
    -- mime type
    local mimetypes = {["html"] = "text/html", ["lua"] = "text/html", ["css"] = "text/css", ["png"] = "image/png", ["jpg"] = "image/jpg"};

    -- set file content type, can be changed by lua script
    local  mime = path:match "[^.]+$";
    local m = mimetypes[mime:lower()];
    if (m ~= nil) then
        _MIMETYPE = m;
    end     
    print('mime ' .. _MIMETYPE );

end

local function create_response(buf) 
   -- standard response header  
    local response = "HTTP/1.1 <retval>\nServer: NodeSrv\nContent-Type: <contenttype>\nContent-Length: <len>\nConnection: Closed\n\n";

    -- fill content meta data
    response = response:gsub('<retval>', _RESPONSE);
    response = response:gsub('<contenttype>', _MIMETYPE);
    response = response:gsub('<len>', #buf);

    print(response);

    return response .. buf;

end

--[[http receivve function ]]--
local function receive(client, request)
--    print (" receiving " .. request)
    
    local response = "";
    local buf = "";
    -- parse http request
    local _, _, method, path, vars = string.find(request, "([A-Z]+) /(.+)?(.+) HTTP");
    if(method == nil)then
        _, _, method, path = string.find(request, "([A-Z]+) /(.+) HTTP");
    end
    
    -- make get params array
    if (vars ~= nil)then
        for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
            _GET[k] = v
        end
    end

    -- make index html standard
    if (path == nil ) then 
        path = 'index.html';
    end
    print ("path ordered : "..path);
    
    -- if file not found, response 404
    if( false == file.exists(path) ) then
        _RESPONSE = "404 Not Found";
        path = '404.html';
        print("file not found");
    end

    -- set file mime
    set_mimetype(path);
        
    -- call lua script or read file
    if(ends_with(path, 'lua') ) then
        buf = dofile(path);
    else 
        buf = read_file(path);
    end

    
    -- and send
    client:send(create_response(buf));

    -- close socket after sending
    client:on("sent", function(sock) 
        sock:close()
    end)
    collectgarbage();
end

--[[ finally create the server ]]--
print("creating server..");
print( wifi.sta.getip());

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", receive);
end)

collectgarbage();