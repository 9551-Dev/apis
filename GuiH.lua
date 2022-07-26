--[[
The MIT License (MIT) 
Copyright © 2022 Oliver Caha (9551Dev)
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. 
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local files={
  [ "objects/circle/object" ] = "local e=require(\"api\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(a.symbols)~=\"table\"then o.symbols={}end if type(o.filled)~=\"boolean\"then\
o.filled=true end local i={name=o.name or e.uuid4(),positioning={x=o.x or\
1,y=o.y or 1,radius=o.radius or 3},symbol=o.symbol or\" \",bg=o.background_color\
or colors.white,fg=o.text_color or\
colors.black,visible=o.visible,filled=o.filled,order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,}return i\
end",
  [ "objects/triangle/logic" ] = "return\
function()end\
",
  [ "objects/rectangle/object" ] = "local e=require(\"api\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(o.symbols)~=\"table\"then o.symbols={}end local i={name=o.name or\
e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or 0,height=o.height\
or 0},visible=o.visible,color=o.color or\
colors.white,filled=o.filled,symbols={[\"top_left\"]=o.symbols.top_left\
or{sym=\" \",bg=o.color or\
colors.white,fg=colors.black},[\"top_right\"]=o.symbols.top_right\
or{sym=\" \",bg=o.color or\
colors.white,fg=colors.black},[\"bottom_left\"]=o.symbols.bottom_left\
or{sym=\" \",bg=o.color or\
colors.white,fg=colors.black},[\"bottom_right\"]=o.symbols.bottom_right\
or{sym=\" \",bg=o.color or\
colors.white,fg=colors.black},[\"side_left\"]=o.symbols.side_left\
or{sym=\" \",bg=o.color or\
colors.white,fg=colors.black},[\"side_right\"]=o.symbols.side_right\
or{sym=\" \",bg=o.color or\
colors.white,fg=colors.black},[\"side_top\"]=o.symbols.side_top\
or{sym=\" \",bg=o.color or\
colors.white,fg=colors.black},[\"side_bottom\"]=o.symbols.side_bottom\
or{sym=\" \",bg=o.color or\
colors.white,fg=colors.black},[\"inside\"]=o.symbols.inside or{sym=\" \",bg=o.color\
or colors.white,fg=colors.black}},order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,}return i\
end",
  [ "objects/button/object" ] = "local e=require(\"api\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end local o={name=a.name or\
e.uuid4(),positioning={x=a.x or 1,y=a.y or 1,width=a.width or 0,height=a.height\
or 0},on_click=a.on_click or function()end,background_color=a.background_color\
or t.term_object.getBackgroundColor(),text_color=a.text_color or\
t.term_object.getTextColor(),symbol=a.symbol\
or\" \",texture=a.tex,text=a.text,visible=a.visible,reactive=a.reactive,react_to_events={mouse_click=true,monitor_touch=true,},order=a.order\
or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,tags={},btn=a.btn,value=(a.value~=nil)and\
a.value or true}return o\
end",
  [ "objects/circle/logic" ] = "return\
function()end\
",
  [ "objects/inputbox/object" ] = "local e=require(\"api\")return function(t,a)if type(a.visible)~=\"boolean\"then\
a.visible=true end if type(a.reactive)~=\"boolean\"then a.reactive=true end if\
not a.autoc then a.autoc={}end if type(a.autoc.put_space)~=\"boolean\"then\
a.autoc.put_space=true end local o={name=a.name or\
e.uuid4(),visible=a.visible,reactive=a.reactive,react_to_events={[\"mouse_click\"]=true,[\"monitor_touch\"]=true,[\"char\"]=true,[\"key\"]=true,[\"key_up\"]=true,[\"paste\"]=true},positioning={x=a.x\
or 1,y=a.y or 1,width=a.width or 0,},pattern=a.pattern\
or\".\",selected=a.selected or\
false,insert=false,ctrl=false,btn=a.btn,cursor_pos=a.cursor_pos or\
0,char_limit=a.char_limit or a.width or\
math.huge,input=\"\",background_color=a.background_color or\
t.term_object.getBackgroundColor(),text_color=a.text_color or\
t.term_object.getTextColor(),order=a.order or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,shift=0,space_symbol=a.space_symbol\
or\"\\175\",background_symbol=a.background_symbol\
or\" \",on_change_select=a.on_change_select or\
function()end,on_change_input=a.on_change_input or\
function()end,on_enter=a.on_enter or\
function()end,replace_char=a.replace_char,ignore_tab=a.ignore_tab,autoc={strings=a.autoc.strings\
or{},spec_strings=a.autoc.spec_strings or{},bg=a.autoc.bg or a.background_color\
or t.term_object.getBackgroundColor(),fg=a.autoc.fg or a.text_color or\
t.term_object.getTextColor(),current=\"\",selected=1,put_space=a.autoc.put_space}}o.cursor_x=o.positioning.x\
return o\
end",
  [ "objects/triangle/object" ] = "local e=require(\"api\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(a.symbols)~=\"table\"then o.symbols={}end if type(o.filled)~=\"boolean\"then\
o.filled=true end if type(o.p1)~=\"table\"then o.p1={}end if\
type(o.p2)~=\"table\"then o.p2={}end if type(o.p3)~=\"table\"then o.p3={}end local\
i={name=o.name or e.uuid4(),positioning={p1={x=o.p1[1]or 1,y=o.p1[2]or\
1},p2={x=o.p2[1]or 1,y=o.p2[2]or 1},p3={x=o.p3[1]or 1,y=o.p3[2]or\
1}},symbol=o.symbol or\" \",bg=o.background_color or colors.white,fg=o.text_color\
or colors.black,visible=o.visible,filled=o.filled,order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,}return i\
end",
  [ "objects/inputbox/graphic" ] = "local e=require(\"graphic_handle\").code local function t(a)return\
a:gsub(\"[%[%]%(%)%.%+%-%%%$%^%*%?]\",\"%%%1\")end return function(o)local\
i=o.canvas.term_object local n,s=o.input,0 if#o.input>=o.positioning.width-1\
then\
n=o.input:sub(#o.input-o.positioning.width+1-o.shift,#o.input-o.shift)s=#o.input-#n\
end local h=(o.positioning.x+o.cursor_pos)-s\
i.setCursorPos(o.positioning.x,o.positioning.y)local r=n\
n=n:gsub(\" \",o.space_symbol)..o.background_symbol:rep(o.positioning.width-#n+1)local\
d if o.replace_char then\
d=o.replace_char:rep(#r)..o.background_symbol:rep(o.positioning.width-#r+1)end\
i.blit(d or\
n,e.to_blit[o.text_color]:rep(#n),e.to_blit[o.background_color]:rep(#n))if\
o.selected and(o.char_limit>o.cursor_pos)then\
i.setCursorPos(math.max(h+o.shift,o.positioning.x),o.positioning.y)if\
h+o.shift<o.positioning.x then o.shift=o.shift+1 end if\
h+o.shift>o.positioning.x+o.positioning.width then o.shift=o.shift-1 end local\
l if o.cursor_pos<o.positioning.width then\
l=o.input:sub(o.cursor_pos+1,o.cursor_pos+1)o.cursor_x=o.cursor_pos+1 else\
l=o.input:sub(o.cursor_pos+1,o.cursor_pos+1)i.setCursorPos(h+o.shift,o.positioning.y)end\
o.cursor_x=h+o.shift i.blit((l)~=\"\"and(o.replace_char or l)or\"_\",l~=\"\"and\
e.to_blit[o.background_color]or e.to_blit[o.text_color],l~=\"\"and\
e.to_blit[o.text_color]or e.to_blit[o.background_color])else\
i.setCursorPos(o.positioning.x+o.positioning.width,o.positioning.y)i.blit(\"\\127\",e.to_blit[o.text_color],e.to_blit[o.background_color])end\
if o.autoc.str_diff then\
i.setCursorPos(o.cursor_x+o.shift,o.positioning.y)local\
u=o.autoc.sorted[o.autoc.selected]if u then local\
c=o.input:match(\"%S+$\")or\"\"local m=u:gsub(\"^\"..c:gsub(\" $\",\"\"),\"\")if\
o.cursor_pos>=#o.input then local m=m:gsub(\"%%(.)\",\"%1\")local\
f=o.positioning.x+o.positioning.width+1 local w=o.cursor_x+o.shift+#m if w>f\
and not o.autoc.ignore_width then local y=w-f m=m:sub(1,#m-y)end\
i.blit(m,e.to_blit[o.autoc.fg]:rep(#m),e.to_blit[o.autoc.bg]:rep(#m))end end\
end\
end",
  [ "objects/frame/graphic" ] = "return\
function(e)e.on_graphic(e)end\
",
  [ "a-tools/update" ] = "local e=require(\"api\")_ENV=_ENV.ORIGINAL local\
t={[\"mouse_click\"]=true,[\"mouse_drag\"]=true,[\"monitor_touch\"]=true,[\"mouse_scroll\"]=true,[\"mouse_up\"]=true,[\"key\"]=true,[\"key_up\"]=true,[\"char\"]=true,[\"guih_data_event\"]=true,[\"paste\"]=true}local\
a={[\"key\"]=true,[\"key_up\"]=true,[\"char\"]=true,[\"paste\"]=true}local\
o={[1]=true,[2]=true}local\
i={[\"mouse_click\"]=true,[\"mouse_drag\"]=true,[\"mouse_up\"]=true,[\"mouse_scroll\"]=true}return\
function(n,s,h,r,d,l,u)if h==nil then h=true end local c=\"none\"local m=d local\
f=d local w=n.gui local y,p,v,b local g,k={},{}local q=true if((s or\
math.huge)>0)and not l then if not f or not r then local j=os.startTimer(s or\
0)if s==0 then os.queueEvent(\"mouse_click\",math.huge,-math.huge,-math.huge)end\
while not t[c]or(c==\"timer\"and y==j)do c,y,p,v,b=os.pullEvent()end if\
c==\"monitor_touch\"then m={name=c,monitor=y,x=p,y=v}end if c==\"mouse_click\"or\
c==\"mouse_up\"then m={name=c,button=y,x=p,y=v}end if c==\"mouse_drag\"then\
m={name=c,button=y,x=p,y=v}end if c==\"mouse_scroll\"then\
m={name=c,direction=y,x=p,y=v}end if c==\"key\"then\
m={name=c,key=y,held=p,x=math.huge,y=math.huge}end if c==\"key_up\"then\
m={name=c,key=y,x=math.huge,y=math.huge}end if c==\"paste\"then\
m={name=c,text=y,x=math.huge,y=math.huge}end if c==\"char\"then\
m={name=c,character=y,x=math.huge,y=math.huge}end if c==\"guih_data_event\"then\
m=y end if not m.monitor then m.monitor=\"term_object\"end if p~=n.id and\
c~=\"guih_data_event\"then os.queueEvent(\"guih_data_event\",m,n.id)else q=false\
end end local x={}if q and m.monitor==n.monitor and not u then for z,E in\
pairs(w)do for T,A in pairs(E)do if(A.reactive and A.react_to_events[m.name])or\
not next(A.react_to_events)then if not x[A.logic_order or A.order]then\
x[A.logic_order or A.order]={}end table.insert(x[A.logic_order or\
A.order],function()if a[m.name]then if A.logic then\
setfenv(A.logic,_ENV)(A,m,n)end else if((A.btn or o)[m.button])or\
m.monitor==n.monitor then if A.logic then setfenv(A.logic,_ENV)(A,m,n)end end\
end end)end end end end for O,I in e.tables.iterate_order(x)do\
parallel.waitForAll(unpack(I))end end local N,S=n.term_object.getCursorPos()if\
h and n.visible then for H,R in pairs(w)do for D,L in pairs(R)do if not\
k[L.graphic_order or L.order]then k[L.graphic_order or L.order]={}end\
table.insert(k[L.graphic_order or L.order],function()if not(L.gui or\
L.child)then if L.visible and L.graphic then setfenv(L.graphic,_ENV)(L,n)end\
else if L.visible and L.graphic then setfenv(L.graphic,_ENV)(L,n);(L.gui or\
L.child).term_object.redraw()end end end)end end end for U,C in\
e.tables.iterate_order(k)do parallel.waitForAll(table.unpack(C))end local\
M={}for F,W in pairs(w)do for Y,P in pairs(W)do if not M[P.graphic_order or\
P.order]then M[P.graphic_order or P.order]={}end table.insert(M[P.graphic_order\
or P.order],function()if P.gui or P.child then table.insert(g,P)end end)end end\
for V,B in e.tables.iterate_order(M)do for G,K in pairs(B)do K()end end if not\
q then return m,table.pack(c,y,p,v,b)end for Q,J in ipairs(g)do local\
X,Z=J.window.getPosition()local et,tt=J.window.getSize()local f=f or d or m if\
f then local\
at={x=(f.x-X)+1,y=(f.y-Z)+1,name=f.name,monitor=f.monitor,button=f.button,direction=f.direction,held=f.held,key=f.key,character=f.character,text=f.text}if\
J.gui and J.gui.cls then\
J.gui.term_object.setBackgroundColor(J.gui.background)J.gui.term_object.clear()end\
if e.is_within_field(f.x,f.y,X,Z,X+et,Z+tt)then(J.child or\
J.gui).update(math.huge,J.visible,true,at,not J.reactive,not J.visible)else\
at.x=-math.huge at.y=-math.huge;(J.child or\
J.gui).update(math.huge,J.visible,true,at,not J.reactive,not J.visible)end if\
J.gui and J.gui.cls then J.gui.term_object.redraw()end end end\
n.term_object.setCursorPos(N,S)return\
m,table.pack(c,y,p,v,b)end",
  [ "objects/script/graphic" ] = "return\
function(e,t)e.graphic(e,t)end\
",
  [ "presets/rect/window" ] = "return\
function(e,t)return{top_left={sym=\" \",bg=e,fg=t},top_right={sym=\" \",bg=e,fg=t},bottom_left={sym=\" \",bg=t,fg=e},bottom_right={sym=\" \",bg=t,fg=e},side_left={sym=\" \",bg=t,fg=e},side_right={sym=\" \",bg=t,fg=e},side_top={sym=\" \",bg=e,fg=t},side_bottom={sym=\" \",bg=t,fg=e},inside={sym=\" \",bg=t,fg=e},}end\
",
  [ "objects/button/graphic" ] = "local e=require(\"graphic_handle\").code return function(t)local\
a=t.canvas.term_object local o,i=t.positioning.x,t.positioning.y if not\
t.texture then\
a.setBackgroundColor(t.background_color)a.setTextColor(t.text_color)for\
n=i,t.positioning.height+i-1 do\
a.setCursorPos(o,n)a.write(t.symbol:rep(t.positioning.width))end else\
e.draw_box_tex(a,t.texture,o,i,t.positioning.width,t.positioning.height,t.background_color,t.text_color,nil,nil,t.canvas.texture_cache)end\
if t.text then\
t.text(a,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)end\
end",
  [ "presets/rect/framed_window" ] = "return\
function(e,t)return{top_left={sym=\" \",bg=e,fg=t},top_right={sym=\" \",bg=e,fg=t},bottom_left={sym=\"\\138\",bg=e,fg=t},bottom_right={sym=\"\\133\",bg=e,fg=t},side_left={sym=\"\\149\",bg=t,fg=e},side_right={sym=\"\\149\",bg=e,fg=t},side_top={sym=\" \",bg=e,fg=t},side_bottom={sym=\"\\143\",bg=e,fg=t},inside={sym=\" \",bg=t,fg=e}}end\
",
  [ "a-tools/gui_object" ] = "local e=require(\"object_loader\")local t=require(\"graphic_handle\")local\
a=require(\"a-tools.update\")local o=require(\"api\")_ENV=_ENV.ORIGINAL local\
function i(n,s,h,r,d)local l={}local u=\"term_object\"local c=s local function\
m(f)r,d=0,0 pcall(function()local function w(y)local\
p,v=y.getPosition()r=r+(p-1)d=d+(v-1)local\
b,g=debug.getupvalue(y.reposition,5)if g.reposition and g~=term.current()then\
c=g w(g)elseif g~=nil then c=g end end w(n)end)if f then f.event_offset_x=r\
f.event_offset_y=d end end if not r or not d then m()end\
pcall(function()u=peripheral.getType(c)end)for k,q in pairs(e.types)do\
l[q]={}end local j,x=n.getSize()local\
z={term_object=n,term=n,gui=l,update=a,visible=true,id=o.uuid4(),task_schedule={},update_delay=0.05,held_keys={},log=h,task_routine={},paused_task_routine={},w=j,h=x,width=j,height=x,event_listeners={},paused_listeners={},background=n.getBackgroundColor(),cls=false,key={},texture_cache={},debug=false,event_offset_x=r,event_offset_y=d,}z.inherit=function(E,T)z.api=E.api\
z.preset=E.preset z.async=E.async z.schedule=E.schedule\
z.add_listener=E.add_listener z.debug=E.debug z.parent=T end z.elements=z.gui\
z.calibrate=function()m(z)end z.getSize=function()return z.w,z.h end\
h(\"set up updater\",h.update)local function A(O,I,N,S,H,R)return\
a(z,O,I,N,S,H,R)end local D local L=false z.schedule=function(U,C,M,F)local\
W=o.uuid4()if F or z.debug then\
h(\"created new thread: \"..tostring(W),h.info)end local Y={}local\
P={c=coroutine.create(function()local V,B=pcall(function()if C then\
o.precise_sleep(C)end U(z,z.term_object)end)if not V then if M==true then D=B\
end Y.err=B if F or z.debug then\
h(\"error in thread: \"..tostring(W)..\"\\n\"..tostring(B),h.error)h:dump()end end\
end),dbug=F}z.task_routine[W]=P local function G(...)local\
K=z.task_routine[W]or z.paused_task_routine[W]if K then local\
Q,D=coroutine.resume(K.c,...)if not Q then Y.err=D if F or z.debug then\
h(\"task \"..tostring(W)..\" error: \"..tostring(D),h.error)h:dump()end end return\
true,Q,D else if F or z.debug then\
h(\"task \"..tostring(W)..\" not found\",h.error)h:dump()end return false end end\
return setmetatable(P,{__index={kill=function()z.task_routine[W]=nil\
z.paused_task_routine[W]=nil if F or z.debug then\
h(\"killed task: \"..tostring(W),h.info)h:dump()end return true\
end,alive=function()local J=z.task_routine[W]or z.paused_task_routine[W]if not\
J then return false end return\
coroutine.status(J.c)~=\"dead\"end,step=G,update=G,pause=function()local\
X=z.task_routine[W]or z.paused_task_routine[W]if X then\
z.paused_task_routine[W]=X z.task_routine[W]=nil if F or z.debug then\
h(\"paused task: \"..tostring(W),h.info)h:dump()end return true else if F or\
z.debug then h(\"task \"..tostring(W)..\" not found\",h.error)h:dump()end return\
false end end,resume=function()local Z=z.paused_task_routine[W]or\
z.task_routine[W]if Z then z.task_routine[W]=Z z.paused_task_routine[W]=nil if\
F or z.debug then h(\"resumed task: \"..tostring(W),h.info)h:dump()end return\
true else if F or z.debug then\
h(\"task \"..tostring(W)..\" not found\",h.error)h:dump()end return false end\
end,get_error=function()return Y.err end,set_running=function(et,F)local\
tt=z.task_routine[W]or z.paused_task_routine[W]local L=z.task_routine[W]~=nil\
if tt then if L and et then return true end if not L and not et then return\
true end if L and not et then z.paused_task_routine[W]=tt z.task_routine[W]=nil\
if F or z.debug then h(\"paused task: \"..tostring(W),h.info)h:dump()end return\
true end if not L and et then z.task_routine[W]=tt z.paused_task_routine[W]=nil\
if F or z.debug then h(\"resumed task: \"..tostring(W),h.info)h:dump()end return\
true end end end},__tostring=function()return\"GuiH.SCHEDULED_THREAD.\"..W\
end})end z.async=z.schedule z.add_listener=function(at,ot,it,nt)if not\
_G.type(ot)==\"function\"then return end if not(_G.type(at)==\"table\"or\
_G.type(at)==\"string\")then at={}end local st=it or o.uuid4()local\
ht={filter=at,code=ot}z.event_listeners[st]=ht if nt or z.debug then\
h(\"created event listener: \"..st,h.success)h:dump()end return\
setmetatable(ht,{__index={kill=function()z.event_listeners[st]=nil\
z.paused_listeners[st]=nil if nt or z.debug then\
h(\"killed event listener: \"..st,h.success)h:dump()end\
end,pause=function()z.paused_listeners[st]=ht z.event_listeners[st]=nil if nt\
or z.debug then h(\"paused event listener: \"..st,h.success)h:dump()end\
end,resume=function()local ht=z.paused_listeners[st]or z.event_listeners[st]if\
ht then z.event_listeners[st]=ht z.paused_listeners[st]=nil if nt or z.debug\
then h(\"resumed event listener: \"..st,h.success)h:dump()end elseif nt or\
z.debug then h(\"event listener not found: \"..st,h.error)h:dump()end\
end},__tostring=function()return\"GuiH.EVENT_LISTENER.\"..st end})end\
z.cause_exeption=function(rt)D=tostring(rt)end z.stop=function()L=false end\
z.kill=z.stop z.error=z.cause_exeption z.clear=function(dt)if dt or z.debug\
then h(\"clearing the gui..\",h.update)end local lt={}for ut,ct in\
pairs(e.types)do lt[ct]={}end z.gui=lt z.elements=lt local\
mt=e.main(z,lt,h)z.create=mt z.new=mt end z.isHeld=function(...)local\
ft={...}local wt,yt=true,true for pt,vt in pairs(ft)do local\
bt=z.held_keys[vt]or{}if bt[1]then wt=wt and true yt=yt and bt[2]else return\
false,false,z.held_keys end end return wt,yt,z.held_keys end\
z.key.held=z.isHeld\
z.execute=setmetatable({},{__call=function(gt,kt,qt,jt,xt)if L then\
h(\"Coulnt execute. Gui is already running\",h.error)h:dump()return false end\
D=nil L=true h(\"\")h(\"loading execute..\",h.update)local zt=z.term_object local\
Et local Tt=zt.getBackgroundColor()local At=coroutine.create(function()local\
Ot,It=pcall(function()zt.setVisible(true)A(0)zt.redraw()while true do\
zt.setVisible(false)zt.setBackgroundColor(z.background or Tt)zt.clear();(jt or\
function()end)(zt)local Et=a(z,nil,true,false,nil);(qt or\
function()end)(zt,Et);(xt or function()end)(zt)zt.setVisible(true);end end)if\
not Ot then D=It h:dump()end end)h(\"created graphic routine 1\",h.update)local\
Nt=kt or function()end local function St()local Ht,Rt=pcall(Nt,zt)if not Ht\
then D=Rt h:dump()end end h(\"created custom updater\",h.update)local\
Dt=coroutine.create(function()while true do\
zt.setVisible(false)zt.setBackgroundColor(z.background or\
Tt)zt.clear();z.update(0,true,nil,{type=\"mouse_click\",x=-math.huge,y=-math.huge,button=-math.huge});(xt\
or function()end)(zt)zt.setVisible(true)zt.setVisible(false)if\
z.update_delay<0.05 then os.queueEvent(\"waiting\")os.pullEvent()else\
sleep(z.update_delay)end end\
end)h(\"created event listener handle\",h.update)local\
Lt=coroutine.create(function()local Ut,Ct=pcall(function()while true do local\
Mt=table.pack(os.pullEventRaw())for Ft,Wt in pairs(z.event_listeners)do local\
Yt=Wt.filter if _G.type(Yt)==\"string\"then Yt={[Wt.filter]=true}end if\
Yt[Mt[1]]or Yt==Mt[1]or(not next(Yt))then\
Wt.code(table.unpack(Mt,_G.type(Wt.filter)~=\"table\"and 2 or 1,Mt.n))end end end\
end)if not Ut then D=Ct h:dump()end\
end)h(\"created graphic routine 2\",h.update)local\
Pt=coroutine.create(function()while true do local Vt,Bt,Gt=os.pullEvent()if\
Vt==\"key\"then z.held_keys[Bt]={true,Gt}end if Vt==\"key_up\"then\
z.held_keys[Bt]=nil end end end)h(\"created key handler\")local\
Kt=coroutine.create(St)coroutine.resume(Kt)coroutine.resume(At,\"mouse_click\",math.huge,-math.huge,-math.huge)coroutine.resume(At,\"mouse_click\",math.huge,-math.huge,-math.huge)coroutine.resume(At,\"mouse_click\",math.huge,-math.huge,-math.huge)h(\"\")h(\"Started execution..\",h.success)h(\"\")h:dump()while((coroutine.status(Kt)~=\"dead\"or\
not(_G.type(kt)==\"function\"))and coroutine.status(At)~=\"dead\"and D==nil)and L\
do local Et=table.pack(os.pullEventRaw())if o.events_with_cords[Et[1]]then\
Et[3]=Et[3]-(z.event_offset_x)Et[4]=Et[4]-(z.event_offset_y)end if\
Et[1]==\"terminate\"then D=\"Terminated\"break end if Et[1]~=\"guih_data_event\"then\
coroutine.resume(Lt,table.unpack(Et,1,Et.n))end\
coroutine.resume(Kt,table.unpack(Et,1,Et.n))if Et[1]==\"key\"or\
Et[1]==\"key_up\"then coroutine.resume(Pt,table.unpack(Et,1,Et.n))end for Qt,Jt\
in pairs(z.task_routine)do if coroutine.status(Jt.c)~=\"dead\"then if\
Jt.filter==Et[1]or Jt.filter==nil then local\
Xt,Zt=coroutine.resume(Jt.c,table.unpack(Et,1,Et.n))if Xt then Jt.filter=Zt end\
end else z.task_routine[Qt]=nil z.task_schedule[Qt]=nil if Jt.dbug then\
h(\"Finished sheduled task: \"..tostring(Qt),h.success)end end end\
coroutine.resume(At,table.unpack(Et,1,Et.n))coroutine.resume(Dt,table.unpack(Et,1,Et.n))local\
j,x=s.getSize()if j~=z.w or x~=z.h then if(Et[1]==\"monitor_resize\"and\
z.monitor==Et[2])or z.monitor==\"term_object\"then\
z.term_object.reposition(1,1,j,x)coroutine.resume(At,\"mouse_click\",math.huge,-math.huge,-math.huge)z.w,z.h=j,x\
z.width,z.height=j,x end end end if D then z.last_err=D end\
zt.setVisible(true)if D then\
h(\"a Fatal error occured: \"..D..debug.traceback(),h.fatal)else\
h(\"finished execution\",h.success)end h:dump()D=nil return z.last_err,true\
end,__tostring=function()return\"GuiH.main_gui_executor\"end})z.run=z.execute if\
u==\"monitor\"then\
h(\"Display object: monitor\",h.info)z.monitor=peripheral.getName(c)else\
h(\"Display object: term\",h.info)z.monitor=\"term_object\"end\
z.load_texture=function(ea)h(\"Loading nimg texture.. \",h.update)local\
ta=t.load_texture(ea)return ta end z.load_ppm_texture=function(aa,oa)local\
ia,na,sa=pcall(t.load_ppm_texture,z.term_object,aa,oa,h)if ia then return na,sa\
else h(\"Failed to load texture: \"..na,h.error)end end\
z.load_cimg_texture=function(ha)h(\"Loading cimg texture.. \",h.update)local\
ra=t.load_cimg_texture(ha)return ra end\
z.load_blbfor_texture=function(da)h(\"Loading blbfor texture.. \",h.update)local\
la,ua=t.load_blbfor_texture(da)return la,ua end\
z.load_limg_texture=function(ca,ma,fa)h(\"Loading limg texture.. \",h.update)local\
wa,ya=t.load_limg_texture(ca,ma,fa)return wa,ya end\
z.load_limg_animation=function(pa,va)h(\"Loading limg animation.. \",h.update)local\
ba=t.load_limg_animation(pa,va)return ba end\
z.load_blbfor_animation=function(ga)h(\"Loading blbfor animation.. \",h.update)local\
ka=t.load_blbfor_animation(ga)return ka end\
z.set_event_offset=function(qa,ja)z.event_offset_x,z.event_offset_y=qa or\
z.event_offset_x,ja or z.event_offset_y end\
h(\"\")h(\"Starting creator..\",h.info)local xa=e.main(z,z.gui,h)z.create=xa\
z.new=xa h(\"\")z.update=A\
h(\"loading text object...\",h.update)h(\"\")z.get_blit=function(za,Ea,Ta)local Aa\
pcall(function()Aa={z.term_object.getLine(za)}end)if not Aa then return false\
end return Aa[1]:sub(Ea,Ta),Aa[2]:sub(Ea,Ta),Aa[3]:sub(Ea,Ta)end\
z.text=function(Oa)Oa=Oa or{}if _G.type(Oa.centered)~=\"boolean\"then\
Oa.centered=false end local\
Ia=(_G.type(Oa.text)==\"string\")and(\"0\"):rep(#Oa.text)or(\"0\"):rep(13)local\
Na=(_G.type(Oa.text)==\"string\")and(\"f\"):rep(#Oa.text)or(\"f\"):rep(13)if\
_G.type(Oa.blit)~=\"table\"then Oa.blit={Ia,Na}end Oa.blit[1]=(Oa.blit[1]or\
Ia):lower()Oa.blit[2]=(Oa.blit[2]or\
Na):lower()h(\"created new text object\",h.info)return setmetatable({text=Oa.text\
or\"<TEXT OBJECT>\",centered=Oa.centered,x=Oa.x or 1,y=Oa.y or\
1,offset_x=Oa.offset_x or 0,offset_y=Oa.offset_y or 0,blit=Oa.blit\
or{Ia,Na},transparent=Oa.transparent,bg=Oa.bg,fg=Oa.fg,width=Oa.width,height=Oa.height},{__call=function(Sa,Ha,Ra,Da,j,x)Ra,Da=Ra\
or Sa.x,Da or Sa.y if Sa.width then j=Sa.width end if Sa.height then\
x=Sa.height end local La=Ha or z.term_object local Ua if\
_G.type(Ra)==\"number\"and _G.type(Da)==\"number\"then Ua=1 end if\
_G.type(Ra)~=\"number\"then Ra=1 end if _G.type(Da)~=\"number\"then Da=1 end local\
Ca,Ma=Ra,Da local Fa={}for Wa in Sa.text:gmatch(\"[^\\n]+\")do\
table.insert(Fa,Wa)end if Sa.centered then Ma=Ma-#Fa/2 else Ma=Ma-1 end for\
Ya=1,#Fa do local Pa=Fa[Ya]Ma=Ma+1 if Sa.centered then local Va=(x or\
z.h)/2-0.5 local Ba=math.ceil(((j or\
z.w)/2)-(#Pa/2)-0.5)La.setCursorPos(Ba+Sa.offset_x+Ca,Va+Sa.offset_y+Ma)Ra,Da=Ba+Sa.offset_x+Ca,Va+Sa.offset_y+Ma\
else La.setCursorPos((Ua or Sa.x)+Sa.offset_x+Ca-1,(Ua or\
Sa.y)+Sa.offset_y+Ma-1)Ra,Da=(Ua or Sa.x)+Sa.offset_x+Ca-1,(Ua or\
Sa.y)+Sa.offset_y+Ma-1 end if Sa.transparent==true then local Ga=-1 if Ra<1\
then Ga=math.abs(math.min(Ra+1,3)-2)La.setCursorPos(1,Da)Ra=1\
Pa=Pa:sub(Ga+1)end local Ia,Na=table.unpack(Sa.blit)if Sa.bg then\
Na=t.code.to_blit[Sa.bg]:rep(#Pa)end if Sa.fg then\
Ia=t.code.to_blit[Sa.fg]:rep(#Pa)end local Ka\
pcall(function()_,_,Ka=La.getLine(math.floor(Da))end)if not Ka then return end\
local Qa=Ka:sub(Ra,math.min(Ra+#Pa-1,z.w))local Ja=#Pa-#Qa-1 if#Ia~=#Pa then\
Ia=(\"0\"):rep(#Pa)end\
pcall(La.blit,Pa,Ia:sub(math.min(Ra,1)),Qa..Na:sub(#Na-Ja,#Na))else local\
Ia,Na=table.unpack(Sa.blit)if Sa.bg then Na=t.code.to_blit[Sa.bg]:rep(#Pa)end\
if Sa.fg then Ia=t.code.to_blit[Sa.fg]:rep(#Pa)end if#Ia~=#Pa then\
Ia=(\"0\"):rep(#Pa)end if#Na~=#Pa then Na=(\"f\"):rep(#Pa)end\
pcall(La.blit,Pa,Ia,Na)end end\
end,__tostring=function()return\"GuiH.primitive.text\"end})end return z end\
return\
i",
  [ "presets/rect/frame_thick" ] = "return\
function(e,t)return{top_left={sym=\" \",bg=e,fg=t},top_right={sym=\" \",bg=e,fg=t},bottom_left={sym=\" \",bg=e,fg=t},bottom_right={sym=\" \",bg=e,fg=t},side_left={sym=\" \",bg=e,fg=t},side_right={sym=\" \",bg=e,fg=t},side_top={sym=\" \",bg=e,fg=t},side_bottom={sym=\" \",bg=e,fg=t},inside={sym=\" \",bg=t,fg=t},}end\
",
  [ "a-tools/algo" ] = "local e=require(\"api\")_ENV=_ENV.ORIGINAL local function t(a,o,i,n,s)local\
h,r=math.ceil(math.floor(a-0.5)/2),math.ceil(math.floor(o-0.5)/2)local d,l=0,r\
local u=((r*r)-(h*h*r)+(0.25*h*h))local c=2*r^2*d local m=2*h^2*l local\
f={}while c<m do\
table.insert(f,{x=d+i,y=l+n})table.insert(f,{x=-d+i,y=l+n})table.insert(f,{x=d+i,y=-l+n})table.insert(f,{x=-d+i,y=-l+n})if\
s then for l=-l+n+1,l+n-1 do\
table.insert(f,{x=d+i,y=l})table.insert(f,{x=-d+i,y=l})end end if u<0 then\
d=d+1 c=c+2*r^2 u=u+c+r^2 else d,l=d+1,l-1 c=c+2*r^2 m=m-2*h^2 u=u+c-m+r^2 end\
end local w=(((r*r)*((d+0.5)*(d+0.5)))+((h*h)*((l-1)*(l-1)))-(h*h*r*r))while\
l>=0 do\
table.insert(f,{x=d+i,y=l+n})table.insert(f,{x=-d+i,y=l+n})table.insert(f,{x=d+i,y=-l+n})table.insert(f,{x=-d+i,y=-l+n})if\
s then for l=-l+n,l+n do\
table.insert(f,{x=d+i,y=l})table.insert(f,{x=-d+i,y=l})end end if w>0 then\
l=l-1 m=m-2*h^2 w=w+h^2-m else l=l-1 d=d+1 m=m-2*h^2 c=c+2*r^2 w=w+c-m+h^2 end\
end return f end local function y(p,v,b,g)local k=(g.x-v.x)/(g.y-v.y)local\
q=(g.x-b.x)/(g.y-b.y)local j=math.ceil(v.y-0.5)local x=math.ceil(g.y-0.5)-1 for\
z=j,x do local E=k*(z+0.5-v.y)+v.x local T=q*(z+0.5-b.y)+b.x local\
A=math.ceil(E-0.5)local O=math.ceil(T-0.5)for I=A,O do\
table.insert(p,{x=I,y=z})end end end local function N(S,H,R,D)local\
L=(R.x-H.x)/(R.y-H.y)local U=(D.x-H.x)/(D.y-H.y)local C=math.ceil(H.y-0.5)local\
M=math.ceil(D.y-0.5)-1 for F=C,M do local W=L*(F+0.5-H.y)+H.x local\
Y=U*(F+0.5-H.y)+H.x local P=math.ceil(W-0.5)local V=math.ceil(Y-0.5)for B=P,V\
do table.insert(S,{x=B,y=F})end end end local function G(K,Q,J)local X={}if\
Q.y<K.y then K,Q=Q,K end if J.y<Q.y then Q,J=J,Q end if Q.y<K.y then K,Q=Q,K\
end if K.y==Q.y then if Q.x<K.x then K,Q=Q,K end y(X,K,Q,J)elseif Q.y==J.y then\
if J.x<Q.x then J,Q=Q,J end N(X,K,Q,J)else local Z=(Q.y-K.y)/(J.y-K.y)local\
et={x=K.x+((J.x-K.x)*Z),y=K.y+((J.y-K.y)*Z),}if Q.x<et.x then\
N(X,K,Q,et)y(X,Q,et,J)else N(X,K,et,Q)y(X,et,Q,J)end end return X end local\
function tt(at,ot,it,nt)local st={}for at=at,at+it do for ot=ot,ot+nt do\
table.insert(st,{x=at,y=ot})end end end local function ht(rt,dt,lt,ut)local\
ct={}rt,dt,lt,ut=math.floor(rt),math.floor(dt),math.floor(lt),math.floor(ut)if\
rt==lt and dt==ut then return{x=rt,y=dt}end local mt=math.min(rt,lt)local\
ft,wt,yt if mt==rt then wt,ft,yt=dt,lt,ut else wt,ft,yt=ut,rt,dt end local\
pt,vt=ft-mt,yt-wt if pt>math.abs(vt)then local bt=wt local gt=vt/pt for\
kt=mt,ft do table.insert(ct,{x=kt,y=math.floor(bt+0.5)})bt=bt+gt end else local\
qt,jt=mt,pt/vt if yt>=wt then for xt=wt,yt do\
table.insert(ct,{x=math.floor(qt+0.5),y=xt})qt=qt+jt end else for zt=wt,yt,-1\
do table.insert(ct,{x=math.floor(qt+0.5),y=zt})qt=qt-jt end end end return ct\
end local function Et(Tt,At,Ot)local It={}local Nt=ht(Tt.x,Tt.y,At.x,At.y)local\
St=ht(At.x,At.y,Ot.x,Ot.y)local Ht=ht(Ot.x,Ot.y,Tt.x,Tt.y)return\
e.tables.merge(Nt,St,Ht)end\
return{get_elipse_points=t,get_triangle_points=G,get_triangle_outline_points=Et,get_line_points=ht}",
  [ "objects/script/object" ] = "local e=require(\"api\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end local o={name=a.name or\
e.uuid4(),visible=a.visible,reactive=a.reactive,code=a.code or function()return\
false end,graphic=a.graphic or function()return false end,order=a.order or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,react_to_events={mouse_click=true,mouse_drag=true,monitor_touch=true,mouse_scroll=true,mouse_up=true,key=true,key_up=true,char=true,paste=true}}return\
o\
end",
  [ "objects/progressbar/logic" ] = "return\
function(e)end\
",
  [ "presets/rect/border" ] = "return\
function(e,t)return{top_left={sym=\"\\159\",fg=t,bg=e},top_right={sym=\"\\144\",fg=e,bg=t},bottom_left={sym=\"\\130\",fg=e,bg=t},bottom_right={sym=\"\\129\",fg=e,bg=t},side_left={sym=\"\\149\",fg=t,bg=e},side_right={sym=\"\\149\",fg=e,bg=t},side_top={sym=\"\\143\",fg=t,bg=e},side_bottom={sym=\"\\131\",fg=e,bg=t},inside={sym=\" \",bg=t,fg=e},}end\
",
  [ "objects/frame/object" ] = "local e=require(\"api\")local t=require(\"a-tools.gui_object\")return\
function(a,o)o=o or{}if type(o.clear)~=\"boolean\"then o.clear=true end if\
type(o.draggable)~=\"boolean\"then o.draggable=true end if\
type(o.visible)~=\"boolean\"then o.visible=true end if\
type(o.reactive)~=\"boolean\"then o.reactive=true end local i={name=o.name or\
e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or 0,height=o.height\
or\
0},visible=o.visible,reactive=o.reactive,react_to_events={mouse_drag=true,mouse_click=true,mouse_up=true},dragged=false,dragger=o.dragger,last_click={x=1,y=1},order=o.order\
or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,btn=o.btn,dragable=o.draggable,on_move=o.on_move\
or function()end,on_select=o.on_select or function()end,on_any=o.on_any or\
function()end,on_graphic=o.on_graphic or\
function()end,on_deselect=o.on_deselect or function()end}local\
n=window.create(a.term_object,i.positioning.x,i.positioning.y,i.positioning.width,i.positioning.height)if\
not i.dragger then i.dragger={x=1,y=1,width=i.positioning.width,height=1}end\
i.child=t(n,a.term_object,a.log)i.window=n i.child.inherit(a,i)return i\
end",
  [ "objects/button/logic" ] = "local e=require(\"api\")return function(t,a)if\
e.is_within_field(a.x,a.y,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)then\
t.on_click(t,a)end\
end",
  [ "objects/switch/object" ] = "local e=require(\"api\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end local o={name=a.name or\
e.uuid4(),positioning={x=a.x or 1,y=a.y or 1,width=a.width or 0,height=a.height\
or 0},on_change_state=a.on_change_state or\
function()end,background_color=a.background_color or\
t.term_object.getBackgroundColor(),background_color_on=a.background_color_on or\
t.term_object.getBackgroundColor(),text_color=a.text_color or\
t.term_object.getTextColor(),text_color_on=a.text_color_on or\
t.term_object.getTextColor(),symbol=a.symbol\
or\" \",texture=a.tex,texture_on=a.tex_on,text=a.text,text_on=a.text_on,visible=a.visible,reactive=a.reactive,react_to_events={mouse_click=true,monitor_touch=true},btn=a.btn,order=a.order\
or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,tags={},value=(a.value~=nil)and\
a.value or false}return o\
end",
  [ "objects/ellipse/logic" ] = "return\
function()end\
",
  api = "_ENV=_ENV.ORIGINAL local function e(t,a,o,i,n,s)return t>=o and t<o+n and a>=i\
and a<i+s end local h=function(r,d,l)if d==0 then return l,l,l end local\
u=math.floor(r/60)local c=(r/60)-u local m=l*(1-d)local f=l*(1-d*c)local\
w=l*(1-d*(1-c))if u==0 then return l,w,m elseif u==1 then return f,l,m elseif\
u==2 then return m,l,w elseif u==3 then return m,f,l elseif u==4 then return\
w,m,l elseif u==5 then return l,m,f end end local function y(p,v)v=v or{}if\
p==0 then return v end setmetatable(v,{__index=function(b,g)local\
k=y(p-1)b[g]=k return k end})return v end local q=function(j)return\
setmetatable(j or{},{__index=function(x,z)local E={}x[z]=E return E end})end\
local T=function(A)return setmetatable(A or{},{__index=function(O,I)local\
N=q()O[I]=N return N end})end local function S(...)local H={}for R,D in\
pairs({...})do for L,U in pairs(D)do table.insert(H,U)end end return H end\
local function C(M,F,W)local Y=W-M.y local P=F.y-M.y local\
V=M.x+(Y*(F.x-M.x))/P local B=M.z+(Y*(F.z-M.z))/P return V,B end local function\
G(K,Q,J)local X=K.z+(J-K.x)*(((Q.z-K.z)/(Q.x-K.x)))return X end local function\
Z(et,tt,at,ot,it,nt,st,ht)local rt=(ot-st)/(ot-et)*at+(st-et)/(ot-et)*nt\
return(it-ht)/(it-tt)*rt+(ht-tt)/(it-tt)*rt end local function dt(lt)local\
ut=createSelfIndexArray()for ct,mt in pairs(lt)do if type(mt)==\"table\"then for\
ft,wt in pairs(mt)do ut[ft][ct]=wt end end end return ut end local\
yt=function(pt)local vt=0 for bt,gt in pairs(pt)do vt=vt+1 end return vt,#pt\
end local kt=function(qt,jt)local xt=true local zt=yt(qt)local Et=yt(jt)for\
Tt,At in pairs(qt)do if At~=jt[Tt]then xt=false end end if xt and zt==Et then\
return true end end local function Ot(It)local Ot={}for Nt,St in pairs(It)do\
table.insert(Ot,Nt)end return Ot end local function Ht(Rt)local Dt=0 local\
Ot=Ot(Rt)table.sort(Ot,function(Lt,Ut)return Lt<Ut end)return function()Dt=Dt+1\
if Rt[Ot[Dt]]then return Ot[Dt],Rt[Ot[Dt]]else return end end end local\
function Ct()local Mt=math.random local\
Ft='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'return\
string.gsub(Ft,'[xy]',function(Wt)return string.format('%x',Wt=='x'and\
Mt(0,0xf)or Mt(8,0xb))end)end local function Yt(Pt)local\
Vt=os.epoch(\"utc\")+Pt*1000 while os.epoch(\"utc\")<Vt do\
os.queueEvent(\"waiting\")os.pullEvent()end end local function Bt(Gt)local\
Kt={}Gt:gsub(\".\",function(Qt)table.insert(Kt,Qt)end)return Kt end local\
function Jt(Xt)local Zt={}for ea=1,Xt do Zt[ea]={\"\",\"\",\"\"}end return Zt end\
local\
ta={monitor_touch=true,mouse_click=true,mouse_drag=true,mouse_scroll=true,mouse_up=true}return{is_within_field=e,tables={createNDarray=y,get_true_table_len=yt,compare_table=kt,switchXYArray=dt,create2Darray=q,create3Darray=T,iterate_order=Ht,merge=S},math={interpolateY=C,interpolateZ=G,interpolate_on_line=Z},HSVToRGB=h,uuid4=Ct,precise_sleep=Yt,piece_string=Bt,create_blit_array=Jt,events_with_cords=ta}",
  [ "objects/script/logic" ] = "return\
function(e,t)e.code(e,t)end\
",
  [ "apis/fuzzy_find" ] = "_ENV=_ENV.ORIGINAL local e=require(\"cc.pretty\")local function t(a,o)local\
i=100/math.max(#a,#o)local n=string.len(a)local s=string.len(o)local h={}for\
r=0,n do h[r]={}h[r][0]=r end for d=0,s do h[0][d]=d end for l=1,n do for u=1,s\
do local c=0 if string.sub(a,l,l)~=string.sub(o,u,u)then c=1 end\
h[l][u]=math.min(h[l-1][u]+1,h[l][u-1]+1,h[l-1][u-1]+c)end end return\
100-h[n][s]*i end local function m(f,w)local y,p={},{}for v,b in pairs(f)do\
table.insert(y,{t(v,w),v,b})end table.sort(y,function(g,k)return\
g[1]>k[1]end)for q,j in ipairs(y)do p[q]={match=j[1],str=j[2],data=j[3]}end\
return p end\
return{fuzzy_match=t,sort_strings=m,}",
  [ "objects/text/graphic" ] = "return function(e)if e.text then e:update(e.text)e.text()end\
end\
",
  [ "a-tools/blbfor" ] = "local e=require(\"cc.expect\").expect _ENV=_ENV.ORIGINAL local t=0x0A local\
a=0x30 local o={INTERNAL={STRING={}}}local i={}local n={}function\
o.INTERNAL.STRING.FORMAT_BLIT(s)return(\"%x\"):format(s)end function\
o.INTERNAL.STRING.TO_BLIT(h,r)local d=(not\
r)and(o.INTERNAL.STRING.FORMAT_BLIT(select(2,math.frexp(h))-1))or(select(2,math.frexp(h))-1)return\
d end function o.INTERNAL.STRING.FROM_HEX(l)return tonumber(l,16)end function\
o.INTERNAL.READ_BYTES_STREAM(u,c,m)local f={}u.seek(\"set\",c)for w=c,c+m-1 do\
local y=u.read()table.insert(f,y)end return table.unpack(f)end function\
o.INTERNAL.STRING_TO_BYTES(p)local v={}for b=1,#p do v[b]=p:byte(b)end return\
table.unpack(v)end function o.INTERNAL.WRITE_BYTES_STREAM(g,k,...)local\
q={...}for j=1,#q do g.seek(\"set\",k+j-1)g.write(q[j])end end function\
o.INTERNAL.READ_STRING_UNTIL_SEP(x,z)local E=\"\"x.seek(\"set\",z)local\
T=x.read()if not T then return false end while T~=t do\
E=E..string.char(T)T=x.read()end return E end function\
o.INTERNAL.READ_INT(A,O)local I=0 A.seek(\"set\",O)local N=A.read()while N~=t do\
I=I*10+(N-a)N=A.read()end return I end function\
o.INTERNAL.COLORS_TO_BYTE(S,H)local R=select(2,math.frexp(S))-1 local\
D=select(2,math.frexp(H))-1 return R*16+D end function\
o.INTERNAL.BYTE_TO_COLORS(L)return\
bit32.rshift(bit32.band(0xF0,L),4),bit32.band(0x0F,L)end function\
o.INTERNAL.WRITE_HEADER(U)U.stream.seek(\"set\",0)local\
C=textutils.serialiseJSON(U.meta):gsub(\"\\n\",\"NEWLINE\")o.INTERNAL.WRITE_BYTES_STREAM(U.stream,0,o.INTERNAL.STRING_TO_BYTES((\"BLBFOR1\\n%d\\n%d\\n%d\\n%d\\n%s\\n\"):format(U.width,U.height,U.layers,os.epoch(\"utc\"),C)))end\
function o.INTERNAL.ASSERT(M,F)if not M then error(F,3)else return M end end\
function o.INTERNAL.createNDarray(W,Y)Y=Y or{}if W==0 then return Y end\
setmetatable(Y,{__index=function(P,V)local\
B=o.INTERNAL.createNDarray(W-1)P[V]=B return B end})return Y end function\
o.INTERNAL.ENCODE(G)o.INTERNAL.WRITE_HEADER(G)for K,Q in ipairs(G.data)do for\
J,X in ipairs(Q)do local Z={}for et,tt in ipairs(X)do\
table.insert(Z,tt[1])table.insert(Z,o.INTERNAL.COLORS_TO_BYTE(2^tt[2],2^tt[3]))end\
o.INTERNAL.WRITE_BYTES_STREAM(G.stream,G.stream.seek(\"cur\"),table.unpack(Z))end\
end end function o.INTERNAL.DECODE(at)at.stream.seek(\"set\",0)local\
ot=o.INTERNAL.READ_STRING_UNTIL_SEP(at.stream,0)local\
it=o.INTERNAL.createNDarray(2)o.INTERNAL.ASSERT(ot==\"BLBFOR1\",\"Invalid header\",2)local\
nt=o.INTERNAL.READ_INT(at.stream,at.stream.seek(\"cur\"))local\
st=o.INTERNAL.READ_INT(at.stream,at.stream.seek(\"cur\"))local\
ht=o.INTERNAL.READ_INT(at.stream,at.stream.seek(\"cur\"))local\
rt=o.INTERNAL.READ_INT(at.stream,at.stream.seek(\"cur\"))local\
dt=textutils.unserializeJSON(o.INTERNAL.READ_STRING_UNTIL_SEP(at.stream,at.stream.seek(\"cur\")))at.width=nt\
at.height=st at.layers=ht at.meta=dt at.last_flushed=rt\
at.data=o.INTERNAL.createNDarray(3,at.data)for lt=1,at.layers do for ut=1,st do\
if not next(it[lt][ut])then it[lt][ut]={\"\",\"\",\"\"}end local ct={}for mt=1,nt do\
local ft={}local\
wt,yt=o.INTERNAL.READ_BYTES_STREAM(at.stream,at.stream.seek(\"cur\"),2)ft[1]=wt\
ft[2],ft[3]=o.INTERNAL.BYTE_TO_COLORS(yt)ct[mt]=ft\
it[lt][ut]={it[lt][ut][1]..string.char(ft[1]),it[lt][ut][2]..o.INTERNAL.STRING.FORMAT_BLIT(ft[2]),it[lt][ut][3]..o.INTERNAL.STRING.FORMAT_BLIT(ft[3])}end\
at.data[lt][ut]=ct end end at.lines=it end function\
i:set_pixel(pt,vt,bt,gt,kt,qt)o.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o.INTERNAL.ASSERT(not\
self.closed,\"Image handle closed\")e(1,pt,\"number\")e(2,vt,\"number\")e(3,bt,\"number\")e(4,gt,\"string\")e(5,kt,\"number\")e(6,qt,\"number\")o.INTERNAL.ASSERT(not(vt<1\
or bt<1 or vt>self.width or\
bt>self.height),\"pixel out of range\")self.data[pt][bt][vt]={gt:byte(),o.INTERNAL.STRING.TO_BLIT(kt,true),o.INTERNAL.STRING.TO_BLIT(qt,true)}end\
function\
n:get_pixel(jt,xt,zt,Et)o.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")e(1,jt,\"number\")e(2,xt,\"number\")e(3,zt,\"number\")e(4,Et,\"boolean\",\"nil\")o.INTERNAL.ASSERT(not(xt<1\
or zt<1 or xt>self.width or zt>self.height),\"pixel out of range\")local\
Tt=self.data[jt][zt][xt]local At={string.char(Tt[1]),2^Tt[2],2^Tt[3]}local\
Ot={string.char(Tt[1]),o.INTERNAL.STRING.FORMAT_BLIT(Tt[2]),o.INTERNAL.STRING.FORMAT_BLIT(Tt[3])}return\
table.unpack(Et and Ot or At)end function\
n:get_line(It,Nt)o.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")e(1,It,\"number\")e(2,Nt,\"number\")o.INTERNAL.ASSERT(not(Nt<1\
or Nt>self.height),\"line out of range\")return\
self.lines[It][Nt][1],self.lines[It][Nt][2],self.lines[It][Nt][3]end function\
i:set_line(St,Ht,Rt,Dt,Lt)o.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o.INTERNAL.ASSERT(not\
self.closed,\"Image handle closed\")e(1,St,\"number\")e(2,Ht,\"number\")e(3,Rt,\"string\")e(4,Dt,\"string\")e(5,Lt,\"string\")o.INTERNAL.ASSERT(#Dt==#Rt\
and#Lt==#Rt,\"line length mismatch\")o.INTERNAL.ASSERT(#Rt<=self.width,\"line too long\")o.INTERNAL.ASSERT(Ht<=self.height\
and Ht>0,\"line out of range\")for Ut=1,#Rt do\
self:set_pixel(St,Ut,Ht,Rt:sub(Ut,Ut),2^o.INTERNAL.STRING.FROM_HEX(Dt:sub(Ut,Ut)),2^o.INTERNAL.STRING.FROM_HEX(Lt:sub(Ut,Ut)))end\
end function\
i:close()o.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o.INTERNAL.ASSERT(not\
self.closed,\"Image handle closed\")o.INTERNAL.ENCODE(self)self.stream.close()self.closed=true\
end function\
i:flush()o.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o.INTERNAL.ASSERT(not\
self.closed,\"Image handle closed\")o.INTERNAL.ENCODE(self)self.stream.flush()end\
i.write_pixel=i.set_pixel i.write_line=i.set_line n.read_pixel=n.get_pixel\
n.read_line=n.get_line function\
o.open(Ct,Mt,Ft,Wt,Yt,Pt,Vt,Bt,Gt)e(1,Ct,\"string\")e(2,Mt,\"string\")local\
Kt=Ct:match(\"%.%a+$\")o.INTERNAL.ASSERT(Kt==\".bbf\",\"file must be a .bbf file\")local\
Qt={}if Mt:sub(1,1):lower()==\"w\"then\
e(3,Ft,\"number\")e(4,Wt,\"number\")e(5,Yt,\"number\",\"nil\")e(6,Pt,\"string\",\"nil\")e(7,Vt,\"string\",\"nil\")e(8,Bt,\"string\",\"nil\")e(9,Gt,\"table\",\"nil\")Yt=Yt\
or 1 local Jt=fs.open(Ct,\"wb\")if not Jt then error(\"Could not open file\",2)end\
Qt.meta=Gt or{}Qt.width=Ft Qt.height=Wt Qt.layers=Yt\
Qt.data=o.INTERNAL.createNDarray(3)Qt.stream=Jt for Xt=1,Yt do for Zt=1,Ft do\
for ea=1,Wt do Qt.data[Xt][ea][Zt]={(Bt or\
string.char(0)):byte(),o.INTERNAL.STRING.TO_BLIT(Pt or\
colors.black,true),o.INTERNAL.STRING.TO_BLIT(Vt or colors.black,true)}end end\
end return setmetatable(Qt,{__index=i})elseif Mt:sub(1,1):lower()==\"r\"then\
local ta=fs.open(Ct,\"rb\")if not ta then error(\"Could not open file\",2)end local\
aa=ta.seek(\"cur\")Qt.raw=ta.readAll()ta.seek(\"set\",aa)Qt.stream=ta\
o.INTERNAL.DECODE(Qt)Qt.closed=true ta.close()return\
setmetatable(Qt,{__index=n})else\
stream.close()error(\"invalid mode. please use \\\"w\\\" or \\\"r\\\" (Write/Read)\",2)end\
end return\
o",
  [ "apis/log" ] = "_ENV=_ENV.ORIGINAL local\
e={{colors.red},{colors.yellow},{colors.white,colors.red},{colors.white,colors.lime},{colors.white,colors.lime},{colors.white},{colors.green},{colors.gray},}local\
t={error=1,warn=2,fatal=3,success=4,message=6,update=7,info=8}local a={}for o,i\
in pairs(t)do a[i]=o end local function n(s)local\
s=s:gsub(\"^%[%d-%:%d-% %a-]\",\"\")return s end local function h(r,d,l,u)local\
c,m=r.getSize()local f,w={},math.ceil(#d/c)local y=0 for p=1,w do local\
v,b=r.getCursorPos()if b>m then r.scroll(1)r.setCursorPos(1,b-1)b=b-1 end\
r.write(d:sub(y+1,p*c))r.setCursorPos(1,b+1)y=p*c end return w end local\
function g(k,q)local j=k.getSize()local x,z={},math.ceil(#q/j)local E=0 local T\
for A=1,z do local O=q:sub(E+1,A*j)E=A*j T=#O end return T end function\
t:dump(I)local N=\"\"local S=1 local H={}local R=\"\"for D,L in\
ipairs(self.history)do if N==n(L.str)..L.type then S=S+1 table.remove(H,#H)else\
S=1 end\
H[#H+1]=L.str..\"(\"..tostring(S)..\") type: \"..(a[L.type]or\"info\")N=n(L.str)..L.type\
end for U,C in ipairs(H)do R=R..C..\"\\n\"end if type(I)==\"string\"then local\
M=fs.open(I..\".log\",\"w\")M.write(R)M.close()end return R end local function\
F(W,Y,P)local V,B=W.term.getSize()local G,K=W.term.getCursorPos()local\
Y=tostring(Y)P=P or\"info\"if W.lastLog==Y..P then W.nstr=W.nstr+1 local\
Q=K-W.maxln W.term.setCursorPos(G,Q)else W.nstr=1 end W.lastLog=Y..P local\
J=\"[\"..textutils.formatTime(os.time())..\"] \"local\
X,Z=W.term.getBackgroundColor(),W.term.getTextColor()local\
et,tt=unpack(e[P]or{})W.term.setBackgroundColor(tt or X);W.term.setTextColor(et\
or colors.gray)local at=J..Y..\"(\"..tostring(W.nstr)..\")\"local ot=#at if ot<1\
then ot=1 end local it=V-ot if it<1 then it=1 end it=V-(g(W.term,at))local\
nt=J..Y..(\" \"):rep(it)table.insert(W.history,{str=nt,type=P})W.maxln=h(W.term,nt..\"(\"..tostring(W.nstr)..\")\",X,W.title)local\
G,K=W.term.getCursorPos()W.term.setBackgroundColor(W.sbg);W.term.setTextColor(W.sfg)if\
W.title then\
W.term.setCursorPos(1,1)W.term.write((W.tsym):rep(V))W.term.setCursorPos(math.ceil((V/2)-(#W.title/2)),1)W.term.write(W.title)W.term.setCursorPos(G,K)end\
W.term.setBackgroundColor(X);W.term.setTextColor(Z)end local function\
st(ht,rt,dt,lt,ut)dt=dt or\"-\"local ct,mt=ht.getSize()local\
ft=setmetatable({lastLog=\"\",nstr=1,maxln=1,term=ht,history={},title=rt,tsym=(#dt<4)and\
dt\
or\"-\",sbg=ht.getBackgroundColor(),sfg=ht.getTextColor(),auto_dump=lt},{__index=t,__call=F})if\
ft.title then\
ft.term.setCursorPos(1,1)ft.term.write((ft.tsym):rep(ct))ft.term.setCursorPos(math.ceil((ct/2)-(#ft.title/2)),1)ft.term.write(ft.title)ft.term.setCursorPos(1,2)end\
ft.lastLog=nil return ft end\
return{create_log=st}",
  [ "objects/inputbox/logic" ] = "local e=require(\"api\")local function t(a)return\
a:gsub(\"[%[%]%(%)%.%+%-%%%$%^%*%?]\",\"%%%1\")end local function o(i,n,s)local o=0\
local h=string.len(i)local r=string.len(n)local d=math.min(h,r)if i==n then\
return 0 end if h==0 and s then return 0.4 end for l=1,d do if\
i:sub(l,l)==n:sub(l,l)then o=o+1 end end return o end local function u(c)local\
m={}for f,w in pairs(c)do m[#m+1]={key=f,value=w}end return m end local\
function y(p,v)local b={}local g={}local k=v.show_default local q={}for j,x in\
ipairs(v)do local o=o(p,x,k)if o>0 and type(j)==\"number\"then if b[o]then\
table.insert(b[o],x)else b[o]={x}end else table.insert(q,x)end end local\
z=u(b)table.sort(z,function(E,T)return E.key>T.key end)for A,O in ipairs(z)do\
for I,N in ipairs(O.value)do table.insert(g,N)end end local S=table.getn(g)for\
H,R in pairs(q)do g[1+S+H]=R end return g end return function(D,L)local\
U=D.canvas.term_object if L.name==\"mouse_click\"then if\
e.is_within_field(L.x,L.y,D.positioning.x,D.positioning.y,D.positioning.width+1,1)then\
if D.selected then\
D.cursor_pos=math.min(D.cursor_pos+(L.x-D.cursor_x),#D.input)else\
D.cursor_pos=D.old_cursor or 0 D.on_change_select(D,L,true)end D.selected=true\
else if D.selected then D.on_change_select(D,L,false)D.old_cursor=D.cursor_pos\
D.cursor_pos=-math.huge end D.selected=false end end local\
C=D.input:sub(1,D.cursor_pos)local M=D.input:sub(D.cursor_pos+1,#D.input)if\
next(D.autoc.strings)or next(D.autoc.spec_strings)and D.selected then local\
F=t(C):match(\"%S+$\")or\"\"local F=F:gsub(\"%%(.)\",\"%1\")local\
W=D.autoc.spec_strings[select(2,C:gsub(\"%W+\",\"\"))+1]or D.autoc.strings if W\
then local Y=y(F,W)D.autoc.sorted=Y if D.autoc.selected>#Y then\
D.autoc.selected=#Y end if Y[1]~=F then D.autoc.current=F\
D.autoc.str_diff=D.autoc.sorted[D.autoc.selected]if not D.autoc.str_diff then\
D.autoc.str_diff=\"\"end D.autoc.current_likeness=o(F,D.autoc.str_diff)end end\
end if L.name==\"char\"and D.selected and L.character:match(D.pattern)then\
if#D.input<D.char_limit then if not D.insert then D.input=C..L.character..M\
D.cursor_pos=D.cursor_pos+1 else\
D.input=C..L.character..M:gsub(\"^.\",\"\")D.cursor_pos=D.cursor_pos+1 end\
D.autoc.selected=1 D.on_change_input(D,L,D.input)end end if L.name==\"key_up\"and\
D.selected then if L.key==keys.leftCtrl or L.key==keys.rightCtrl then\
D.ctrl=false end end if L.name==\"key\"and D.selected then if\
L.key==keys.leftCtrl or L.key==keys.rightCtrl then D.ctrl=true elseif\
L.key==keys.backspace then D.input=C:gsub(\".$\",\"\")..M D.autoc.selected=1\
D.cursor_pos=math.max(D.cursor_pos-1,0)D.on_change_input(D,L,D.input)elseif\
L.key==keys.left then if not D.ctrl then\
D.cursor_pos=math.max(D.cursor_pos-1,0)else local\
P=C:reverse():find(\" \")D.cursor_pos=P and#C-P or 0 end elseif L.key==keys.right\
then if not D.ctrl then\
D.cursor_pos=math.min(math.max(D.cursor_pos+1,0),#D.input)else local\
V=M:sub(2,#M):find(\" \")D.cursor_pos=V and V+#C or#D.input end elseif\
L.key==keys.tab and not D.ignore_tab and not L.held and(next(D.autoc.strings)or\
next(D.autoc.spec_strings)and D.selected)then local\
B=#D.autoc.str_diff-#D.autoc.current local\
G=D.input:gsub(D.autoc.current..\"$\",D.autoc.str_diff)if#G<=D.char_limit and\
D.cursor_pos>=#D.input then if D.autoc.put_space then\
D.input=G..\" \"D.cursor_pos=D.cursor_pos+B+1 else D.input=G\
D.cursor_pos=D.cursor_pos+B end\
D.autoc.sorted={}D.autoc.str_diff=\"\"D.on_change_input(D,L,D.input)end elseif\
L.key==keys.home then D.cursor_pos=0 elseif L.key==keys[\"end\"]then\
D.cursor_pos=#D.input elseif L.key==keys.delete then\
D.input=C..M:gsub(\"^.\",\"\")D.autoc.selected=1\
D.on_change_input(D,L,D.input)elseif L.key==keys.insert and not L.held then\
D.insert=not D.insert elseif L.key==keys.down then if\
D.autoc.selected+1<=#D.autoc.sorted then D.autoc.selected=D.autoc.selected+1\
end elseif L.key==keys.up then if D.autoc.selected>1 then\
D.autoc.selected=D.autoc.selected-1 end elseif L.key==keys.enter and D.selected\
then local\
K={}D.input:gsub(\"%S+\",function(Q)table.insert(K,Q)end)D.on_enter(D,L,K)end end\
if L.name==\"paste\"then D.autoc.selected=1 D.input=C..L.text..M\
D.cursor_pos=D.cursor_pos+#L.text D.on_change_input(D,L,D.input)end\
end",
  [ "objects/switch/graphic" ] = "local e=require(\"graphic_handle\").code return function(t)local\
a=t.canvas.term_object local o,i=t.positioning.x,t.positioning.y if not\
t.texture and not t.texture_on then a.setBackgroundColor(t.value and\
t.background_color_on or t.background_color)a.setTextColor(t.value and\
t.text_color_on or t.text_color)for n=i,t.positioning.height+i-1 do\
a.setCursorPos(o,n)a.write(t.symbol:rep(t.positioning.width))end else\
e.draw_box_tex(a,(t.value and t.texture_on or t.texture)or(t.texture or\
t.texture_on),t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height,(t.value\
and t.background_color_on or t.background_color)or colors.red,(t.value and\
t.text_color_on or t.text_color)or\
colors.black,nil,nil,t.canvas.texture_cache)end if t.text and((not t.value)or\
not t.text_on)then\
t.text(a,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)elseif\
t.text_on and t.value then\
t.text_on(a,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)end\
end",
  [ "apis/termtools" ] = "_ENV=_ENV.ORIGINAL local function e(t,...)local a={...}local o={}for i,n in\
pairs(a[1])do o[i]=function(...)local s=table.pack(t[i](...))for h,r in\
pairs(a)do s=table.pack(r[i](...))end return table.unpack(s,1,s.n or 1)end end\
return o end local function d(...)local l={...}local u={}for c,m in\
pairs(l[1])do u[c]=function(...)local f={}for w,y in pairs(l)do\
f=table.pack(y[c](...))end return table.unpack(f,1,f.n or 1)end end return u\
end\
return{mirror_monitors=e,make_shared_terminal=d}",
  [ "objects/group/graphic" ] = "return\
function(e)e.window.redraw()end\
",
  [ "apis/text" ] = "_ENV=_ENV.ORIGINAL local e=require(\"cc.expect\").expect local function\
t(a,o,i)e(1,a,\"string\")e(2,o,\"number\")local n,s,h={},{},\"\"for r in\
a:gmatch(\"[%w%p%a%d]+%s?\")do table.insert(n,r)end if o==0 then return\"\"end\
while h<a and not(#n==0)do local d=\"\"while n~=0 do local l=n[1]if not l then\
break end if#l>o then local u=l:match(\"% +$\")or\"\"if not((#l-#u)<=o)then local\
c,m=l:sub(1,o),l:sub(o+1)if#(d..c)>o then n[1]=t(c..m,o,true)break end\
d,n[1],l=d..c,m,m else l=l:sub(1,#l-(#l-o))end end if#(d..l)<=o then d=d..l\
table.remove(n,1)else break end end table.insert(s,d)end return\
table.concat(s,i and\"\"or\"\\n\")end local function\
f(w,y)e(1,w,\"string\")e(2,y,\"number\")local p={}local v=\"\"for b in\
w:gmatch(\".\")do if#v+#b<=y then v=v..b else table.insert(p,v)v=b end end\
table.insert(p,v)return p end local function\
g(k,q)e(1,k,\"string\")e(2,q,\"number\")local j=k:sub(1,q)if#j<q then\
j=j..(\" \"):rep(q-#j)end return j end local function x(z)e(1,z,\"table\")return\
table.concat(z,\"\\n\")end\
return{wrap=t,cut_parts=f,ensure_size=g}",
  [ "objects/scrollbox/logic" ] = "local e=require(\"api\")return function(t,a)if\
e.is_within_field(a.x,a.y,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)then\
if a.direction==-1 then t.value=t.value+1 if t.value>t.limit_max then\
t.value=t.limit_max end t.on_change_value(t)t.on_up(t)elseif a.direction==1\
then t.value=t.value-1 if t.value<t.limit_min then t.value=t.limit_min end\
t.on_change_value(t)t.on_down(t)end end\
end",
  graphic_handle = "local e=require\"a-tools.luappm\"local t=require\"a-tools.blbfor\".open local\
a=require\"api\"_ENV=_ENV.ORIGINAL local o=require\"cc.expect\"local\
i=\"0123456789abcdef\"local n,s={},{}for h=0,15 do\
n[2^h]=i:sub(h+1,h+1)s[i:sub(h+1,h+1)]=2^h end local r=function(d)local\
l=a.tables.createNDarray(2)l[\"offset\"]=d[\"offset\"]for u,c in pairs(d)do for m,f\
in pairs(c)do if type(f)==\"table\"then l[u][m]={}if f then\
l[u][m].t=s[f.t]l[u][m].b=s[f.b]l[u][m].s=f.s end end end end return\
setmetatable(l,getmetatable(d))end local function w(y)local\
p,v=math.huge,-math.huge local b,g=math.huge,-math.huge for k,q in pairs(y)do\
p,v=math.min(p,k),math.max(v,k)for j,x in pairs(q)do\
b,g=math.min(b,j),math.max(g,j)end end return math.abs(p)+v,math.abs(b)+g end\
local function z(E,T)local A={}local O={}for I,N in pairs(E)do local\
S=math.abs(I-T)A[#A+1],O[S]=S,I end local H=math.min(table.unpack(A))return\
E[O[H]]end local function R(D,L)if not next(D)then return nil end if D[L]then\
return D[L]end local U=math.floor(L+0.5)if D[U]then return D[U]end for\
C=1,math.huge do if D[U+C]then return D[U+C]end if D[U-C]then return D[U-C]end\
end end local function M(F)local W,Y if\
not(type(F)==\"table\")and(F:match(\".nimg$\")and fs.exists(F))then\
W=fs.open(F,\"r\")if not W then error(\"file doesnt exist\",2)end\
Y=textutils.unserialise(W.readAll())else Y=F end local\
P=a.tables.createNDarray(2,r(Y))local V=a.tables.createNDarray(2)for B,G in\
pairs(P)do if type(B)~=\"string\"then for K,Y in pairs(G)do\
V[B-P.offset[1]+1][K-P.offset[2]+5]={text_color=Y.t,background_color=Y.b,symbol=Y.s}end\
end end V.scale={w(V)}return\
setmetatable({tex=V,offset=P.offset,id=a.uuid4()},{__tostring=function()return\"GuiH.texture\"end})end\
local function Q(J)local X o(1,J,\"string\",\"table\")if type(J)==\"table\"then X=J\
else local\
Z=fs.open(J,\"r\")assert(Z,\"file doesnt exist\")X=textutils.unserialise(Z.readAll())Z.close()end\
local et=a.tables.createNDarray(2,{offset={5,13,11,4}})for tt,at in pairs(X)do\
for ot,it in pairs(at)do et[tt+4][ot+7]={s=\" \",b=it,t=\"0\"}end end return\
M(et)end local function nt(st)local ht,rt=pcall(t,st,\"r\")if not ht then\
error(rt,3)end local dt={}for lt=1,rt.layers do local\
ut=a.tables.createNDarray(2,{offset={5,13,11,4}})for ct=1,rt.width do for\
mt=1,rt.height do local\
ft,wt,yt=rt:read_pixel(lt,ct,mt,true)ut[ct+4][mt+8]={s=ft,b=yt,t=wt}end end\
dt[lt]=M(ut)end return dt end local function pt(vt,bt)bt=bt or colors.black\
local gt=fs.open(vt,\"r\")if not gt then error(\"file doesnt exist\",2)end local\
kt=textutils.unserialise(gt.readAll())gt.close()assert(kt.type==\"lImg\"or\
kt.type==nil,\"not an limg image\")local qt={}for jt,xt in pairs(kt)do if\
jt~=\"type\"and xt~=\"lImg\"then local\
zt=a.tables.createNDarray(2,{offset={5,13,11,4}})for Et,Tt in pairs(xt)do local\
At,Ot,It=Tt[3]:gsub(\"T\",n[bt]),Tt[2]:gsub(\"T\",n[bt]),Tt[1]local\
Nt=a.piece_string(At)local St=a.piece_string(Ot)local Ht=a.piece_string(It)for\
Rt,Dt in pairs(Ht)do zt[Rt+4][Et+8]={s=Dt,b=Nt[Rt],t=St[Rt]}end end\
qt[jt]=M(zt)end end return qt end local function Lt(Ut,Ct,Mt)local\
Ft=pt(Ut,Ct)return Ft[Mt or 1],Ft end local function Wt(Yt)local\
Pt=nt(Yt)return Pt[1],Pt end local function Vt(Bt,Gt)local Kt={}for Qt=0,15 do\
local\
Jt,Xt,Zt=Bt.getPaletteColor(2^Qt)table.insert(Kt,{dist=math.sqrt((Jt-Gt.r)^2+(Xt-Gt.g)^2+(Zt-Gt.b)^2),color=2^Qt})end\
table.sort(Kt,function(ea,ta)return ea.dist<ta.dist end)return\
Kt[1].color,Kt[1].dist,Kt end local function aa(oa,ia)local\
na,sa,ha,ra={},{},{},{}local da=0 for la,ua in pairs(oa)do na[ua]=na[ua]~=nil\
and{count=na[ua].count+1,c=na[ua].c}or(function()da=da+1\
return{count=1,c=ua}end)()end for ca,ma in pairs(na)do if not ra[ma.c]then\
ra[ma.c]=true if da==1 then table.insert(sa,ma)end table.insert(sa,ma)end end\
table.sort(sa,function(fa,wa)return fa.count>wa.count end)for ya=1,6 do if\
oa[ya]==sa[1].c then ha[ya]=1 elseif oa[ya]==sa[2].c then ha[ya]=0 else\
ha[ya]=ia and 0 or 1 end end if ha[6]==1 then for pa=1,5 do ha[pa]=1-ha[pa]end\
end local va=128 for ba=0,4 do va=va+ha[ba+1]*2^ba end return\
string.char(va),ha[6]==1 and sa[2].c or sa[1].c,ha[6]==1 and sa[1].c or sa[2].c\
end local function ga(ka,qa,ja,xa)ka[qa+ja*2-2]=xa return ka end local function\
za(Ea,Ta,Aa,Oa)local\
Ia=term.current()Oa(\"loading ppm texture.. \",Oa.update)Oa(\"decoding ppm.. \",Oa.update)local\
Na=e(Ta)Oa(\"decoding finished. \",Oa.success)if Na then local\
Sa={}Oa(\"transforming pixels to characters..\",Oa.update)for Ha=1,Na.width do\
for Ra=1,Na.height do local Da=Vt(Ea or Ia,Na.get_pixel(Ha,Ra))local\
La,Ua=math.ceil(Ha/2),math.ceil(Ra/3)local Ca,Ma=(Ha-1)%2+1,(Ra-1)%3+1 if not\
Sa[La]then Sa[La]={}end\
Sa[La][Ua]=ga(Sa[La][Ua]or{},Ca,Ma,Da)os.queueEvent(\"\")os.pullEvent(\"\")end end\
Oa(\"transformation finished. \"..tostring((Na.width/2)*(Na.height/3))..\" characters\",Oa.success)local\
Fa=a.tables.createNDarray(2,{offset={5,13,11,4}})Oa(\"building nimg format..\",Oa.update)for\
Wa,Ya in pairs(Sa)do for Pa,Va in pairs(Ya)do local\
Ba,Ga,Ka=aa(Va,Aa)Fa[Wa+4][Pa+8]={s=Ba,t=n[Ga],b=n[Ka]}end end\
Oa(\"building finished. texture loaded.\",Oa.success)Oa(\"\")Oa:dump()return\
setmetatable(M(Fa),{__tostring=function()return\"GuiH.texture\"end}),Na end end\
local function Qa(Ja,Xa,Za,eo)local to=Za.tex local\
ao,oo=math.floor(to.scale[1]-0.5),math.floor(to.scale[2]-0.5)Ja=((Ja-1)%ao)+1\
Xa=((Xa-1)%oo)+1 local io=to[Ja][Xa]local no=to.scale to.scale=nil if not io\
and eo then local so=z(to,Ja)io=R(so or{},Xa)end to.scale=no return io end\
local function ho(ro,lo,uo,co,mo,fo,wo,yo,po,vo,bo)local\
go,ko,qo={},{},{}po,vo=po or 0,vo or 0 local jo=false if type(bo)==\"table\"and\
bo[lo.id]then local xo=bo[lo.id].args jo=xo.x==uo and xo.y==co and xo.width==mo\
and xo.height==fo and xo.bg==wo and xo.tg==yo and xo.offsetx==po and\
xo.offsety==vo end if type(bo)==\"table\"and bo[lo.id]and jo then\
go=bo[lo.id].bg_layers ko=bo[lo.id].fg_layers qo=bo[lo.id].text_layers else for\
zo=1,fo do for Eo=1,mo do local To=Qa(Eo+po,zo+vo,lo)if To and next(To)then\
go[zo]=(go[zo]or\"\")..n[To.background_color]ko[zo]=(ko[zo]or\"\")..n[To.text_color]qo[zo]=(qo[zo]or\"\")..To.symbol:match(\".$\")else\
go[zo]=(go[zo]or\"\")..n[wo]ko[zo]=(ko[zo]or\"\")..n[yo]qo[zo]=(qo[zo]or\"\")..\" \"end\
end end if type(bo)==\"table\"then\
bo[lo.id]={bg_layers=go,fg_layers=ko,text_layers=qo,args={term=ro,x=uo,y=co,width=mo,height=fo,bg=wo,tg=yo,offsetx=po,offsety=vo}}end\
end for Ao,Oo in pairs(go)do\
ro.setCursorPos(uo,co+Ao-1)ro.blit(qo[Ao],ko[Ao],go[Ao])end end\
return{load_nimg_texture=M,load_ppm_texture=za,load_cimg_texture=Q,load_blbfor_texture=Wt,load_blbfor_animation=nt,load_limg_texture=Lt,load_limg_animation=pt,code={get_pixel=Qa,draw_box_tex=ho,to_blit=n,to_color=s,build_drawing_char=aa},load_texture=M}",
  [ "objects/scrollbox/graphic" ] = "return\
function()end\
",
  installer = "fs.makeDir(\"GuiH\")fs.makeDir(\"GuiH/a-tools\")fs.makeDir(\"GuiH/objects\")fs.makeDir(\"GuiH/apis/\")fs.makeDir(\"GuiH/apis/fonts.7sh\")fs.makeDir(\"GuiH/presets\")fs.makeDir(\"GuiH/presets/rect\")fs.makeDir(\"GuiH/presets/tex\")local\
e=http.get(\"https://api.github.com/repos/9551-Dev/GuiH/git/trees/main?recursive=1\",_G._GIT_API_KEY\
and{Authorization='token '.._G._GIT_API_KEY})local\
t=textutils.unserialiseJSON(e.readAll())local a={}local o=0 e.close()for i,n in\
pairs(t.tree)do if n.type==\"blob\"and n.path:lower():match(\".+%.lua\")then\
a[\"https://raw.githubusercontent.com/9551-Dev/GuiH/main/\"..n.path]=n.path o=o+1\
end end local s=100/o local h=0 local r=0 local d={}for l,u in pairs(a)do\
table.insert(d,function()local c=http.get(l)local\
m=fs.open(\"./GuiH/\"..u,\"w\")m.write(c.readAll())m.close()c.close()h=h+1 local\
f=fs.getSize(\"./GuiH/\"..u)r=r+f\
print(\"downloading \"..u..\"  \"..tostring(math.ceil(h*s))..\"% \"..tostring(math.ceil(f/1024*10)/10)..\"kB total: \"..math.ceil(r/1024)..\"kB\")end)end\
parallel.waitForAll(table.unpack(d))print(\"Finished downloading GuiH\")",
  [ "objects/group/logic" ] = "return\
function(e,t)e.bef_draw(e,t)end\
",
  init = "if config then if config.get(\"standardsMode\")==false then\
print(\"WARNING: standardsMode is set to false, this is not supported by the GuiH API\")print(\"Enter Y to enable standards mode, this will reboot the computer\")local\
e=read()if e:lower():match(\"y\")then\
config.set(\"standardsMode\",true)os.reboot()else\
error(\"GuiH cannot run without standards mode\",0)end end end local\
t=require\"main\"return\
setmetatable(t,{__tostring=function()return\"GuiH.API\"end})",
  [ "presets/rect/frame" ] = "return\
function(e,t)return{top_left={sym=\"\\151\",bg=t,fg=e},top_right={sym=\"\\148\",bg=e,fg=t},bottom_left={sym=\"\\138\",bg=e,fg=t},bottom_right={sym=\"\\133\",bg=e,fg=t},side_left={sym=\"\\149\",bg=t,fg=e},side_right={sym=\"\\149\",bg=e,fg=t},side_top={sym=\"\\131\",bg=t,fg=e},side_bottom={sym=\"\\143\",bg=e,fg=t},inside={sym=\" \",bg=t,fg=e}}end\
",
  [ "objects/text/logic" ] = "return\
function()end\
",
  [ "objects/circle/graphic" ] = "local e=require(\"a-tools.algo\")local t=require(\"graphic_handle\").code local\
a=require(\"api\")return function(o)local i=o.canvas.term_object local n={}local\
s={}local h=a.tables.createNDarray(2)if o.filled then local\
r=e.get_elipse_points(o.positioning.radius,math.ceil(o.positioning.radius-o.positioning.radius/3)+0.5,o.positioning.x,o.positioning.y,true)for\
d,l in ipairs(r)do if h[l.x][l.y]~=true then\
n[l.y]=(n[l.y]or\"\")..\"*\"s[l.y]=math.min(s[l.y]or math.huge,l.x)h[l.x][l.y]=true\
end end for u,c in pairs(n)do\
i.setCursorPos(s[u],u)i.blit(c:gsub(\"%*\",o.symbol),c:gsub(\"%*\",t.to_blit[o.fg]),c:gsub(\"%*\",t.to_blit[o.bg]))end\
else local\
m=e.get_elipse_points(o.positioning.radius,math.ceil(o.positioning.radius-o.positioning.radius/3)+0.5,o.positioning.x,o.positioning.y)for\
f,w in pairs(m)do\
i.setCursorPos(w.x,w.y)i.blit(o.symbol,t.to_blit[o.fg],t.to_blit[o.bg])end end\
end",
  main = "local e=require(\"a-tools.logger\")local t=e.create_log()local\
a={algo=require(\"a-tools.algo\"),luappm=require(\"a-tools.luappm\"),blbfor=require(\"a-tools.blbfor\"),graphic=require(\"graphic_handle\").code,general=require(\"api\")}local\
o={}t(\"loading apis..\",t.update)for i,n in pairs(fs.list(\"apis\"))do local\
s=n:match(\"[^.]+\")if not fs.isDir(\"apis/\"..n)then\
a[s]=require(\"apis.\"..s)t(\"loaded api: \"..s)end end\
t(\"\")t(\"loading presets..\",t.update)for h,r in pairs(fs.list(\"presets\"))do for\
d,l in pairs(fs.list(\"presets/\"..r))do if not o[r]then o[r]={}end local\
u=l:match(\"[^.]+\")o[r][u]=require(\"presets.\"..r..\".\"..u)t(\"loaded preset: \"..r..\" > \"..u)end\
end t(\"\")t(\"finished loading\",t.success)t(\"\")t:dump()local function\
c(m,f,w)local y=require(\"a-tools.gui_object\")local\
p=window.create(m,1,1,m.getSize())t(\"creating gui object..\",t.update)local\
v=y(p,m,t,f,w)t(\"finished creating gui object!\",t.success)t(\"\",t.info)t:dump()local\
b=getmetatable(v)or{}b.__tostring=function()return\"GuiH.MAIN_UI.\"..tostring(v.id)end\
v.api=a v.preset=o return setmetatable(v,b)end\
return{create_gui=c,new=c,load_texture=require(\"graphic_handle\").load_texture,convert_event=function(g,k,q,j,x)local\
z={}if g==\"monitor_touch\"then z={name=g,monitor=k,x=q,y=j}end if\
g==\"mouse_click\"or g==\"mouse_up\"then z={name=g,button=k,x=q,y=j}end if\
g==\"mouse_drag\"then z={name=g,button=k,x=q,y=j}end if g==\"mouse_scroll\"then\
z={name=g,direction=k,x=q,y=j}end if g==\"key\"then\
z={name=g,key=k,held=q,x=math.huge,y=math.huge}end if g==\"key_up\"then\
z={name=g,key=k,x=math.huge,y=math.huge}end if g==\"char\"then\
z={name=g,character=k,x=math.huge,y=math.huge}end if g==\"guih_data_event\"then\
z=k end if not z.monitor then z.monitor=\"term_object\"end return z\
or{name=g}end,apis=a,presets=o,valid_events={[\"mouse_click\"]=true,[\"mouse_drag\"]=true,[\"monitor_touch\"]=true,[\"mouse_scroll\"]=true,[\"mouse_up\"]=true,[\"key\"]=true,[\"key_up\"]=true,[\"char\"]=true,[\"guih_data_event\"]=true},log=t}",
  [ "presets/tex/brick" ] = "local e=require(\"graphic_handle\")return function(t,a)if not t then\
t=colors.gray end if not a then a=colors.lightGray end local\
o=[[{\
        [3] = {[5] = {b = \"background\", s = \"\", t = \"brick\"}, [6] = {b = \"background\", s = \"\", t = \"brick\"}},\
        [4] = {[5] = {b = \"background\", s = \"\", t = \"brick\"}, [6] = {b = \"background\", s = \"\", t = \"brick\"}},\
        [5] = {[5] = {b = \"background\", s = \"\", t = \"brick\"}, [6] = {b = \"background\", s = \"\", t = \"brick\"}},\
        offset = {3, 9, 11, 4}\
    }]]local\
i=o:gsub(\"background\",e.code.to_blit[t]):gsub(\"brick\",e.code.to_blit[a])return\
e.load_texture(textutils.unserialize(i))end",
  [ "objects/progressbar/object" ] = "local e=require(\"api\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(o.drag_texture)~=\"boolean\"then o.drag_texture=false end local\
i={name=o.name or e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or\
0,height=o.height or 0},visible=o.visible,fg=o.fg or colors.white,bg=o.bg or\
colors.black,texture=o.tex,value=o.value or 0,direction=t[o.direction]and\
o.direction or\"left-right\",order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,drag_texture=o.drag_texture,tex_offset_x=o.tex_offset_x\
or 0,tex_offset_y=o.tex_offset_y or 0,}return i\
end",
  [ "objects/group/object" ] = "local e=require(\"api\")local t=require(\"a-tools.gui_object\")return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(o.reactive)~=\"boolean\"then o.reactive=true end local i={name=o.name or\
e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or 0,height=o.height\
or 0},visible=o.visible,order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,bef_draw=o.bef_draw\
or function()end}local\
n=window.create(a.term_object,i.positioning.x,i.positioning.y,i.positioning.width,i.positioning.height)i.gui=t(n,a.term_object,a.log)i.window=n\
i.gui.inherit(a,i)return i\
end",
  [ "objects/text/object" ] = "local e=require(\"api\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end local o={name=a.name or\
e.uuid4(),visible=a.visible,text=a.text or\
t.text{text=\"none\",x=1,y=1,bg=colors.red,fg=colors.black},order=a.order or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,update=a.update or\
function()end}return o\
end",
  [ "apis/pixelbox" ] = "local e=require(\"graphic_handle\")local t=require(\"api\")local\
a=require(\"a-tools.algo\")_ENV=_ENV.ORIGINAL local o=require(\"cc.expect\").expect\
local i={}local n={}function i.INDEX_SYMBOL_CORDINATION(s,h,r,d)s[h+r*2-2]=d\
return s end function n:within(l,u)return l>0 and u>0 and l<=self.width*2 and\
u<=self.height*3 end function\
n:push_updates()i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")self.symbols=t.tables.createNDarray(2)self.lines=t.create_blit_array(self.height)getmetatable(self.symbols).__tostring=function()return\"PixelBOX.SYMBOL_BUFFER\"end\
setmetatable(self.lines,{__tostring=function()return\"PixelBOX.LINE_BUFFER\"end})for\
c,m in pairs(self.CANVAS)do for f,w in pairs(m)do local y=math.ceil(f/2)local\
p=math.ceil(c/3)local v=(f-1)%2+1 local b=(c-1)%3+1\
self.symbols[p][y]=i.INDEX_SYMBOL_CORDINATION(self.symbols[p][y],v,b,w)end end\
for g,k in pairs(self.symbols)do for q,j in ipairs(k)do local\
x,z,E=e.code.build_drawing_char(j)self.lines[g]={self.lines[g][1]..x,self.lines[g][2]..e.code.to_blit[z],self.lines[g][3]..e.code.to_blit[E]}end\
end end function\
n:get_pixel(T,A)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o(1,T,\"number\")o(2,A,\"number\")assert(self.CANVAS[A]and\
self.CANVAS[A][T],\"Out of range\")return self.CANVAS[A][T]end function\
n:clear(O)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o(1,O,\"number\")self.CANVAS=t.tables.createNDarray(2)for\
I=1,self.height*3 do for N=1,self.width*2 do self.CANVAS[I][N]=O end end\
getmetatable(self.CANVAS).__tostring=function()return\"PixelBOX_SCREEN_BUFFER\"end\
end function\
n:draw()i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")if\
not self.lines then error(\"You must push_updates in order to draw\",2)end for\
S,H in ipairs(self.lines)do\
self.term.setCursorPos(1,S)self.term.blit(table.unpack(H))end end function\
n:set_pixel(R,D,L,U)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o(1,R,\"number\")o(2,D,\"number\")o(3,L,\"number\")i.ASSERT(R>0\
and R<=self.width*2,\"Out of range\")i.ASSERT(D>0 and\
D<=self.height*3,\"Out of range\")U=U or 1 local C=(U-1)/2\
self:set_box(math.ceil(R-C),math.ceil(D-C),R+U-1,D+U-1,L,true)end function\
n:set_box(M,F,W,Y,P,V)if not V then\
i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o(1,M,\"number\")o(2,F,\"number\")o(3,W,\"number\")o(4,Y,\"number\")o(5,P,\"number\")end\
for B=F,Y do for G=M,W do if self:within(G,B)then self.CANVAS[B][G]=P end end\
end end function n:set_ellipse(K,Q,J,X,Z,et,tt,at)if not at then\
i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o(1,K,\"number\")o(2,Q,\"number\")o(3,J,\"number\")o(4,X,\"number\")o(5,Z,\"number\")o(6,et,\"boolean\",\"nil\")end\
tt=tt or 1 local ot=(tt-1)/2 if type(et)~=\"boolean\"then et=true end local\
it=a.get_elipse_points(J,X,K,Q,et)for nt,st in ipairs(it)do if\
self:within(st.x,st.y)then\
self:set_box(math.ceil(st.x-ot),math.ceil(st.y-ot),st.x+tt-1,st.y+tt-1,Z,true)end\
end end function\
n:set_circle(ht,rt,dt,lt,ut,ct)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o(1,ht,\"number\")o(2,rt,\"number\")o(3,dt,\"number\")o(4,lt,\"number\")o(5,ut,\"boolean\",\"nil\")self:set_ellipse(ht,rt,dt,dt,lt,ut,ct,true)end\
function\
n:set_triangle(mt,ft,wt,yt,pt,vt,bt,gt,kt)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o(1,mt,\"number\")o(2,ft,\"number\")o(3,wt,\"number\")o(4,yt,\"number\")o(5,pt,\"number\")o(6,vt,\"number\")o(7,bt,\"number\")o(8,gt,\"boolean\",\"nil\")kt=kt\
or 1 local qt=(kt-1)/2 if type(gt)~=\"boolean\"then gt=true end local jt if gt\
then\
jt=a.get_triangle_points(vector.new(mt,ft),vector.new(wt,yt),vector.new(pt,vt))else\
jt=a.get_triangle_outline_points(vector.new(mt,ft),vector.new(wt,yt),vector.new(pt,vt))end\
for xt,zt in ipairs(jt)do if self:within(zt.x,zt.y)then\
self:set_box(math.ceil(zt.x-qt),math.ceil(zt.y-qt),zt.x+kt-1,zt.y+kt-1,bt,true)end\
end end function\
n:set_line(Et,Tt,At,Ot,It,Nt)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")o(1,Et,\"number\")o(2,Tt,\"number\")o(3,At,\"number\")o(4,Ot,\"number\")o(5,It,\"number\")Nt=Nt\
or 1 local St=(Nt-1)/2 local Ht=a.get_line_points(Et,Tt,At,Ot)for Rt,Dt in\
ipairs(Ht)do if self:within(Dt.x,Dt.y)then\
self:set_box(math.ceil(Dt.x-St),math.ceil(Dt.y-St),Dt.x+Nt-1,Dt.y+Nt-1,It,true)end\
end end function i.ASSERT(Lt,Ut)if not Lt then error(Ut,3)end return Lt end\
function\
i.new(Ct,Mt,Ft)o(1,Ct,\"table\")o(2,Mt,\"number\",\"nil\")o(3,Ft,\"table\",\"nil\")local\
Mt=Mt or Ct.getBackgroundColor()or colors.black local Wt={}local\
Yt,Pt=Ct.getSize()Wt.term=setmetatable(Ct,{__tostring=function()return\"term_object\"end})Wt.CANVAS=t.tables.createNDarray(2,Ft)getmetatable(Wt.CANVAS).__tostring=function()return\"PixelBOX_SCREEN_BUFFER\"end\
Wt.width=Yt Wt.height=Pt for Vt=1,Pt*3 do for Bt=1,Yt*2 do Wt.CANVAS[Vt][Bt]=Mt\
end end return setmetatable(Wt,{__index=n})end return\
i",
  object_loader = "local e=require(\"api\")local function t(a)local o=type(a)local i if\
o==\"table\"then i={}for n,s in next,a,nil do if n==\"canvas\"then i.canvas=s else\
i[t(n)]=t(s)end end setmetatable(i,t(getmetatable(a)))else i=a end return i end\
return{main=function(h,r,d)local l=h local u={}local c=fs.list(\"objects\")for\
m,f in pairs(c)do d(\"loading object: \"..f,d.update)local\
w,y=pcall(require,\"objects/\"..f..\"/object\")if w and type(y)==\"function\"then\
local p,v=pcall(require,\"objects/\"..f..\"/logic\")local\
b,g=pcall(require,\"objects/\"..f..\"/graphic\")if p and b\
and(type(v)==\"function\")and(type(g)==\"function\")then local\
k=fs.list(fs.combine(\"objects/\",f))local q={}local j={}for x,z in pairs(k)do\
local E=z:match(\"(.*)%.\")or z if not(E==\"logic\"or E==\"graphic\"or\
E==\"object\")and(not fs.isDir(\"objects/\"..f..\"/\"..E))then\
d(\"objects.\"..f..\".\"..E)local T,A=pcall(require,\"objects/\"..f..\"/\"..E)if T then\
d(\"found custom object flag \\\"\"..E..\"\\\" for: \"..f,d.update)q[E]=require(\"objects/\"..f..\"/\"..E)else\
d(\"bad object flag \"..A)end else if E==\"manipulators\"then\
d(\"found custom object manipulators for: \"..f,d.update)local\
O=fs.list(\"objects/\"..f..\"/manipulators\")for x,z in pairs(O)do local\
I,N=pcall(require,\"objects/\"..f..\"/manipulators/\"..z:match(\"(.*)%.\")or z)if I\
then\
d(\"found custom object manipulator \\\"\"..z..\"\\\" for: \"..f,d.update)j[z:match(\"(.*)%.\")or\
z]=setmetatable({},{__call=function(S,...)return\
N(...)end,__index=N,__tostring=function()return\"GuiH.\"..f..\".manipulator\"end})else\
d(\"bad object manipulator \"..N)end end end end end\
u[f]=setmetatable({},{__index=q,__tostring=function()return\"GuiH.element_builder.\"..f\
end,__call=function(H,R)local l=y(l,R)if not(type(l.name)==\"string\")then\
l.name=e.uuid4()end if not(type(l.order)==\"number\")then l.order=1 end if\
not(type(l.logic_order)==\"number\")then l.logic_order=1 end if\
not(type(l.graphic_order)==\"number\")then l.graphic_order=1 end if\
not(type(l.react_to_events)==\"table\")then l.react_to_events={}end if\
not(type(l.btn)==\"table\")then l.btn={}end if\
not(type(l.visible)==\"boolean\")then l.visible=true end if\
not(type(l.reactive)==\"boolean\")then l.reactive=true end if\
type(l.positioning)==\"table\"then if R.w and not R.width then\
l.positioning.width=R.w end if R.h and not R.height then\
l.positioning.height=R.h end end r[f][l.name]=l local D=l local\
L={finish=function()return D end}local U={finish=function()return D end}local\
function C(M,F,l,W)local function\
Y(P,V,B)P[V]=setmetatable({},{__call=function(H,G,K)if type(G)~=B then\
error(\"Types are immutable with setters\",2)end if h.debug then\
d(\"Modified \\\"\"..V..\"\\\" of \"..D.name)end l[V]=G return K and M or L end})end\
local function Q(J,X)J[X]=setmetatable({},{__call=function()if h.debug then\
d(\"Read \\\"\"..X..\"\\\" of \"..D.name)end return l[X]end})end for Z,et in pairs(l)do\
local tt=Z~=\"canvas\"and Z~=\"parent\"Y(M,Z,type(et))Q(F,Z)if type(et)==\"table\"and\
W then if not M[Z]then M[Z]={}end if not F[Z]then F[Z]={}end\
C(M[Z],F[Z],et,tt)end end end C(L,U,l,true)local at=t(j)or{}local ot={}local\
it=false for m,f in pairs(at)do ot[m]=function(...)return f(l,...)end it=true\
end if it then d(\"Finished attaching manipulators to creator.\",d.info)end\
ot.logic=v ot.graphic=g ot.set=L ot.get=U ot.kill=function()if r[f][l.name]then\
r[f][l.name]=nil if h.debug then d(\"killed \"..f..\" > \"..l.name,d.warn)end\
return true else if h.debug then\
d(\"tried to manipulate dead object.\",d.error)end return\
false,\"object no longer exist\"end end ot.get_position=function()if\
r[f][l.name]then if l.positioning then return l.positioning else return\
false,\"object doesnt have positioning information\"end else if h.debug then\
d(\"tried to manipulate dead object.\",d.error)end return\
false,\"object no longer exist\"end end ot.replicate=function(nt)nt=nt or\
e.uuid4()if r[f][l.name]then if nt==l.name then\
return\"name of copy cannot be the same!\"else if h.debug then\
d(\"Replicated \"..f..\" > \"..l.name..\" as \"..f..\" > \"..nt,d.info)end local\
st=t(r[f][l.name])r[f][nt or\"\"]=st st.name=nt return st,true end else if\
h.debug then d(\"tried to manipulate dead object.\",d.error)end return\
false,\"object no longer exist\"end end ot.isolate=function()if r[f][l.name]then\
local l=t(r[f][l.name])if h.debug then\
d(\"isolated \"..f..\" > \"..l.name,d.info)end return{parse=function(ht)if h.debug\
then d(\"parsed \"..f..\" > \"..l.name,d.info)end if l then local ht=ht or l.name\
if r[f][ht]then r[f][ht]=nil end r[f][ht]=l return r[f][ht]else return\
false,\"object no longer exist\"end end,get=function()if l then if h.debug then\
d(\"returned \"..f..\" > \"..l.name,d.info)end return l else return\
false,\"object no longer exist\"end end,clear=function()if h.debug then\
d(\"Removed copied object \"..f..\" > \"..l.name,d.info)end l=nil end,}else if\
h.debug then d(\"tried to manipulate dead object.\",d.error)end return\
false,\"object no longer exist\"end end ot.cut=function()if r[f][l.name]then\
local l=t(r[f][l.name])r[f][l.name]=nil if h.debug then\
d(\"cut \"..f..\" > \"..l.name,d.info)end return{parse=function()if l then if\
h.debug then d(\"parsed \"..f..\" > \"..l.name,d.info)end if r[f][l.name]then\
r[f][l.name]=nil end r[f][l.name]=l return r[f][l.name]else return\
false,\"object no longer exist\"end end,get=function()if h.debug then\
d(\"returned \"..f..\" > \"..l.name,d.info)end return l end,clear=function()if\
h.debug then d(\"Removed copied object \"..f..\" > \"..l.name,d.info)end l=nil\
end}else if h.debug then d(\"tried to manipulate dead object.\",d.error)end\
return false,\"object no longer exist\"end end ot.destroy=ot.kill\
ot.murder=ot.destroy ot.copy=ot.isolate if not type(ot.logic)==\"function\"then\
d(\"object \"..f..\" has invalid logic.lua\",d.error)return false end if not\
type(ot.graphic)==\"function\"then\
d(\"object \"..f..\" has invalid graphic.lua\",d.error)return false end\
setmetatable(l,{__index=ot,__tostring=function()return\"GuiH.element.\"..f..\".\"..l.name\
end})if l.positioning then\
setmetatable(l.positioning,{__tostring=function()return\"GuiH.element.position\"end})end\
l.canvas=h d(\"created new \"..f..\" > \"..l.name,d.info)d:dump()return l end})else\
if not p and b then d(f..\" is missing an logic file !\",d.error)end if not b and\
p then d(f..\" is missing an graphic file !\",d.error)end if not p and not b then\
d(f..\" is missing logic and graphic file !\",d.error)end if p\
and(type(v)~=\"function\")then d(f..\" has an invalid logic file !\",d.error)end if\
b and(type(g)~=\"function\")then\
d(f..\" has an invalid graphic file !\",d.error)end if b and p\
and(type(g)~=\"function\")and(type(v)~=\"function\")then\
d(f..\" has an invalid logic and graphic file !\",d.error)end end else if w and\
not(type(y)==\"function\")then d(f..\" has invalid object file!\",d.error)else\
d(f..\" is missing an object file !\",d.error)end end end _ENV=_ENV.ORIGINAL\
return u\
end,types=fs.list(\"objects\")}",
  [ "objects/scrollbox/object" ] = "local e=require(\"api\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end local o={name=a.name or\
e.uuid4(),positioning={x=a.x or 1,y=a.y or 1,width=a.width or 1,height=a.height\
or\
1},visible=a.visible,reactive=a.reactive,react_to_events={[\"mouse_scroll\"]=true},order=a.order\
or 1,logic_order=a.logic_order,graphic_order=a.graphic_order,value=a.value or\
1,limit_min=a.limit_min or-math.huge,limit_max=a.limit_max or\
math.huge,on_change_value=a.on_change_value or function()end,on_up=a.on_up or\
function()end,on_down=a.on_down or function()end}return o\
end",
  [ "objects/ellipse/graphic" ] = "local e=require(\"a-tools.algo\")local t=require(\"graphic_handle\").code local\
a=require(\"api\")return function(o)local i=o.canvas.term_object local n={}local\
s={}local h=a.tables.createNDarray(2)if o.filled then local\
r=e.get_elipse_points(o.positioning.width,o.positioning.height,o.positioning.x,o.positioning.y,true)for\
d,l in ipairs(r)do if h[l.x][l.y]~=true then\
n[l.y]=(n[l.y]or\"\")..\"*\"s[l.y]=math.min(s[l.y]or math.huge,l.x)h[l.x][l.y]=true\
end end for u,c in pairs(n)do\
i.setCursorPos(s[u],u)i.blit(c:gsub(\"%*\",o.symbol),c:gsub(\"%*\",t.to_blit[o.fg]),c:gsub(\"%*\",t.to_blit[o.bg]))end\
else local\
m=e.get_elipse_points(o.positioning.width,o.positioning.height,o.positioning.x,o.positioning.y)for\
f,w in pairs(m)do\
i.setCursorPos(w.x,w.y)i.blit(o.symbol,t.to_blit[o.fg],t.to_blit[o.bg])end end\
end",
  [ "objects/frame/logic" ] = "local e=require(\"api\")return function(t,a,o)t.on_any(t,a)local\
i,n=t.window.getPosition()local s=t.dragger.x+i local h=t.dragger.y+n if\
a.name==\"mouse_click\"or a.name==\"monitor_touch\"then if\
e.is_within_field(a.x,a.y,s-1,h-1,t.dragger.width,t.dragger.height)then\
t.dragged=true t.last_click=a t.on_select(t,a)end elseif a.name==\"mouse_up\"then\
t.dragged=false t.on_select(t,a)elseif a.name==\"mouse_drag\"and t.dragged and\
t.dragable then local r,d=t.window.getPosition()local\
l,u=t.window.getSize()local c,m=a.x-t.last_click.x,a.y-t.last_click.y\
t.last_click=a local f,w=r+c,d+m if not t.on_move(t,{x=f,y=w})then\
t.window.reposition(f,w)end end\
end",
  [ "a-tools/luappm" ] = "_ENV=_ENV.ORIGINAL local function e(t,a,o)local i={}for n=a,o do\
t.seek(\"set\",n)table.insert(i,t.read())end return\
string.char(table.unpack(i))end local function s(h,r)local d=r local l={}for\
u=1,3 do local c={}local m=\"\"while not(m==0x20 or m==0x0A)do\
h.seek(\"set\",d)m=h.read()table.insert(c,m)d=d+1 end\
table.insert(l,tonumber(string.char(table.unpack(c))))end return l,d end local\
function f(w,y,p)local v=y local b={}local g=0 w.seek(\"set\",y)while w.read()do\
g=g+1 end w.seek(\"set\",v)for k=1,math.floor(g/3)do local q=\"\"for k=1,3 do local\
j=0 local x={}while q and j<3 do w.seek(\"set\",v)q=w.read()if q~=nil then\
q=q/p[3]end table.insert(x,q)v=v+1 j=j+1 end if not next(x)then break end\
table.insert(b,{r=x[1],g=x[2],b=x[3]})end end return b,g/3 end local function\
z(E,T,A)local O={}for I,N in pairs(E)do local S=math.floor((I-1)%T+1)local\
H=math.ceil(I/T)if not O[A and S or H]then O[A and S or H]={}end O[A and S or\
H][A and H or S]=N end return O end local function R(D)local\
L=fs.open(D,\"rb\")if not L then error(\"File: \"..(D or\"\")..\" doesnt exist\",3)end\
if e(L,0,2)==\"P6\\x0A\"then local U=-math.huge while true do local C=L.read()if\
string.char(C)==\"#\"then while true do local M=L.read()if M==0x0A then break end\
U=L.seek(\"cur\")+1 end else local F,U=s(L,U)local W,Y=f(L,U,F)local\
C=z(W,F[1],true)local\
P=L.readAll()L.close()return{data=P,meta=F,pixels=C,pixel_count=Y,width=F[1],height=F[2],color_type=F[3],get_pixel=function(V,B)local\
G=C[math.floor(V+0.5)]if G then return G[math.floor(B+0.5)]end\
end,get_palette=function()local K={}local Q=0 local J={}local X={}for Z,et in\
pairs(W)do local tt=colors.packRGB(et.r,et.g,et.b)if not K[tt]then Q=Q+1\
K[tt]={c=tt,count=0}end K[tt].count=K[tt].count+1 end for at,ot in pairs(K)do\
table.insert(J,ot)end table.sort(J,function(it,nt)return it.count>nt.count\
end)for st,ht in ipairs(J)do local\
rt,dt,lt=colors.unpackRGB(ht.c)table.insert(X,{r=rt,g=dt,b=lt,c=ht.count})end\
return X,Q end}end end else\
L.close()error(\"File is unsupported format: \"..e(L,0,1),2)end end return\
R",
  [ "a-tools/logger" ] = "local\
e={{colors.red},{colors.yellow},{colors.white,colors.red},{colors.white,colors.lime},{colors.white,colors.lime},{colors.white},{colors.green},{colors.gray},}local\
t={error=1,warn=2,fatal=3,success=4,message=6,update=7,info=8}local a=15 local\
o={}for i,n in pairs(t)do o[n]=i end local function s(h)local\
h=h:gsub(\"^%[%d-%:%d-% %a-]\",\"\")return h end function t:dump()end local\
function r(d,l,u)local c,m=math.huge,math.huge local l=tostring(l)u=u\
or\"info\"if d.lastLog==l..u then d.nstr=d.nstr+1 else d.nstr=1 end\
d.lastLog=l..u local\
f=tostring(table.getn(d.history))..\": [\"..(os.date(\"%T\",os.epoch\"local\"/1000)..(\".%03d\"):format(os.epoch\"local\"%1000)):gsub(\"%.\",\" \")..\"] \"local\
w,y=unpack(e[u]or{})local p=\"[\"..(o[u]or\"info\")..\"]\"local\
v=f..p..(\" \"):rep(a-#p-#tostring(#d.history)-1)..\"\\127\"..l local\
b=v..(\" \"):rep(math.max(100-(#v),3))table.insert(d.history,{str=b,type=u})end\
local function g(k,q,j,x)q=q or\"-\"local\
z=setmetatable({lastLog=\"\",nstr=1,maxln=1,history={},title=k,tsym=(#q<4)and q\
or\"-\",auto_dump=j},{__index=t,__call=r})z.lastLog=nil return z end\
return{create_log=g}",
  [ "objects/rectangle/graphic" ] = "local e=require(\"graphic_handle\").code return function(t)local\
a=t.canvas.term_object local o,i=t.positioning.x,t.positioning.y local\
n,s=t.positioning.width,t.positioning.height\
a.setCursorPos(o,i)a.blit(t.symbols.top_left.sym..t.symbols.side_top.sym:rep(n-2)..t.symbols.top_right.sym,e.to_blit[t.symbols.top_left.fg]..e.to_blit[t.symbols.side_top.fg]:rep(n-2)..e.to_blit[t.symbols.top_right.fg],e.to_blit[t.symbols.top_left.bg]..e.to_blit[t.symbols.side_top.bg]:rep(n-2)..e.to_blit[t.symbols.top_right.bg])for\
h=1,s-2 do\
a.setCursorPos(o,i+h)a.blit(t.symbols.side_left.sym..t.symbols.inside.sym:rep(n-2)..t.symbols.side_right.sym,e.to_blit[t.symbols.side_left.fg]..e.to_blit[t.symbols.inside.fg]:rep(n-2)..e.to_blit[t.symbols.side_right.fg],e.to_blit[t.symbols.side_left.bg]..e.to_blit[t.symbols.inside.bg]:rep(n-2)..e.to_blit[t.symbols.side_right.bg])end\
a.setCursorPos(o,i+s-1)a.blit(t.symbols.bottom_left.sym..t.symbols.side_bottom.sym:rep(n-2)..t.symbols.bottom_right.sym,e.to_blit[t.symbols.bottom_left.fg]..e.to_blit[t.symbols.side_bottom.fg]:rep(n-2)..e.to_blit[t.symbols.bottom_right.fg],e.to_blit[t.symbols.bottom_left.bg]..e.to_blit[t.symbols.side_bottom.bg]:rep(n-2)..e.to_blit[t.symbols.bottom_right.bg])end",
  [ "objects/switch/logic" ] = "local e=require(\"api\")return function(t,a)if\
e.is_within_field(a.x,a.y,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)then\
t.value=not t.value t.on_change_state(t,a)end\
end",
  [ "objects/triangle/graphic" ] = "local e=require(\"a-tools.algo\")local t=require(\"graphic_handle\").code return\
function(a)local o=a.canvas.term_object local i={}local n={}if a.filled then\
local\
s=e.get_triangle_points(a.positioning.p1,a.positioning.p2,a.positioning.p3)for\
h,r in ipairs(s)do i[r.y]=(i[r.y]or\"\")..\"*\"n[r.y]=math.min(n[r.y]or\
math.huge,r.x)end for d,l in pairs(i)do\
o.setCursorPos(n[d],d)o.blit(l:gsub(\"%*\",a.symbol),l:gsub(\"%*\",t.to_blit[a.fg]),l:gsub(\"%*\",t.to_blit[a.bg]))end\
else local\
u=e.get_triangle_outline_points(a.positioning.p1,a.positioning.p2,a.positioning.p3)for\
c,m in pairs(u)do\
o.setCursorPos(m.x,m.y)o.blit(a.symbol,t.to_blit[a.fg],t.to_blit[a.bg])end end\
end",
  [ "presets/tex/checker" ] = "local e=require(\"api\")local t=require(\"graphic_handle\")return\
function(...)local a=e.tables.createNDarray(2,{offset={5,13,11,4}})local\
o={...}local i=1 for n,s in pairs(o)do local h={}for r=1,table.getn(o)do local\
d=((r+i)-2)%table.getn(o)+1 h[r]=o[d]end for n,s in pairs(h)do\
a[n+4][i+8]={s=\" \",t=\"f\",b=t.code.to_blit[s]}end i=i+1 end return\
t.load_texture(a)end",
  [ "a-tools/object-base" ] = "local e=require(\"api\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end local o={name=a.name or\
e.uuid4(),visible=a.visible,reactive=a.reactive,react_to_events={},btn={},order=a.order\
or 1,logic_order=a.logic_order,graphic_order=a.graphic_order,}return o\
end",
  [ "objects/progressbar/graphic" ] = "local e=require(\"graphic_handle\")return function(t)local a=t.canvas.term_object\
local\
o=math.floor(math.max(math.min(t.positioning.width*(t.value/100),t.positioning.width),0))local\
i=math.ceil(math.min(math.max(t.positioning.width-o,0),t.positioning.width))if\
t.direction==\"left-right\"then if not t.texture then for\
n=t.positioning.y,t.positioning.height+t.positioning.y-1 do\
a.setCursorPos(t.positioning.x,n)a.blit((\" \"):rep(o)..(\" \"):rep(i),(\"f\"):rep(o)..(\"f\"):rep(i),e.code.to_blit[t.fg]:rep(o)..e.code.to_blit[t.bg]:rep(i))end\
else if not t.drag_texture then\
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y,o,t.positioning.height,t.bg,t.fg,t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)else\
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y,o,t.positioning.height,t.bg,t.fg,-o+1+t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)end\
for s=t.positioning.y,t.positioning.height+t.positioning.y-1 do\
a.setCursorPos(t.positioning.x+o,s)a.blit((\" \"):rep(i),(\"f\"):rep(i),e.code.to_blit[t.bg]:rep(i))end\
end end if t.direction==\"right-left\"then if not t.texture then for\
h=t.positioning.y,t.positioning.height+t.positioning.y-1 do\
a.setCursorPos(t.positioning.x,h)a.blit((\" \"):rep(i)..(\" \"):rep(o),(\"f\"):rep(i)..(\"f\"):rep(o),e.code.to_blit[t.bg]:rep(i)..e.code.to_blit[t.fg]:rep(o))end\
else if t.drag_texture then\
e.code.draw_box_tex(a,t.texture,t.positioning.x+t.positioning.width-o,t.positioning.y,o,t.positioning.height,t.bg,t.fg,t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)else\
e.code.draw_box_tex(a,t.texture,t.positioning.x+t.positioning.width-o,t.positioning.y,o,t.positioning.height,t.bg,t.fg,-o+1+t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)end\
for r=t.positioning.y,t.positioning.height+t.positioning.y-1 do\
a.setCursorPos(t.positioning.x,r)a.blit((\" \"):rep(i),(\"f\"):rep(i),e.code.to_blit[t.bg]:rep(i))end\
end end local\
o=math.floor(math.min(t.positioning.height,math.max(0,math.floor(t.positioning.height*(math.floor(t.value))/100))))local\
i=math.ceil(math.min(t.positioning.height,math.max(0,t.positioning.height-o)))if\
t.direction==\"top-down\"then if not t.texture then for\
d=t.positioning.y,t.positioning.y+t.positioning.height-1 do\
a.setCursorPos(t.positioning.x,d)if d<=o+t.positioning.y-0.5 then\
a.blit((\" \"):rep(t.positioning.width),(\"f\"):rep(t.positioning.width),e.code.to_blit[t.fg]:rep(t.positioning.width))else\
a.blit((\" \"):rep(t.positioning.width),(\"f\"):rep(t.positioning.width),e.code.to_blit[t.bg]:rep(t.positioning.width))end\
end else if not t.drag_texture then\
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y,t.positioning.width,o,t.bg,t.fg,t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)else\
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y,t.positioning.width,o,t.bg,t.fg,t.tex_offset_x,-o+1+t.tex_offset_y,t.canvas.texture_cache)end\
for l=t.positioning.y+o,t.positioning.y+t.positioning.height-1 do\
a.setCursorPos(t.positioning.x,l)a.blit((\" \"):rep(t.positioning.width),(\"f\"):rep(t.positioning.width),e.code.to_blit[t.bg]:rep(t.positioning.width))end\
end end local\
o=math.min(t.positioning.height,math.max(0,math.floor(t.positioning.height*(100-math.floor(t.value))/100)))local\
i=math.min(t.positioning.height,math.max(0,t.positioning.height-o))if\
t.direction==\"down-top\"then if not t.texture then for\
u=t.positioning.y,t.positioning.y+t.positioning.height-1 do\
a.setCursorPos(t.positioning.x,u)if u<=o+t.positioning.y-0.5 then\
a.blit((\" \"):rep(t.positioning.width),(\"f\"):rep(t.positioning.width),e.code.to_blit[t.bg]:rep(t.positioning.width))else\
a.blit((\" \"):rep(t.positioning.width),(\"f\"):rep(t.positioning.width),e.code.to_blit[t.fg]:rep(t.positioning.width))end\
end else if t.drag_texture then\
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y+o,t.positioning.width,i,t.bg,t.fg,t.tex_offset_x,t.tex_offset_y,t.canvas.texture_cache)else\
e.code.draw_box_tex(a,t.texture,t.positioning.x,t.positioning.y+o,t.positioning.width,i,t.bg,t.fg,t.tex_offset_x,-i+1+t.tex_offset_y,t.canvas.texture_cache)end\
for c=t.positioning.y,t.positioning.y+o-1 do\
a.setCursorPos(t.positioning.x,c)a.blit((\" \"):rep(t.positioning.width),(\"f\"):rep(t.positioning.width),e.code.to_blit[t.bg]:rep(t.positioning.width))end\
end end\
end",
  [ "objects/rectangle/logic" ] = "return\
function()end\
",
  [ "objects/ellipse/object" ] = "local e=require(\"api\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(a.symbols)~=\"table\"then o.symbols={}end if type(o.filled)~=\"boolean\"then\
o.filled=true end local i={name=o.name or e.uuid4(),positioning={x=o.x or\
1,y=o.y or 1,width=o.width or 1,height=o.height or 1},symbol=o.symbol\
or\" \",bg=o.background_color or colors.white,fg=o.text_color or\
colors.black,visible=o.visible,filled=o.filled,order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,}return i\
end",
} local e local t local function a(o)local i=files[o]local n=load(i)return
setfenv(n,t())end function e(s)if s=="cc.expect"then return
require("cc.expect")end if s=="cc.pretty"then return require("cc.pretty")end
local h=a(s:gsub("%.","/"))return h()end function t()local
r={fs={exists=function(d)return not not files[d]end,isDir=function(l)return not
files[l]end,open=function(u,c)if c=="r"then local
m=files[u]return{readAll=function()return m end,close=function()end}else return
fs.open(u,c)end end,list=function(f)local w={}local y={}for p,v in
pairs(files)do local b=p:gsub("^"..f.."/","")if p:find("^"..f.."/")then
w[(b.."/"):match("^([^/]*)/")]=true end end for g,k in pairs(w)do 
table.insert(y,g)end return y end}}for q,j in pairs(fs)do if not r.fs[q]then
r.fs[q]=j end end r=setmetatable(r,{__index=_ENV})r.require=e r.ORIGINAL=_ENV
return r end local x=a("init")return x()
