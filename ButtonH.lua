--------------------ButtonH----------------------------
----------------------MENU/PANEL API-------------------
--------------------by 9551 DEV------------------------
---Copyright (c) 2021-2022 9551------------9551#0001---
---using this code in your project is fine!------------
---as long as you dont claim you made it---------------
---im cool with it, feel free to include---------------
---in your projects!   discord: 9551#0001--------------
---you dont have to but giving credits is nice :)------
-------------------------------------------------------
-------------------------------------------------------
--   pastebin get LTDZZZEJ button
 
--*functions usages
--*API(ins, cord1, cord2, length, height)
--*timetouch(timeout,monitor [,ignore])
--*button(monitor, ins, cord1, cord2, text)
--*counter(monitor, ins, cc, cord1, cord2, cv, max, min, col)
--*fill(monitor, pos1, pos2, length, height)
--*switch(monitor, cc, ins, pos1, pos2, col1, col2, col3, text)
--*switchn(monitor, cc, ins, pos1, pos2, col1, col2, col3, text, text2)
--*bundle(side, color, state)
--*signal(side, ins, col)
--*sliderVer/Hor(monitor, ins, cc, pos1, pos2, length, color1, textCol)
--*menu(monitor, ins, cc, x, y, textcol, switchcol, text, returns1, more, returns2)  (returns menuout)
--*bar(monitor, pos1, pos2, length, height, ins, max, color1, color2, color3, printval, hor, text, format, rect, thicc)
--*render(monitor,text,x,y,textcol,backCol)
--*menudata()
--*frame(monitor, pos1, pos2, length, height, color3, color1, thicc)
--*boxAPI(ins,x,y,xp,yp,text)
--*boxButton(mon,ins,x,y,bcol,tcol,txt,xp,yp)
--*db allows you to get stored data from all functions that use stored data!
--*how to use db:  in your function for example switch you do   b.switch("db",<data>) data is the storing position you want to get data of. you can also use "setdb" to set data b.switch("setdb",buttonID,value)
--*if you are using terminal version instead of mon put in 1-3 to select left or right click (3 for mouse wheel middle)
--*put values at end of switch function (x,y) to add padding for your switches
local e = {}
local t = {}
local a = require("cc.expect").expect
function e.fill(o, i, n, s, h)
    a(1, o, "string")
    a(2, i, "number")
    a(3, n, "number")
    a(4, s, "number")
    a(5, h, "number")
    local r = peripheral.wrap(o)
    for d = 0, h - 1 do
        r.setCursorPos(i, n + d)
        r.write(string.rep(" ", s))
    end
end
function e.API(l, u, c, f, w)
    a(1, l, "table")
    a(2, u, "number")
    a(3, c, "number")
    a(4, f, "number")
    a(5, w, "number")
    if l == true then
        l = {os.pullEvent("monitor_touch")}
    end
    if l[3] >= u and l[3] <= u + f - 1 then
        return l[4] >= c and l[4] <= c + w - 1
    end
end
function e.boxAPI(y, p, v, b, g, k)
    a(1, y, "table")
    a(2, p, "number")
    a(3, v, "number")
    a(4, b, "number")
    a(5, g, "number")
    a(6, k, "string")
    local q = p - b + 1
    local j = v - g
    local x = #k - 2
    local z = false
    if b >= 1 then
        b = b - 1
        z = true
    end
    if b > 0 or z then
        x = #k + b * 2
        q = q - 1
    end
    local E = g * 2 + 1
    return e.API(y, q - 1, j, x + 2, E), {q, j, x, E}
end
function e.boxButton(T, A, O, I, N, S, H, R, D)
    a(1, T, "string")
    a(2, A, "table")
    a(3, O, "number")
    a(4, I, "number")
    a(5, N, "string")
    a(6, S, "string")
    a(7, H, "string", "number", "nil")
    a(8, R, "number", "nil")
    a(9, D, "number", "nil")
    if not R then
        R = 0
    end
    if not D then
        D = 0
    end
    if not H then
        H = ""
    end
    local H = tostring(H)
    if A[2] == T then
        if A ~= nil then
            local L = peripheral.wrap(T)
            local U, C = L.getTextColor(), L.getBackgroundColor()
            L.setBackgroundColor(colors[N])
            L.setTextColor(colors[S])
            local M, F = e.boxAPI(A, O, I, R or 1, D or 1, H)
            e.fill(T, F[1] - 1, F[2], F[3] + 2, F[4])
            local W, Y, P, V = F[1], F[2], F[3] + F[1], F[4] + F[2]
            L.setCursorPos(math.floor(W + (P - W) / 2 - H:len() / 2 + 0.5), math.floor(Y + (V - Y) / 2))
            L.write(H)
            L.setBackgroundColor(C)
            L.setTextColor(U)
            return M
        end
    end
end
function e.touch()
    local B = {os.pullEvent("monitor_touch")}
    return B
end
function e.timetouch(G, K)
    a(1, G, "number", "nil")
    a(2, K, "string")
	local Q
	if G then
    	Q = os.startTimer(G)
	end
    while true do
		local J
        if G then J = {os.pullEvent()} end
		if not G then J = {os.pullEvent("monitor_touch")} end
        if J[1] == "timer" and J[2] == Q then
            return {"timeout", K, 1000, 1000}
        elseif J[1] == "monitor_touch" and J[2] == K then
            return {J[1], J[2], J[3], J[4]}
        end
    end
end
function e.button(X, Z, et, tt, at)
    a(1, X, "string")
    a(2, Z, "table")
    a(3, et, "number")
    a(4, tt, "number")
    a(5, at, "string")
    if Z[2] == X then
        if Z ~= nil then
            local ot = peripheral.wrap(X)
            local it = e.API(Z, et, tt, #at, 1)
            ot.setCursorPos(et, tt)
            ot.write(at)
            return it
        end
    end
end
function e.counter(nt, st, ht, rt, dt, lt, ut, ct, mt)
    if nt == "db" then
        if data == nil then
            return nil
        else
            return data[st]
        end
    end
    if nt == "setdb" then
        if data == nil then
            return "no data to edit"
        else
            data[st] = ht
            return "value changed too " .. type(ht)
        end
    end
    a(1, nt, "string")
    a(2, st, "table")
    a(3, ht, "number")
    a(4, rt, "number")
    a(5, dt, "number")
    a(6, lt, "number")
    a(7, ut, "number")
    a(8, ct, "number")
    a(9, mt, "string")
    if st[2] == nt then
        if st ~= nil then
            local ft = peripheral.wrap(nt)
            if data == nil then
                data = {}
                for wt = 0, 1000 do
                    data[wt] = 0
                end
            end
            ft.setCursorPos(rt, dt)
            ft.write("\24" .. " " .. data[ht])
            ft.setCursorPos(rt, dt + 1)
            ft.write("\25")
            if e.API(st, rt, dt, 1, 1) == true then
                if data[ht] < ut then
                    data[ht] = data[ht] + lt
                    ft.setCursorPos(rt, dt)
                    ft.setTextColor(colors.green)
                    ft.write("\24" .. " " .. data[ht] .. " ")
                    ft.setCursorPos(rt, dt + 1)
                    ft.setTextColor(colors.red)
                    ft.write("\25")
                    ft.setTextColor(colors[mt])
                    return data[ht]
                end
            end
        end
        if e.API(st, rt, dt + 1, 1, 1) == true then
            if data[ht] > ct then
                data[ht] = data[ht] - lt
                m.setCursorPos(rt, dt)
                m.setTextColor(colors.green)
                m.write("\24" .. " " .. data[ht] .. " ")
                m.setCursorPos(rt, dt + 1)
                m.setTextColor(colors.red)
                m.write("\25")
                m.setTextColor(colors[mt])
                return data[ht]
            end
        end
    end
end
function e.switch(yt, pt, vt, bt, gt, kt, qt, jt, xt, zt, Et)
    if yt == "db" then
        if data1 == nil then
            return nil
        else
            return data1[pt]
        end
    end
    if yt == "setdb" then
        if data1 == nil then
            return "no data to edit"
        else
            data1[pt] = vt
            return "value changed too " .. type(vt)
        end
    end
    a(1, yt, "string")
    a(2, pt, "number")
    a(3, vt, "table")
    a(4, bt, "number")
    a(5, gt, "number")
    a(6, kt, "string")
    a(7, qt, "string")
    a(8, jt, "string")
    a(9, xt, "string")
    a(10, zt, "number", "nil")
    a(11, Et, "number", "nil")
    if vt[2] == yt then
        if vt ~= nil then
            local _ = #xt
            peripheral.wrap(yt)
            if data1 == nil then
                data1 = {}
                for Ot = 0, 1000 do
                    data1[Ot] = false
                end
            end
            local function It()
                data1[pt] = not data1[pt]
            end
            local Nt
            if not data1[pt] then
                Nt = kt
            else
                Nt = qt
            end
            if e.boxButton(yt, vt, bt, gt, Nt, jt, xt, zt, Et) then
                It()
            end
            return data1[pt]
        end
    end
end
function e.switchn(St, Ht, Rt, Dt, Lt, Ut, Ct, Mt, Ft, Wt, Yt, Pt)
    if St == "db" then
        if data2 == nil then
            return nil
        else
            return data2[Ht]
        end
    end
    if St == "setdb" then
        if data2 == nil then
            return "no data to edit"
        else
            data2[Ht] = Rt
            return "value changed too " .. type(Rt)
        end
    end
    a(1, St, "string")
    a(2, Ht, "number")
    a(3, Rt, "table")
    a(4, Dt, "number")
    a(5, Lt, "number")
    a(6, Ut, "string")
    a(7, Ct, "string")
    a(8, Mt, "string")
    a(9, Ft, "string")
    a(10, Wt, "string")
    a(11, Yt, "number", "nil")
    a(12, Pt, "number", "nil")
    if Rt[2] == St then
        if Rt ~= nil then
            peripheral.wrap(St)
            if data2 == nil then
                data2 = {}
                for Bt = 0, 1000 do
                    data2[Bt] = false
                end
            end
            local function Gt()
                data2[Ht] = not data2[Ht]
            end
            local Kt
            local Qt
            if not data2[Ht] then
                Kt = Ut
                Qt = Ft
            else
                Kt = Ct
                Qt = Wt
            end
            if e.boxButton(St, Rt, Dt, Lt, Kt, Mt, Qt, Yt, Pt) then
                Gt()
            end
            return data2[Ht]
        end
    end
end
function e.bundle(Jt, Xt, Zt)
    a(1, Jt, "string")
    a(2, Xt, "number")
    a(3, Zt, "boolean")
    if Zt == true then
        rs.setBundledOutput(Jt, colors.combine(rs.getBundledOutput(Jt), Xt))
    elseif Zt == false then
        rs.setBundledOutput(Jt, colors.subtract(rs.getBundledOutput(Jt), Xt))
    end
end
function e.signal(ea, ta, aa, oa)
    a(1, ea, "string")
    a(2, ta, "boolean", "string")
    a(3, aa, "number","string")
    a(4, oa, "boolean")
    if ta == "clear" then
        rs.setBundledOutput(ea, 0)
    else
        if oa == true then
            if ta == "on" then
                ta = true
            end
            if ta == "nil" then
                ta = false
            end
        end
        if ta ~= nil then
            if type(aa) == "number" then
                if ta == true then
                    e.bundle(ea, aa, true)
                elseif ta == false then
                    e.bundle(ea, aa, false)
                end
            elseif type(aa) == "string" then
                if ta == true then
                    e.bundle(ea, colors[aa], true)
                elseif ta == false then
                    e.bundle(ea, colors[aa], false)
                end
            end
        end
    end
end
function e.sliderHor(ia, na, sa, ha, ra, da, la, ua)
    if ia == "db" then
        if data3 == nil then
            return nil
        else
            return data3[na]
        end
    end
    if ia == "setdb" then
        if data3 == nil then
            return "no data to edit"
        else
            data3[na] = sa
            return "value changed too " .. type(sa)
        end
    end
    a(1, ia, "string")
    a(2, na, "table")
    a(3, sa, "number")
    a(4, ha, "number")
    a(5, ra, "number")
    a(6, da, "number")
    a(7, la, "string")
    a(8, ua, "string")
    if na[2] == ia then
        if na ~= nil then
            m = peripheral.wrap(ia)
            local ca = m.getBackgroundColor()
            local ma = m.getTextColor()
            m.setBackgroundColor(colors[la])
            m.setTextColor(colors[ua])
            m.setCursorPos(ha, ra)
            for fa = 0, da do
                m.write("-")
                m.setCursorPos(ha + fa, ra)
            end
            if data3 == nil then
                data3 = {}
                for wa = 0, 10000 do
                    data3[wa] = 0
                end
            end
            local ya = na[3]
            if na[4] == ra and na[3] >= ha and na[3] <= ha + da - 1 then
                m.setCursorPos(ya, ra)
                data3[sa] = ya
                m.write("|")
            else
                m.setCursorPos(data3[sa], ra)
                m.write("|")
            end
            m.setBackgroundColor(ca)
            m.setTextColor(ma)
            if data3[sa] - ha >= 0 then
                return data3[sa] - ha
            elseif data3[sa] - ha < 0 then
                return 0
            end
        end
    end
end
function e.sliderVer(pa, va, ba, ga, ka, qa, ja, xa)
    if pa == "db" then
        if data10 == nil then
            return nil
        else
            return data10[va]
        end
    end
    if pa == "setdb" then
        if data10 == nil then
            return "no data to edit"
        else
            data10[va] = ba
            return "value changed too " .. type(ba)
        end
    end
    a(1, pa, "string")
    a(2, va, "table")
    a(3, ba, "number")
    a(4, ga, "number")
    a(5, ka, "number")
    a(6, qa, "number")
    a(7, ja, "string")
    a(8, xa, "string")
    if va[2] == pa then
        if va ~= nil then
            m = peripheral.wrap(pa)
            local za = m.getBackgroundColor()
            local Ea = m.getTextColor()
            m.setBackgroundColor(colors[ja])
            m.setTextColor(colors[xa])
            m.setCursorPos(ga, ka)
            for Ta = 0, qa do
                m.write("\124")
                m.setCursorPos(ga, ka - Ta)
            end
            if data10 == nil then
                data10 = {}
                for Aa = 0, 10000 do
                    data10[Aa] = 0
                end
            end
            local Oa = va[4]
            if va[3] == ga and va[4] <= ka and va[4] >= ka - qa + 1 then
                m.setCursorPos(ga, Oa)
                data10[ba] = Oa
                m.write("\xad")
            else
                m.setCursorPos(ga, data10[ba])
                m.write("\xad")
            end
            m.setBackgroundColor(za)
            m.setTextColor(Ea)
            if data10[ba] - ga >= 0 then
                return data10[ba] - ga
            elseif data10[ba] - ga < 0 then
                return 0
            end
        end
    end
end
function e.render(Ia, Na, Sa, Ha, Ra, Da)
    a(1, Ia, "string")
    a(2, Na, "string")
    a(3, Sa, "number")
    a(4, Ha, "number")
    a(5, Ra, "string")
    a(6, Da, "string", "number")
    local La = peripheral.wrap(Ia)
    local Ua = La.getBackgroundColor()
    local Ca = La.getTextColor()
    local Ma = {La.getCursorPos()}
    La.setTextColor(colors[Ra])
    if type(Da) == "string" then
        La.setBackgroundColor(colors[Da])
    elseif type(Da) == "number" then
        La.setBackgroundColor(Da)
    end
    La.setCursorPos(Sa, Ha)
    La.write(Na)
    La.setBackgroundColor(Ua)
    La.setTextColor(Ca)
    La.setCursorPos(Ma[1], Ma[2])
end
function e.menu(Fa, Wa, Ya, Pa, Va, Ba, Ga, Ka, Qa, Ja, Xa)
    a(1, Fa, "string")
    a(2, Wa, "table")
    a(3, Ya, "number")
    a(4, Pa, "number")
    a(5, Va, "number")
    a(6, Ba, "string")
    a(7, Ga, "string")
    a(8, Ka, "string")
    a(9, Qa, "string", "number", "boolean", "nil")
    a(10, Ja, "boolean", "nil")
    a(11, Xa, "string", "number", "boolean", "nil")
    if Wa[2] == Fa then
        if thisIsUseless == nil then
            for Za = 0, 1000 do
                thisIsUseless = {}
                thisIsUseless[Za] = false
            end
        end
		local eo = peripheral.wrap(Fa)
        if not thisIsUseless[Ya] then
			local tcol = eo.getBackgroundColor()
            e.render(Fa, Ka, Pa, Va, Ba, tcol)
        end
        if Wa ~= nil then
            local to = eo.getTextColor()
            local ao = eo.getBackgroundColor()
            local oo = #Ka
            if Wa[1] ~= "timeout" then
                if data4 == nil then
                    data4 = {}
                    for io = 0, 1000 do
                        data4[io] = false
                    end
                end
                if data5 == nil then
                    data5 = {}
                    for no = 0, 1000 do
                        data5[no] = false
                    end
                end
                if data6 == nil then
                    data6 = {}
                    for so = 0, 1000 do
                        data6[so] = false
                    end
                end
                if e.API(Wa, Pa, Va, oo, 1) == true then
                    data4[Ya] = Ka
                    data5[Ya] = Pa
                    data6[Ya] = Va
                    local function ho()
                        for ro = 1, 500 do
                            if data4[ro] ~= false then
                                eo.setBackgroundColor(ao)
                                eo.setCursorPos(data5[ro], data6[ro])
                                eo.setTextColor(colors[Ba])
                                eo.write(data4[ro])
                            end
                        end
                    end
                    ho()
                    eo.setCursorPos(data5[Ya], data6[Ya])
                    eo.setBackgroundColor(colors[Ga])
                    eo.setTextColor(colors[Ba])
                    eo.write(Ka)
                    eo.setTextColor(to)
                    eo.setBackgroundColor(ao)
                    menuout = Ka
                    if Qa == nil then
                        return menuout
                    else
                        if Ja == nil or Ja == false then
                            menuout = Qa
                            return menuout
                        else
                            menuout = {Qa, Xa}
                            if menuout == nil then
                                return 0
                            end
                            return menuout
                        end
                    end
                end
            end
        end
    end
    thisIsUseless[Ya] = true
    if Ja == true then
        if menuout == nil then
            menuout = {Qa, "nil"}
        end
    end
end
function e.menudata(...)
    local re = {}
	local re = table.pack(...)
	local ty = type(menuout)
    if ty == "string" or ty == "number" or ty == "function"  then
        return menuout
    elseif ty == "table" then
        for k,v in pairs(menuout) do
        	if menuout[k] == "nil" then
				menuout[k] = re[k]
			end
		end
		return table.unpack(menuout)
    end
end
function e.bar(lo, uo, co, mo, fo, wo, yo, po, vo, bo, go, ko, qo, jo, xo, zo)
    a(1, lo, "string")
    a(2, uo, "number")
    a(3, co, "number")
    a(4, mo, "number")
    a(5, fo, "number")
    a(6, wo, "number")
    a(7, yo, "number")
    a(8, po, "string")
    a(9, vo, "string")
    a(10, bo, "string")
    a(11, go, "boolean")
    a(12, ko, "boolean")
    a(13, qo, "string")
    a(14, jo, "boolean")
    a(15, xo, "boolean")
    a(16, zo, "boolean")
    if wo == nil or wo < 0 then
        wo = 0
    end
    if jo == nil then
    end
    if wo ~= nil then
        local Eo = peripheral.wrap(lo)
        oldcol = Eo.getBackgroundColor()
        oldcol1 = Eo.getTextColor()
        Eo.setTextColor(colors[bo])
        local function To()
            Eo.setBackgroundColor(colors[po])
            e.fill(lo, uo - 1, co - fo, mo, fo * 2)
            Eo.setBackgroundColor(oldcol)
            xm = Eo.getBackgroundColor()
            xb = Eo.getTextColor()
            Eo.setTextColor(xm)
            Eo.setBackgroundColor(xb)
            Eo.setCursorPos(uo - 1, co - fo)
            if zo then
                Eo.setBackgroundColor(colors[bo])
            end
            if zo then
                Eo.write(string.rep("\x83", mo + 1))
                Eo.setTextColor(xb)
                Eo.setBackgroundColor(xm)
            else
                Eo.write("\159" .. string.rep("\143", mo - 1))
                Eo.setTextColor(xb)
                Eo.setBackgroundColor(xm)
                Eo.write("\144")
            end
            if zo then
                Eo.setBackgroundColor(colors[bo])
            end
            Eo.setCursorPos(uo - 1, co + fo)
            if zo then
                Eo.write(string.rep("\x8c", mo + 1))
            else
                Eo.write("\130" .. string.rep("\131", mo - 1) .. "\129")
            end
            for Ao = 0, fo * 2 - 2 do
                if not zo then
                    Eo.setTextColor(xm)
                    Eo.setBackgroundColor(xb)
                end
                Eo.setCursorPos(uo - 1, co + Ao - fo + 1)
                if zo then
                    Eo.setBackgroundColor(colors[bo])
                end
                Eo.write("\x95")
                Eo.setCursorPos(uo - 2 + (mo + 1), co + Ao - fo + 1)
                if not zo then
                    Eo.setTextColor(xb)
                    Eo.setBackgroundColor(xm)
                end
                Eo.write("\x95")
            end
        end
        if xo ~= false then
            To()
        else
            e.fill(lo, uo - 1, co - fo, mo, fo * 2)
        end
        local Oo = wo / yo * mo
        local Io = wo / yo * fo
        local No = math.ceil(Io)
        local So = No * 2 - 2
        local Ho = co + fo
        Eo.setBackgroundColor(colors[vo])
        if ko == false or ko == nil then
            e.fill(lo, uo, co - fo + 1, Oo - 1, fo * 2 - 1)
        else
            e.fill(lo, uo, Ho - 1 - So, mo - 1, So + 1)
        end
        if go == true then
            Eo.setCursorPos(uo, co)
            Eo.setTextColor(colors[bo])
            if ko == true then
                if jo then
                    if wo >= yo / 2 then
                        Eo.setBackgroundColor(colors[vo])
                    else
                        Eo.setBackgroundColor(colors[po])
                    end
                else
                    if wo >= yo / 2 - yo / fo then
                        Eo.setBackgroundColor(colors[vo])
                    else
                        Eo.setBackgroundColor(colors[po])
                    end
                end
            elseif ko == false then
                Eo.setCursorPos(uo, co)
                Eo.setTextColor(colors[bo])
                if ko == true then
                    if wo >= 1 then
                        Eo.setBackgroundColor(colors[vo])
                    else
                        Eo.setBackgroundColor(colors[po])
                    end
                end
            end
            if jo then
                Eo.write(wo .. "/" .. yo)
                Eo.setCursorPos(uo, co + 1)
                Eo.write(qo)
            else
                Eo.write(wo .. "/" .. yo .. " " .. qo)
            end
            Eo.setBackgroundColor(oldcol)
            Eo.setTextColor(oldcol1)
        end
        Eo.setTextColor(oldcol1)
        Eo.setBackgroundColor(oldcol)
    end
end
function e.frame(Ro, Do, Lo, Uo, Co, Mo, Fo, Wo)
    a(1, Ro, "string")
    a(2, Do, "number")
    a(3, Lo, "number")
    a(4, Uo, "number")
    a(5, Co, "number")
    a(6, Mo, "string")
    a(7, Fo, "string")
    a(8, Wo, "boolean", "nil")
    local Yo = peripheral.wrap(Ro)
    local Po = Yo.getBackgroundColor()
    local Vo = Yo.getTextColor()
    Yo.setBackgroundColor(colors[Fo])
    e.fill(Ro, Do - 1, Lo - Co, Uo, Co * 2)
    Yo.setBackgroundColor(Po)
    xm = Yo.getBackgroundColor()
    xb = Yo.getTextColor()
    Yo.setTextColor(xm)
    Yo.setBackgroundColor(xb)
    Yo.setCursorPos(Do - 1, Lo - Co)
    if Wo then
        Yo.setBackgroundColor(colors[Mo])
        Yo.setTextColor(Po)
        Yo.write(string.rep("\x83", Uo + 1))
        Yo.setTextColor(xb)
        Yo.setBackgroundColor(xm)
    else
        Yo.setTextColor(Po)
        Yo.setBackgroundColor(colors[Mo])
        Yo.write("\159" .. string.rep("\143", Uo - 1))
        Yo.setTextColor(colors[Mo])
        Yo.setBackgroundColor(Po)
        Yo.write("\144")
    end
    Yo.setCursorPos(Do - 1, Lo + Co)
    if Wo then
        Yo.setBackgroundColor(Po)
        Yo.setTextColor(colors[Mo])
        Yo.write(string.rep("\x8f", Uo + 1))
        Yo.setBackgroundColor(colors[Fo])
        Yo.setTextColor(colors[Mo])
    else
        Yo.write("\130" .. string.rep("\131", Uo - 1) .. "\129")
    end
    for Bo = 0, Co * 2 - 2 do
        if not Wo then
            Yo.setTextColor(xm)
            Yo.setBackgroundColor(xb)
        end
        Yo.setCursorPos(Do - 1, Lo + Bo - Co + 1)
        if Wo then
            Yo.setBackgroundColor(colors[Mo])
        end
        Yo.setBackgroundColor(colors[Mo])
        Yo.write("\x95")
        Yo.setCursorPos(Do - 2 + (Uo + 1), Lo + Bo - Co + 1)
        if not Wo then
            Yo.setTextColor(xb)
            Yo.setBackgroundColor(xm)
        end
        Yo.setTextColor(colors[Mo])
        Yo.write("\x95")
    end
    Yo.setBackgroundColor(Po)
    Yo.setTextColor(Vo)
end
function t.fill(Go, Ko, Qo, Jo, chars)
	local char
	if _9551_buttonH_doFillCharCustom  then
        char = _9551_buttonH_doFillCharCustom       
		_9551_buttonH_doFillCharCustom =  nil
	else
		char = " "
	end
	if not chars then
        a(1, Go, "number")
        a(2, Ko, "number")
        a(3, Qo, "number")
        a(4, Jo, "number")
        for Xo = 0, Jo - 1 do
            term.setCursorPos(Go, Ko + Xo)
            term.write(string.rep(char, Qo))
        end
	else
		_9551_buttonH_doFillCharCustom = chars
	end
end
function t.API(Zo, ei, ti, ai, oi)
    a(1, Zo, "table")
    a(2, ei, "number")
    a(3, ti, "number")
    a(4, ai, "number")
    a(5, oi, "number")
    if Zo == true then
        Zo = {os.pullEvent("mouse_click")}
    end
    if Zo[3] >= ei and Zo[3] <= ei + ai - 1 then
        return Zo[4] >= ti and Zo[4] <= ti + oi - 1
    end
end
function t.boxAPI(ii, ni, si, hi, ri, di)
    a(1, ii, "table")
    a(2, ni, "number")
    a(3, si, "number")
    a(4, hi, "number")
    a(5, ri, "number")
    a(6, di, "string")
    local li = ni - hi + 1
    local ui = si - ri
    local ci = #di - 2
    local mi = false
    if hi >= 1 then
        hi = hi - 1
        mi = true
    end
    if hi > 0 or mi then
        ci = #di + hi * 2
        li = li - 1
    end
    local fi = ri * 2 + 1
    return t.API(ii, li - 1, ui, ci + 2, fi), {li, ui, ci, fi}
end
function t.boxButton(wi, yi, pi, vi, bi, gi, ki, qi, ji)
    a(1, wi, "number")
    a(2, yi, "table")
    a(3, pi, "number")
    a(4, vi, "number")
    a(5, bi, "string")
    a(6, gi, "string")
    a(7, ki, "string", "number", "nil")
    a(8, qi, "number", "nil")
    a(9, ji, "number", "nil")
    if not qi then
        qi = 0
    end
    if not ji then
        ji = 0
    end
    if not ki then
        ki = ""
    end
    local ki = tostring(ki)
    if yi[2] == wi or yi[2] == "tout" then
        if yi ~= nil then
            local xi, zi = term.getTextColor(), term.getBackgroundColor()
            term.setBackgroundColor(colors[bi])
            term.setTextColor(colors[gi])
            local Ei, Ti = t.boxAPI(yi, pi, vi, qi or 1, ji or 1, ki)
            t.fill(Ti[1] - 1, Ti[2], Ti[3] + 2, Ti[4])
            local Ai, Oi, Ii, Ni = Ti[1], Ti[2], Ti[3] + Ti[1], Ti[4] + Ti[2]
            term.setCursorPos(math.floor(Ai + (Ii - Ai) / 2 - ki:len() / 2 + 0.5), math.floor(Oi + (Ni - Oi) / 2))
            term.write(ki)
            term.setBackgroundColor(zi)
            term.setTextColor(xi)
            return Ei
        end
    end
end
function t.touch()
    local Si = {os.pullEvent("mouse_click")}
    return Si
end
function t.timetouch(Hi,iG,drag)
    a(1, Hi, "number", "nil")
	local Ri
    if Hi then
		Ri = os.startTimer(Hi)
	end
	if drag then
        while true do
            local Di
            if Hi then Di = {os.pullEvent()} end
            if not Hi then Di = {os.pullEvent("mouse_click")} end
            if not iG then
                if Di[1] == "timer" and Di[2] == Ri then
                    return {"timeout", "tout", 1000, 1000}
                elseif (Di[1] == "mouse_click" or Di[1] == "mouse_drag") then
                    return {Di[1], Di[2], Di[3], Di[4]}
                end
            elseif iG then
                if Di[1] == "timer" and Di[2] == Ri then
                    return {"timeout", "tout", 1000, 1000}
                elseif (Di[1] == "mouse_click" or Di[1] == "mouse_drag") and not iG[Di[2]] then
                    return {Di[1], Di[2], Di[3], Di[4]}
                end
            end
		end
	else
		while true do
            local Di
            if Hi then Di = {os.pullEvent()} end
            if not Hi then Di = {os.pullEvent("mouse_click")} end
            if not iG then
                if Di[1] == "timer" and Di[2] == Ri then
                    return {"timeout", "tout", 1000, 1000}
                elseif (Di[1] == "mouse_click") then
                    return {Di[1], Di[2], Di[3], Di[4]}
                end
            elseif iG then
                if Di[1] == "timer" and Di[2] == Ri then
                    return {"timeout", "tout", 1000, 1000}
                elseif (Di[1] == "mouse_click") and not iG[Di[2]] then
                    return {Di[1], Di[2], Di[3], Di[4]}
                end
            end
		end
    end
end
function t.button(Li, Ui, Ci, Mi, Fi)
    a(1, Li, "number")
    a(2, Ui, "table")
    a(3, Ci, "number")
    a(4, Mi, "number")
    a(5, Fi, "string")
    if Ui[2] == Li or Ui[2] == "tout" then
        if Ui ~= nil then
            local Wi = t.API(Ui, Ci, Mi, #Fi, 1)
            term.setCursorPos(Ci, Mi)
            term.write(Fi)
            return Wi
        end
    end
end
function t.counter(Yi, Pi, Vi, Bi, Gi, Ki, Qi, Ji, Xi)
    if Yi == "db" then
        if data == nil then
            return nil
        else
            return data[Pi]
        end
    end
    if Yi == "setdb" then
        if data == nil then
            return "no data to edit"
        else
            data[Pi] = Vi
            return "value changed too " .. type(Vi)
        end
    end
    a(1, Yi, "number")
    a(2, Pi, "table")
    a(3, Vi, "number")
    a(4, Bi, "number")
    a(5, Gi, "number")
    a(6, Ki, "number")
    a(7, Qi, "number")
    a(8, Ji, "number")
    a(9, Xi, "string")
    if Pi[2] == Yi or Pi[2] == "tout" then
        if Pi ~= nil then
            if data == nil then
                data = {}
                for Zi = 0, 1000 do
                    data[Zi] = 0
                end
            end
            term.setCursorPos(Bi, Gi)
            term.write("\24" .. " " .. data[Vi])
            term.setCursorPos(Bi, Gi + 1)
            term.write("\25")
            if t.API(Pi, Bi, Gi, 1, 1) == true then
                if data[Vi] < Qi then
                    data[Vi] = data[Vi] + Ki
                    term.setCursorPos(Bi, Gi)
                    term.setTextColor(colors.green)
                    term.write("\24" .. " " .. data[Vi] .. " ")
                    term.setCursorPos(Bi, Gi + 1)
                    term.setTextColor(colors.red)
                    term.write("\25")
                    term.setTextColor(colors[Xi])
                    return data[Vi]
                end
            end
        end
        if t.API(Pi, Bi, Gi + 1, 1, 1) == true then
            if data[Vi] > Ji then
                data[Vi] = data[Vi] - Ki
                term.setCursorPos(Bi, Gi)
                term.setTextColor(colors.green)
                term.write("\24" .. " " .. data[Vi] .. " ")
                term.setCursorPos(Bi, Gi + 1)
                term.setTextColor(colors.red)
                term.write("\25")
                term.setTextColor(colors[Xi])
                return data[Vi]
            end
        end
    end
end
function t.switch(en, tn, an, on, nn, sn, hn, rn, dn, ln, un)
    if en == "db" then
        if data1 == nil then
            return nil
        else
            return data1[tn]
        end
    end
    if en == "setdb" then
        if data1 == nil then
            return "no data to edit"
        else
            data1[tn] = an
            return "value changed too " .. type(an)
        end
    end
    a(1, en, "number")
    a(2, tn, "number")
    a(3, an, "table")
    a(4, on, "number")
    a(5, nn, "number")
    a(6, sn, "string")
    a(7, hn, "string")
    a(8, rn, "string")
    a(9, dn, "string")
    a(10, ln, "number", "nil")
    a(11, un, "number", "nil")
	local fn
    if an[2] == en or an[2] == "tout" then
        if an ~= nil then
            if data1 == nil then
                data1 = {}
                for cn = 0, 1000 do
                    data1[cn] = false
                end
            end
            local function mn()
                data1[tn] = not data1[tn]
            end
            if not data1[tn] then
                fn = sn
            else
                fn = hn
            end
            if t.boxButton(en, an, on, nn, fn, rn, dn, ln, un) then
                mn()
            end
            return data1[tn]
        end
    elseif an and data1 ~= nil and fn then
		t.boxButton(en, an, on, nn, fn, rn, dn, ln, un)
	end
end
function t.switchn(wn, yn, pn, vn, bn, gn, kn, qn, jn, xn, zn, En)
    if wn == "db" then
        if data2 == nil then
            return nil
        else
            return data2[yn]
        end
    end
    if wn == "setdb" then
        if data2 == nil then
            return "no data to edit"
        else
            data2[yn] = pn
            return "value changed too " .. type(pn)
        end
    end
    a(1, wn, "number")
    a(2, yn, "number")
    a(3, pn, "table")
    a(4, vn, "number")
    a(5, bn, "number")
    a(6, gn, "string")
    a(7, kn, "string")
    a(8, qn, "string")
    a(9, jn, "string")
    a(10, xn, "string")
    a(11, zn, "number", "nil")
    a(12, En, "number", "nil")
	local On
    local In
    if pn[2] == wn or pn[2] == "tout" then
        if pn ~= nil then
            if data2 == nil then
                data2 = {}
                for Tn = 0, 1000 do
                    data2[Tn] = false
                end
            end
            local function An()
                data2[yn] = not data2[yn]
            end
            if not data2[yn] then
                On = gn
                In = jn
            else
                On = kn
                In = xn
            end
            if t.boxButton(wn, pn, vn, bn, On, qn, In, zn, En) then
                An()
            end
        end
    elseif pn and data2 ~= nil and On and In then
		t.boxButton(wn, pn, vn, bn, On, qn, In, zn, En)
	end
end
function t.bundle(Nn, Sn, Hn)
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
function t.signal(ea, ta, aa, oa)
    a(1, ea, "string")
    a(2, ta, "boolean", "string")
    a(3, aa, "number","string")
    a(4, oa, "boolean")
    if ta == "clear" then
        rs.setBundledOutput(ea, 0)
    else
        if oa == true then
            if ta == "on" then
                ta = true
            end
            if ta == "nil" then
                ta = false
            end
        end
        if ta ~= nil then
            if type(aa) == "number" then
                if ta == true then
                    t.bundle(ea, aa, true)
                elseif ta == false then
                    t.bundle(ea, aa, false)
                end
            elseif type(aa) == "string" then
                if ta == true then
                    t.bundle(ea, colors[aa], true)
                elseif ta == false then
                    t.bundle(ea, colors[aa], false)
                end
            end
        end
    end
end
function t.sliderHor(Cn, Mn, Fn, Wn, Yn, Pn, Vn, Bn)
    if Cn == "db" then
        if data3 == nil then
            return nil
        else
            return data3[Mn]
        end
    end
    if Cn == "setdb" then
        if data3 == nil then
            return "no data to edit"
        else
            data3[Mn] = Fn
            return "value changed too " .. type(Fn)
        end
    end
    a(1, Cn, "number")
    a(2, Mn, "table")
    a(3, Fn, "number")
    a(4, Wn, "number")
    a(5, Yn, "number")
    a(6, Pn, "number")
    a(7, Vn, "string")
    a(8, Bn, "string")
    if Mn[2] == Cn or Mn[2] == "tout" then
        if Mn ~= nil then
            local Gn = term.getBackgroundColor()
            local Kn = term.getTextColor()
            term.setBackgroundColor(colors[Vn])
            term.setTextColor(colors[Bn])
            term.setCursorPos(Wn, Yn)
            for Qn = 0, Pn do
                term.write("-")
                term.setCursorPos(Wn + Qn, Yn)
            end
            if data3 == nil then
                data3 = {}
                for Jn = 0, 10000 do
                    data3[Jn] = 0
                end
            end
            local Xn = Mn[3]
            if Mn[4] == Yn and Mn[3] >= Wn and Mn[3] <= Wn + Pn - 1 then
                term.setCursorPos(Xn, Yn)
                data3[Fn] = Xn
                term.write("|")
            else
                term.setCursorPos(data3[Fn], Yn)
                term.write("|")
            end
            term.setBackgroundColor(Gn)
            term.setTextColor(Kn)
            if data3[Fn] - Wn >= 0 then
                return data3[Fn] - Wn
            elseif data3[Fn] - Wn < 0 then
                return 0
            end
        end
    end
end
function t.sliderVer(Zn, es, ts, as, is, ns, ss, hs)
    if Zn == "db" then
        if data10 == nil then
            return nil
        else
            return data10[es]
        end
    end
    if Zn == "setdb" then
        if data10 == nil then
            return "no data to edit"
        else
            data10[es] = ts
            return "value changed too " .. type(ts)
        end
    end
    a(1, Zn, "number")
    a(2, es, "table")
    a(3, ts, "number")
    a(4, as, "number")
    a(5, is, "number")
    a(6, ns, "number")
    a(7, ss, "string")
    a(8, hs, "string")
    if es[2] == Zn or es[2] == "tout" then
        if es ~= nil then
            local ds = term.getBackgroundColor()
            local ls = term.getTextColor()
            term.setBackgroundColor(colors[ss])
            term.setTextColor(colors[hs])
            term.setCursorPos(as, is)
            for us = 0, ns do
                term.write("\124")
                term.setCursorPos(as, is - us)
            end
            if data10 == nil then
                data10 = {}
                for cs = 0, 10000 do
                    data10[cs] = 0
                end
            end
            local ms = es[4]
            if es[3] == as and es[4] <= is and es[4] >= is - ns + 1 then
                term.setCursorPos(as, ms)
                data10[ts] = ms
                term.write("\xad")
            else
                term.setCursorPos(as, data10[ts])
                term.write("\xad")
            end
            term.setBackgroundColor(ds)
            term.setTextColor(ls)
            if data10[ts] - as >= 0 then
                return data10[ts] - as
            elseif data10[ts] - as < 0 then
                return 0
            end
        end
    end
end
function t.render(fs, ws, ys, ps, vs)
    a(1, fs, "string")
    a(2, ws, "number")
    a(3, ys, "number")
    a(4, ps, "string")
    a(5, vs, "string", "number")
    local bs = term.getBackgroundColor()
    local gs = term.getTextColor()
    local ks = {term.getCursorPos()}
    term.setTextColor(colors[ps])
    if type(vs) == "string" then
        term.setBackgroundColor(colors[vs])
    elseif type(vs) == "number" then
        term.setBackgroundColor(vs)
    end
    term.setCursorPos(ws, ys)
    term.write(fs)
    term.setBackgroundColor(bs)
    term.setTextColor(gs)
    term.setCursorPos(ks[1], ks[2])
end
function t.menu(qs, js, xs, zs, Es, Ts, As, Os, Is, Ns, Ss)
    a(1, qs, "number")
    a(2, js, "table")
    a(3, xs, "number")
    a(4, zs, "number")
    a(5, Es, "number")
    a(6, Ts, "string")
    a(7, As, "string")
    a(8, Os, "string")
    a(9, Is, "string", "number", "boolean", "nil")
    a(10, Ns, "boolean", "nil")
    a(11, Ss, "string", "number", "boolean", "nil")
    if js[2] == qs or js[2] == "tout" then
        if thisIsUseless == nil then
            for Hs = 0, 1000 do
                thisIsUseless = {}
                thisIsUseless[Hs] = false
            end
        end
        if not thisIsUseless[xs] then
			local tcol = term.getBackgroundColor()
            t.render(Os, zs, Es, Ts, tcol)
        end
        if js ~= nil then
            local Rs = term.getTextColor()
            local Ds = term.getBackgroundColor()
            local Ls = #Os
            if js[1] ~= "timeout" then
                if data4 == nil then
                    data4 = {}
                    for Us = 0, 1000 do
                        data4[Us] = false
                    end
                end
                if data5 == nil then
                    data5 = {}
                    for Cs = 0, 1000 do
                        data5[Cs] = false
                    end
                end
                if data6 == nil then
                    data6 = {}
                    for Ms = 0, 1000 do
                        data6[Ms] = false
                    end
                end
                if t.API(js, zs, Es, Ls, 1) == true then
                    data4[xs] = Os
                    data5[xs] = zs
                    data6[xs] = Es
                    local function Fs()
                        for Ws = 1, 500 do
                            if data4[Ws] ~= false then
                                term.setBackgroundColor(Ds)
                                term.setCursorPos(data5[Ws], data6[Ws])
                                term.setTextColor(colors[Ts])
                                term.write(data4[Ws])
                            end
                        end
                    end
                    Fs()
                    term.setCursorPos(data5[xs], data6[xs])
                    term.setBackgroundColor(colors[As])
                    term.setTextColor(colors[Ts])
                    term.write(Os)
                    term.setTextColor(Rs)
                    term.setBackgroundColor(Ds)
                    menuout = Os
                    if Is == nil then
                        return menuout
                    else
                        if Ns == nil or Ns == false then
                            menuout = Is
                            return menuout
                        else
                            menuout = {Is, Ss}
                            if menuout == nil then
                                return 0
                            end
                            return menuout
                        end
                    end
                end
            end
        end
    end
    thisIsUseless[xs] = true
    if Ns == true then
        if menuout == nil then
            menuout = {Is, "nil"}
        end
    end
end
function t.menudata(...)
	local re = {}
	local re = table.pack(...)
	local ty = type(menuout)
    if ty == "string" or ty == "number" or ty == "function"  then
        return menuout
    elseif ty == "table" then
        for k,v in pairs(menuout) do
        	if menuout[k] == "nil" then
				menuout[k] = re[k]
			end
		end
		return table.unpack(menuout)
    end
end
function t.bar(Ys, Ps, Vs, Bs, Gs, Ks, Qs, Js, Xs, Zs, eh, th, ah, oh, ih)
    a(1, Ys, "number")
    a(2, Ps, "number")
    a(3, Vs, "number")
    a(4, Bs, "number")
    a(5, Gs, "number")
    a(6, Ks, "number")
    a(7, Qs, "string")
    a(8, Js, "string")
    a(9, Xs, "string")
    a(10, Zs, "boolean")
    a(11, eh, "boolean")
    a(12, th, "string")
    a(13, ah, "boolean")
    a(14, oh, "boolean")
    a(15, ih, "boolean")
    if Gs == nil or Gs < 0 then
        Gs = 0
    end
    if ah == nil then
    end
    if Gs ~= nil then
        oldcol = term.getBackgroundColor()
        oldcol1 = term.getTextColor()
        term.setTextColor(colors[Xs])
        local function nh()
            term.setBackgroundColor(colors[Qs])
            t.fill(Ys - 1, Ps - Bs, Vs, Bs * 2)
            term.setBackgroundColor(oldcol)
            xm = term.getBackgroundColor()
            xb = term.getTextColor()
            term.setTextColor(xm)
            term.setBackgroundColor(xb)
            term.setCursorPos(Ys - 1, Ps - Bs)
            if ih then
                term.setBackgroundColor(colors[Xs])
            end
            if ih then
                term.write(string.rep("\x83", Vs + 1))
                term.setTextColor(xb)
                term.setBackgroundColor(xm)
            else
                term.write("\159" .. string.rep("\143", Vs - 1))
                term.setTextColor(xb)
                term.setBackgroundColor(xm)
                term.write("\144")
            end
            if ih then
                term.setBackgroundColor(colors[Xs])
            end
            term.setCursorPos(Ys - 1, Ps + Bs)
            if ih then
                term.write(string.rep("\x8c", Vs + 1))
            else
                term.write("\130" .. string.rep("\131", Vs - 1) .. "\129")
            end
            for sh = 0, Bs * 2 - 2 do
                if not ih then
                    term.setTextColor(xm)
                    term.setBackgroundColor(xb)
                end
                term.setCursorPos(Ys - 1, Ps + sh - Bs + 1)
                if ih then
                    term.setBackgroundColor(colors[Xs])
                end
                term.write("\x95")
                term.setCursorPos(Ys - 2 + (Vs + 1), Ps + sh - Bs + 1)
                if not ih then
                    term.setTextColor(xb)
                    term.setBackgroundColor(xm)
                end
                term.write("\x95")
            end
        end
        if oh ~= false then
            nh()
        else
            t.fill(Ys - 1, Ps - Bs, Vs, Bs * 2)
        end
        local hh = Gs / Ks * Vs
        local rh = Gs / Ks * Bs
        local dh = math.ceil(rh)
        local lh = dh * 2 - 2
        local uh = Ps + Bs
        term.setBackgroundColor(colors[Js])
        if eh == false or eh == nil then
            t.fill(Ys, Ps - Bs + 1, hh - 1, Bs * 2 - 1)
        else
            t.fill(Ys, uh - 1 - lh, Vs - 1, lh + 1)
        end
        if Zs == true then
            term.setCursorPos(Ys, Ps)
            term.setTextColor(colors[Xs])
            if eh == true then
                if ah then
                    if Gs >= Ks / 2 then
                        term.setBackgroundColor(colors[Js])
                    else
                        term.setBackgroundColor(colors[Qs])
                    end
                else
                    if Gs >= Ks / 2 - Ks / Bs then
                        term.setBackgroundColor(colors[Js])
                    else
                        term.setBackgroundColor(colors[Qs])
                    end
                end
            elseif eh == false then
                term.setCursorPos(Ys, Ps)
                term.setTextColor(colors[Xs])
                if eh == true then
                    if Gs >= 1 then
                        term.setBackgroundColor(colors[Js])
                    else
                        term.setBackgroundColor(colors[Qs])
                    end
                end
            end
            if ah then
                term.write(Gs .. "/" .. Ks)
                term.setCursorPos(Ys, Ps + 1)
                term.write(th)
            else
                term.write(Gs .. "/" .. Ks .. " " .. th)
            end
            term.setBackgroundColor(oldcol)
            term.setTextColor(oldcol1)
        end
        term.setTextColor(oldcol1)
        term.setBackgroundColor(oldcol)
    end
end
function t.frame(ch, mh, fh, wh, yh, ph, vh)
    a(1, ch, "number")
    a(2, mh, "number")
    a(3, fh, "number")
    a(4, wh, "number")
    a(5, yh, "string")
    a(6, ph, "string")
    a(7, vh, "boolean", "nil")
    local bh = term.getBackgroundColor()
    local gh = term.getTextColor()
    term.setBackgroundColor(colors[ph])
    t.fill(ch - 1, mh - wh, fh, wh * 2)
    term.setBackgroundColor(bh)
    xm = term.getBackgroundColor()
    xb = term.getTextColor()
    term.setTextColor(xm)
    term.setBackgroundColor(xb)
    term.setCursorPos(ch - 1, mh - wh)
    if vh then
        term.setBackgroundColor(colors[yh])
        term.setTextColor(bh)
        term.write(string.rep("\x83", fh + 1))
        term.setTextColor(xb)
        term.setBackgroundColor(xm)
    else
        term.setTextColor(bh)
        term.setBackgroundColor(colors[yh])
        term.write("\159" .. string.rep("\143", fh - 1))
        term.setTextColor(colors[yh])
        term.setBackgroundColor(bh)
        term.write("\144")
    end
    term.setCursorPos(ch - 1, mh + wh)
    if vh then
        term.setBackgroundColor(bh)
        term.setTextColor(colors[yh])
        term.write(string.rep("\x8f", fh + 1))
        term.setBackgroundColor(colors[ph])
        term.setTextColor(colors[yh])
    else
        term.write("\130" .. string.rep("\131", fh - 1) .. "\129")
    end
    for kh = 0, wh * 2 - 2 do
        if not vh then
            term.setTextColor(xm)
            term.setBackgroundColor(xb)
        end
        term.setCursorPos(ch - 1, mh + kh - wh + 1)
        if vh then
            term.setBackgroundColor(colors[yh])
        end
        term.setBackgroundColor(colors[yh])
        term.write("\x95")
        term.setCursorPos(ch - 2 + (fh + 1), mh + kh - wh + 1)
        if not vh then
            term.setTextColor(xb)
            term.setBackgroundColor(xm)
        end
        term.setTextColor(colors[yh])
        term.write("\x95")
    end
    term.setBackgroundColor(bh)
    term.setTextColor(gh)
end
return {monitor = e, terminal = t}
