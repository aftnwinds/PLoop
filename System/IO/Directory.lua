--===========================================================================--
--                                                                           --
--                            System.IO.Directory                            --
--                                                                           --
--===========================================================================--

--===========================================================================--
-- Author       :   kurapica125@outlook.com                                  --
-- URL          :   http://github.com/kurapica/PLoop                         --
-- Create Date  :   2018/03/29                                               --
-- Update Date  :   2018/03/29                                               --
-- Version      :   1.0.0                                                    --
--===========================================================================--

PLoop(function(_ENV)
    namespace "System.IO"

    __Final__() __Sealed__() __Abstract__()
    class "Directory" (function (_ENV)

        export {
            strfind             = string.find,
            strmatch            = string.match,
            strgmatch           = string.gmatch,
            strsub              = string.sub,
            strgsub             = string.gsub,
            strformat           = string.format,
            select              = select,
            yield               = coroutine.yield,
        }

        if OperationSystem.Current == OperationSystemType.Windows then
            --- Get sub-directories
            __PipeRead__("dir \"%s\"", ".*", OperationSystemType.Windows)
            __Iterator__()
            __Static__()
            function GetDirectories(path, result)
                if result then
                    for line in strgmatch(result, "[^\n]+") do
                        local dir = strmatch(line, "<DIR>%s+(.*)$")
                        if dir and (dir ~= "" and dir ~= "." and dir ~= "..") then
                            yield(dir)
                        end
                    end
                end
            end

            --- Get files
            __PipeRead__("dir \"%s\"", ".*", OperationSystemType.Windows)
            __Iterator__()
            __Static__()
            function GetFiles(path, result)
                if result then
                    for line in strgmatch(result, "[^\n]+") do
                        local file = strmatch(line, "^%d+[%d/%s:,]+(.*)$")
                        if file and not strfind(file, "^<DIR>") then
                            yield(file)
                        end
                    end
                end
            end
        else
            --- Get sub-directories
            __PipeRead__("ls -l \"%s\"", ".*", OperationSystemType.Linux)
            __PipeRead__("export PATH='/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin'\nls -l \"%s\"", ".*", OperationSystemType.MacOS)
            __Iterator__()
            __Static__()
            function GetDirectories(path, result)
                if result then
                    for line in strgmatch(result, "[^\n]+") do
                        if strsub(line, 1, 1) == "d" then
                            local dir = strmatch(line, "^%S+%s+%d+%s+%S+%s+%S+%s+%d+%s+%S+%s+.*%s+([^%d%s]+.*)$")
                            if dir and dir ~= "" then yield(dir) end
                        end
                    end
                end
            end

            --- Get files
            __PipeRead__("ls -l \"%s\"", ".*", OperationSystemType.Linux)
            __PipeRead__("export PATH='/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin'\nls -l \"%s\"", ".*", OperationSystemType.MacOS)
            __Iterator__()
            __Static__()
            function GetFiles(path, result)
                if result then
                    for line in strgmatch(result, "[^\n]+") do
                        if strsub(line, 1, 1) == "-" then
                            local file = strmatch(line, "^%S+%s+%d+%s+%S+%s+%S+%s+%d+%s+%S+%s+.*%s+([^%d%s]+.*)$")
                            if file and file ~= "" then yield(file) end
                        end
                    end
                end
            end
        end

        --- Whether the target directory existed
        __PipeRead__ ("IF EXIST \"%s\" (echo exist) ELSE (echo missing)", "exist", OperationSystemType.Windows)
        __PipeRead__ ("[ -d \"%s\" ] && echo \"exist\" || echo \"missing\"", "exist", OperationSystemType.MacOS + OperationSystemType.Linux)
        __Static__()
        function Exist(dir, result)
            return result == "exist"
        end

        --- Create directory if not existed
        __PipeRead__ (function(dir) return strformat("export PATH='/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin'\n[ ! -d \"%s\" ] && mkdir -p \"%s\"", dir, dir) end, "", OperationSystemType.MacOS + OperationSystemType.Linux)
        __PipeRead__ (function(dir) return strformat("IF NOT EXIST \"%s\" (mkdir \"%s\")", dir, dir) end, "", OperationSystemType.Windows)
        __Static__()
        function Create(dir)
        end
    end)
end)
