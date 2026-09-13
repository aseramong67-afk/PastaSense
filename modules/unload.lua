-- unload.lua — выгрузка скрипта
-- Просто вызови Unload() для полной очистки
local Unload = {}

function Unload.Register(fn)
    pcall(function() getgenv().PastaUnload = fn end)
end

function Unload.Run()
    pcall(function()
        if getgenv().PastaUnload then
            getgenv().PastaUnload()
        end
    end)
end

return Unload
