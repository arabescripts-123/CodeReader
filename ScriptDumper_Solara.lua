for _,v in pairs(getgc(true)) do
    if typeof(v) == "function" then
        local info = debug.getinfo(v)
        if info.name and info.name:lower():find("kick") then
            print("FUNÇÃO SUSPEITA:", info.name)
        end
    end
end
