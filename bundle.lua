local function bundle(Nn, Sn, Hn)
    a(1, Nn, "string")
    a(2, Sn, "number")
    a(3, Hn, "boolean")
    if type(Nn) == "string" and type(Sn) == "number" and type(Hn) == "boolean" then
        if Hn == true then
            rs.setBundledOutput(Nn, colors.combine(rs.getBundledOutput(Nn), Sn))
        elseif Hn == false then
            rs.setBundledOutput(Nn, colors.subtract(rs.getBundledOutput(Nn), Sn))
        end
    else
        error("please use like this:\nbundle(side:string,colors.(color),state:boolean)")
    end
end
return {bundle=bundle}
