--[=====[
MIT License
Copyright (c) 2022 Oliver Caha
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]=====]


local files={
  object_loader = "local e=require(\"util\")_ENV=_ENV.ORIGINAL local function t(a)local\
o=type(a)local i if o==\"table\"then i={}for n,s in next,a,nil do if\
n==\"canvas\"then i.canvas=s else i[t(n)]=t(s)end end\
setmetatable(i,t(getmetatable(a)))else i=a end return i end\
return{main=function(h,r,d)local l=h local u={}local c=fs.list(\"animations\")for\
m,f in pairs(c)do d(\"Found animation \"..(f:match(\"(.*)%.\")or f),d.info)end\
d(\"\")local w=fs.list(\"objects\")for y,p in pairs(w)do\
d(\"loading object: \"..p,d.update)local\
v,b=pcall(require,\"objects.\"..p..\".object\")if v and type(b)==\"function\"then\
local g,k=pcall(require,\"objects.\"..p..\".logic\")local\
q,j=pcall(require,\"objects.\"..p..\".graphic\")if g and q\
and(type(k)==\"function\")and(type(j)==\"function\")then local\
x=fs.list(fs.combine(\"objects\",p))local z={}local E={}for T,A in pairs(x)do\
local O=A:match(\"(.*)%.\")or A if not(O==\"logic\"or O==\"graphic\"or\
O==\"object\")and(not fs.isDir(\"objects/\"..p..\"/\"..O))then local\
I,N=pcall(require,\"objects.\"..p..\".\"..O)if I then\
d(\"found custom object flag \\\"\"..O..\"\\\" for: \"..p,d.update)z[O]=require(\"objects.\"..p..\".\"..O)else\
d(\"bad object flag \"..N)end else if O==\"manipulators\"then\
d(\"found custom object manipulators for: \"..p,d.update)local\
S=fs.list(\"objects/\"..p..\"/manipulators\")for T,A in pairs(S)do local\
H,R=pcall(require,\"objects.\"..p..\".manipulators.\"..A:match(\"(.*)%.\")or A)if H\
then\
d(\"found custom object manipulator \\\"\"..A..\"\\\" for: \"..p,d.update)E[A:match(\"(.*)%.\")or\
A]=setmetatable({},{__call=function(D,...)return\
R(...)end,__index=R,__tostring=function()return\"GuiH.\"..p..\".manipulator\"end})else\
d(\"bad object manipulator \"..R)end end end end end local L={}for U,C in\
pairs(c)do local M=C:match(\"(.*)%.\")or C local\
F,W=pcall(require,\"animations/\"..M)if F then L[M]=W else\
d(\"Error loading animation: \"..M..\". \"..W)end end\
u[p]=setmetatable({},{__index=z,__tostring=function()return\"GuiH.element_builder.\"..p\
end,__call=function(Y,P)local l=b(l,P)if not(type(l.name)==\"string\")then\
l.name=e.uuid4()end if not(type(l.order)==\"number\")then l.order=1 end if\
not(type(l.logic_order)==\"number\")then l.logic_order=1 end if\
not(type(l.graphic_order)==\"number\")then l.graphic_order=1 end if\
not(type(l.react_to_events)==\"table\")then l.react_to_events={}end if\
not(type(l.btn)==\"table\")then l.btn={}end if\
not(type(l.visible)==\"boolean\")then l.visible=true end if\
not(type(l.reactive)==\"boolean\")then l.reactive=true end if\
_G.type(P.on_focus)==\"function\"then l.on_focus=P.on_focus end if\
type(l.positioning)==\"table\"then if P.w and not P.width then\
l.positioning.width=P.w end if P.h and not P.height then\
l.positioning.height=P.h end end r[p][l.name]=l local V=l local\
B={finish=function()return V end}local G={finish=function()return V end}local\
function K(Q,J,l,X)local function\
Z(et,tt,at)et[tt]=setmetatable({},{__call=function(Y,ot,it)if type(ot)~=at then\
error(\"Types are immutable with setters\",2)end if h.debug then\
d(\"Modified \\\"\"..tt..\"\\\" of \"..V.name)end l[tt]=ot return it and Q or B\
end})end local function nt(st,ht)st[ht]=setmetatable({},{__call=function()if\
h.debug then d(\"Read \\\"\"..ht..\"\\\" of \"..V.name)end return l[ht]end})end for\
rt,dt in pairs(l)do local lt=rt~=\"canvas\"and\
rt~=\"parent\"Z(Q,rt,type(dt))nt(J,rt)if type(dt)==\"table\"and X then if not\
Q[rt]then Q[rt]={}end if not J[rt]then J[rt]={}end K(Q[rt],J[rt],dt,lt)end end\
end K(B,G,l,true)local ut=t(E)or{}local ct={}local mt=false for y,p in\
pairs(ut)do ct[y]=function(...)return p(l,...)end mt=true end if mt then\
d(\"Finished attaching manipulators to creator.\",d.info)end local ft={}local\
wt=setmetatable({},{__call=function(yt,pt,vt)if l.positioning and\
l.positioning.width and l.positioning.height then\
l.positioning.width,l.positioning.height=pt,vt return true else return false\
end end})local bt={}for gt,kt in pairs(L)do if l.positioning and\
l.positioning.x and l.positioning.y then\
ft[gt]=function(qt,jt,xt,zt,Et,Tt)zt=zt or l.positioning.x Et=Et or\
l.positioning.y jt=jt or zt xt=xt or Et Tt=Tt or 0.05 return\
h.async(function()for At=0.05*(Tt/0.05),qt+Tt,Tt do local\
Ot=math.floor(e.math.lerp(zt,jt,kt(e.math.lerp,At/qt))+0.5)local\
It=math.floor(e.math.lerp(Et,xt,kt(e.math.lerp,At/qt))+0.5)l.positioning.x=Ot\
l.positioning.y=It sleep(Tt)end end)end end if l.positioning and\
l.positioning.width and l.positioning.height then\
wt[gt]=function(Nt,St,Ht,Rt,Dt,Lt)Rt=Rt or l.positioning.width or 1 Dt=Dt or\
l.positioning.height or 1 St=St or Rt Ht=Ht or Dt Lt=Lt or 0.05 return\
h.async(function()for Ut=0.05*(Lt/0.05),Nt+Lt,Lt do local\
Ct=math.floor(e.math.lerp(Rt,St,kt(e.math.lerp,Ut/Nt))+0.5)local\
Mt=math.floor(e.math.lerp(Dt,Ht,kt(e.math.lerp,Ut/Nt))+0.5)l.positioning.width=Ct\
l.positioning.height=Mt sleep(Lt)end end)end end bt[gt]=function(Ft,Wt,Yt,Pt)if\
l.text then Pt=Pt or 0.05 return h.async(function()for\
Vt=0.05*(Pt/0.05),Ft+Pt,Pt do local\
Bt=math.floor(e.math.lerp(0,#Wt,kt(e.math.lerp,Vt/Ft))+0.5)l.text.text=Wt:sub(0,Bt)if\
type(Yt)==\"function\"then Yt(l)end sleep(Pt)end end)end end\
setmetatable(ft,{__call=function(Gt,...)ft.linear(...)end,__index={text=bt,reposition=ft,move=ft,resize=wt}})end\
ct.animate=ft ct.resize=wt ct.logic=k ct.graphic=j ct.set=B ct.get=G\
ct.kill=function()if r[p][l.name]then r[p][l.name]=nil if h.debug then\
d(\"killed \"..p..\" > \"..l.name,d.warn)end return true else if h.debug then\
d(\"tried to manipulate dead object.\",d.error)end return\
false,\"object no longer exist\"end end ct.get_position=function()if\
r[p][l.name]then if l.positioning then return l.positioning else return\
false,\"object doesnt have positioning information\"end else if h.debug then\
d(\"tried to manipulate dead object.\",d.error)end return\
false,\"object no longer exist\"end end ct.replicate=function(Kt)Kt=Kt or\
e.uuid4()if r[p][l.name]then if Kt==l.name then\
return\"name of copy cannot be the same!\"else if h.debug then\
d(\"Replicated \"..p..\" > \"..l.name..\" as \"..p..\" > \"..Kt,d.info)end local\
Qt=t(r[p][l.name])r[p][Kt or\"\"]=Qt Qt.name=Kt return Qt,true end else if\
h.debug then d(\"tried to manipulate dead object.\",d.error)end return\
false,\"object no longer exist\"end end ct.isolate=function()if r[p][l.name]then\
local l=t(r[p][l.name])if h.debug then\
d(\"isolated \"..p..\" > \"..l.name,d.info)end return{parse=function(Jt)if h.debug\
then d(\"parsed \"..p..\" > \"..l.name,d.info)end if l then local Jt=Jt or l.name\
if r[p][Jt]then r[p][Jt]=nil end r[p][Jt]=l return r[p][Jt]else return\
false,\"object no longer exist\"end end,get=function()if l then if h.debug then\
d(\"returned \"..p..\" > \"..l.name,d.info)end return l else return\
false,\"object no longer exist\"end end,clear=function()if h.debug then\
d(\"Removed copied object \"..p..\" > \"..l.name,d.info)end l=nil end,}else if\
h.debug then d(\"tried to manipulate dead object.\",d.error)end return\
false,\"object no longer exist\"end end ct.cut=function()if r[p][l.name]then\
local l=t(r[p][l.name])r[p][l.name]=nil if h.debug then\
d(\"cut \"..p..\" > \"..l.name,d.info)end return{parse=function()if l then if\
h.debug then d(\"parsed \"..p..\" > \"..l.name,d.info)end if r[p][l.name]then\
r[p][l.name]=nil end r[p][l.name]=l return r[p][l.name]else return\
false,\"object no longer exist\"end end,get=function()if h.debug then\
d(\"returned \"..p..\" > \"..l.name,d.info)end return l end,clear=function()if\
h.debug then d(\"Removed copied object \"..p..\" > \"..l.name,d.info)end l=nil\
end}else if h.debug then d(\"tried to manipulate dead object.\",d.error)end\
return false,\"object no longer exist\"end end ct.destroy=ct.kill\
ct.murder=ct.destroy ct.copy=ct.isolate if not type(ct.logic)==\"function\"then\
d(\"object \"..p..\" has invalid logic.lua\",d.error)return false end if not\
type(ct.graphic)==\"function\"then\
d(\"object \"..p..\" has invalid graphic.lua\",d.error)return false end\
setmetatable(l,{__index=ct,__tostring=function()return\"GuiH.element.\"..p..\".\"..l.name\
end})if l.positioning then\
setmetatable(l.positioning,{__tostring=function()return\"GuiH.element.position\"end})end\
l.canvas=h d(\"created new \"..p..\" > \"..l.name,d.info)d:dump()return l end})else\
if not g and q then d(p..\" is missing an logic file !\",d.error)end if not q and\
g then d(p..\" is missing an graphic file !\",d.error)end if not g and not q then\
d(p..\" is missing logic and graphic file !\",d.error)end if g\
and(type(k)~=\"function\")then d(p..\" has an invalid logic file !\",d.error)end if\
q and(type(j)~=\"function\")then\
d(p..\" has an invalid graphic file !\",d.error)end if q and g\
and(type(j)~=\"function\")and(type(k)~=\"function\")then\
d(p..\" has an invalid logic and graphic file !\",d.error)end end else if v and\
not(type(b)==\"function\")then d(p..\" has invalid object file!\",d.error)else\
d(p..\" is missing an object file !\",d.error)end end end return u\
end,types=fs.list(\"objects\")}",
  [ "apis/log" ] = "local\
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
  [ "objects/group/graphic" ] = "return function(e)local t=e.last_known_position local a=e.positioning if\
t.x~=a.x or t.y~=a.y or t.width~=a.width or t.height~=a.height then\
e.window.reposition(a.x,a.y,a.width,a.height)e.gui.w,e.gui.width=a.width,a.width\
e.gui.h,e.gui.height=a.height,a.height\
e.last_known_position={x=a.x,y=a.y,width=a.width,height=a.height}end\
e.window.redraw()end",
  [ "objects/script/graphic" ] = "return\
function(e,t)e.graphic(e,t)end\
",
  [ "animations/ease_in_expo" ] = "return function(e,t)return t==0 and 0 or\
2^(10*t-10)end\
",
  [ "apis/pixelbox" ] = "local e=require(\"graphic_handle\")local t=require(\"util\")local\
a=require(\"cc.expect\").expect local o=require(\"core.algo\")local i={}local\
n={}function i.INDEX_SYMBOL_CORDINATION(s,h,r,d)s[h+r*2-2]=d return s end\
function n:within(l,u)return l>0 and u>0 and l<=self.width*2 and\
u<=self.height*3 end function\
n:push_updates()i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")self.symbols=t.tables.createNDarray(2)self.lines=t.create_blit_array(self.height)getmetatable(self.symbols).__tostring=function()return\"PixelBOX.SYMBOL_BUFFER\"end\
setmetatable(self.lines,{__tostring=function()return\"PixelBOX.LINE_BUFFER\"end})for\
c,m in pairs(self.CANVAS)do for f,w in pairs(m)do local y=math.ceil(f/2)local\
p=math.ceil(c/3)local v=(f-1)%2+1 local b=(c-1)%3+1\
self.symbols[p][y]=i.INDEX_SYMBOL_CORDINATION(self.symbols[p][y],v,b,w)end end\
for g,k in pairs(self.symbols)do for q,j in ipairs(k)do local\
x,z,E=e.code.build_drawing_char(j)self.lines[g]={self.lines[g][1]..x,self.lines[g][2]..e.code.to_blit[z],self.lines[g][3]..e.code.to_blit[E]}end\
end end function\
n:get_pixel(T,A)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")a(1,T,\"number\")a(2,A,\"number\")assert(self.CANVAS[A]and\
self.CANVAS[A][T],\"Out of range\")return self.CANVAS[A][T]end function\
n:clear(O)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")a(1,O,\"number\")self.CANVAS=t.tables.createNDarray(2)for\
I=1,self.height*3 do for N=1,self.width*2 do self.CANVAS[I][N]=O end end\
getmetatable(self.CANVAS).__tostring=function()return\"PixelBOX_SCREEN_BUFFER\"end\
end function\
n:draw()i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")if\
not self.lines then error(\"You must push_updates in order to draw\",2)end for\
S,H in ipairs(self.lines)do\
self.term.setCursorPos(1,S)self.term.blit(table.unpack(H))end end function\
n:set_pixel(R,D,L,U)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")a(1,R,\"number\")a(2,D,\"number\")a(3,L,\"number\")i.ASSERT(R>0\
and R<=self.width*2,\"Out of range\")i.ASSERT(D>0 and\
D<=self.height*3,\"Out of range\")U=U or 1 local C=(U-1)/2\
self:set_box(math.ceil(R-C),math.ceil(D-C),R+U-1,D+U-1,L,true)end function\
n:set_box(M,F,W,Y,P,V)if not V then\
i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")a(1,M,\"number\")a(2,F,\"number\")a(3,W,\"number\")a(4,Y,\"number\")a(5,P,\"number\")end\
for B=F,Y do for G=M,W do if self:within(G,B)then self.CANVAS[B][G]=P end end\
end end function n:set_ellipse(K,Q,J,X,Z,et,tt,at)if not at then\
i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")a(1,K,\"number\")a(2,Q,\"number\")a(3,J,\"number\")a(4,X,\"number\")a(5,Z,\"number\")a(6,et,\"boolean\",\"nil\")end\
tt=tt or 1 local ot=(tt-1)/2 if type(et)~=\"boolean\"then et=true end local\
it=o.get_elipse_points(J,X,K,Q,et)for nt,st in ipairs(it)do if\
self:within(st.x,st.y)then\
self:set_box(math.ceil(st.x-ot),math.ceil(st.y-ot),st.x+tt-1,st.y+tt-1,Z,true)end\
end end function\
n:set_circle(ht,rt,dt,lt,ut,ct)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")a(1,ht,\"number\")a(2,rt,\"number\")a(3,dt,\"number\")a(4,lt,\"number\")a(5,ut,\"boolean\",\"nil\")self:set_ellipse(ht,rt,dt,dt,lt,ut,ct,true)end\
function\
n:set_triangle(mt,ft,wt,yt,pt,vt,bt,gt,kt)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")a(1,mt,\"number\")a(2,ft,\"number\")a(3,wt,\"number\")a(4,yt,\"number\")a(5,pt,\"number\")a(6,vt,\"number\")a(7,bt,\"number\")a(8,gt,\"boolean\",\"nil\")kt=kt\
or 1 local qt=(kt-1)/2 if type(gt)~=\"boolean\"then gt=true end local jt if gt\
then\
jt=o.get_triangle_points(vector.new(mt,ft),vector.new(wt,yt),vector.new(pt,vt))else\
jt=o.get_triangle_outline_points(vector.new(mt,ft),vector.new(wt,yt),vector.new(pt,vt))end\
for xt,zt in ipairs(jt)do if self:within(zt.x,zt.y)then\
self:set_box(math.ceil(zt.x-qt),math.ceil(zt.y-qt),zt.x+kt-1,zt.y+kt-1,bt,true)end\
end end function\
n:set_line(Et,Tt,At,Ot,It,Nt)i.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")a(1,Et,\"number\")a(2,Tt,\"number\")a(3,At,\"number\")a(4,Ot,\"number\")a(5,It,\"number\")Nt=Nt\
or 1 local St=(Nt-1)/2 local Ht=o.get_line_points(Et,Tt,At,Ot)for Rt,Dt in\
ipairs(Ht)do if self:within(Dt.x,Dt.y)then\
self:set_box(math.ceil(Dt.x-St),math.ceil(Dt.y-St),Dt.x+Nt-1,Dt.y+Nt-1,It,true)end\
end end function i.ASSERT(Lt,Ut)if not Lt then error(Ut,3)end return Lt end\
function\
i.new(Ct,Mt,Ft)a(1,Ct,\"table\")a(2,Mt,\"number\",\"nil\")a(3,Ft,\"table\",\"nil\")local\
Mt=Mt or Ct.getBackgroundColor()or colors.black local Wt={}local\
Yt,Pt=Ct.getSize()Wt.term=setmetatable(Ct,{__tostring=function()return\"term_object\"end})Wt.CANVAS=t.tables.createNDarray(2,Ft)getmetatable(Wt.CANVAS).__tostring=function()return\"PixelBOX_SCREEN_BUFFER\"end\
Wt.width=Yt Wt.height=Pt for Vt=1,Pt*3 do for Bt=1,Yt*2 do Wt.CANVAS[Vt][Bt]=Mt\
end end return setmetatable(Wt,{__index=n})end return\
i",
  [ "objects/group/logic" ] = "return\
function(e,t)e.bef_draw(e,t)end\
",
  [ "objects/script/logic" ] = "return\
function(e,t)e.code(e,t)end\
",
  [ "animations/ease_in_out" ] = "return function(e,t)return\
e(t^3,1-((1-t)^3),t)end\
",
  [ "objects/group/object" ] = "local e=require(\"util\")local t=require(\"core.gui_object\")return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(o.reactive)~=\"boolean\"then o.reactive=true end if\
type(o.blocking)~=\"boolean\"then o.blocking=true end if\
type(o.always_update)~=\"boolean\"then o.always_update=false end local\
i={name=o.name or e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or\
0,height=o.height or 0},visible=o.visible,last_known_position={x=o.x or 1,y=o.y\
or 1,width=o.width or 0,height=o.height or 0},order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,bef_draw=o.bef_draw\
or function()end,blocking=o.blocking,always_update=o.always_update}local\
n=window.create(a.term_object,i.positioning.x,i.positioning.y,i.positioning.width,i.positioning.height)i.gui=t(n,a.term_object,a.log)i.window=n\
i.gui.inherit(a,i)return i\
end",
  [ "apis/termtools" ] = "local function e(t,...)local a={...}local o={}for i,n in pairs(a[1])do\
o[i]=function(...)local s=table.pack(t[i](...))for h,r in pairs(a)do\
s=table.pack(r[i](...))end return table.unpack(s,1,s.n or 1)end end return o\
end local function d(...)local l={...}local u={}for c,m in pairs(l[1])do\
u[c]=function(...)local f={}for w,y in pairs(l)do f=table.pack(y[c](...))end\
return table.unpack(f,1,f.n or 1)end end return u end\
return{mirror=e,make_shared=d}",
  [ "animations/ease_in_out_back" ] = "return function(e,t)local a=1.70158;local o=a*1.525;return t<0.5\
and((2*t)^2*((o+1)*2*t-o))/2 or((2*t-2)^2*((o+1)*(t*2-2)+o)+2)/2\
end",
  [ "apis/sevensh" ] = "local\
e={normal={1021,1007,1021,881,2,925,893,894,1021,325,2,1017,877,879,1021,size=3,conversion={}}}if\
not fs.exists(\"GuiH/apis/fonts.7sh\")then fs.makeDir(\"GuiH/apis/fonts.7sh\")end\
for t,a in pairs(fs.list(\"GuiH/apis/fonts.7sh\"))do local\
o=dofile(\"GuiH/apis/fonts.7sh/\"..a)if next(o or{})then for t,i in pairs(o)do\
e[a..\".\"..t]=i end end end local n={}function n:update()local\
s,h=self.term.getBackgroundColor(),self.term.getTextColor()for r,d in\
ipairs(e[self.font])do local l=self.value local\
u=bit32.band(bit32.rshift(d,(e[self.font].conversion or{})[l]or\
l),1)self.term.setCursorPos(((r-1)%e[self.font].size)+1+self.pos.x,math.ceil(r/e[self.font].size)+self.pos.y)if\
u==1 then\
self.term.setBackgroundColor(self.bg)self.term.setTextColor(self.tg)self.term.write(self.symbol)else\
self.term.setBackgroundColor(s)self.term.setTextColor(h)self.term.write(\" \")end\
end self.term.setTextColor(h)self.term.setBackgroundColor(s)end function\
n:reposition(c,m)self.pos=vector.new(c or 0,m or 0)end function\
n:set_background(f)self.bg=f or colors.white end function\
n:set_color(w)self.tg=w or colors.black end function\
n:set_symbol(y)self.symbol=y or\" \"end function n:set_value(p)self.value=p or 0\
end function n:set_font(v)if e[v or\"normal\"]then self.font=v or\"normal\"end end\
function n:set_term(b)if type(b)==\"table\"then self.term=b end end local\
function g(k,q,j,x,z,E,T,A)if type(k)~=\"table\"then\
error(\"create_display needs an term object as its argument input to work!\",2)end\
return setmetatable({pos=vector.new(q,j),value=x or 0,symbol=T or\" \",bg=E or\
colors.white,tg=A or colors.black,font=z or\"normal\",term=k},{__index=n})end\
return{create_display=g}",
  [ "animations/ease_in_out_cubic" ] = "return function(e,t)return t<0.5 and 4*t^3 or 1-(-2*t+2)^3/2\
end\
",
  [ "objects/button/logic" ] = "local e=require(\"util\")return function(t,a)if\
e.is_within_field(a.x,a.y,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)then\
t.on_click(t,a)end\
end",
  [ "apis/text" ] = "local e=require(\"cc.expect\").expect local function\
t(a,o,i)e(1,a,\"string\")e(2,o,\"number\")local n,s,h={},{},\"\"for r in\
a:gmatch(\"[%w%p%a%d]+%s?\")do table.insert(n,r)end if o==0 then return\"\"end\
while h<a and not(#n==0)do local d=\"\"while n~=0 do local l=n[1]if not l then\
break end if#l>o then local u=l:match(\"% +$\")or\"\"if not((#l-#u)<=o)then local\
c,m=l:sub(1,o),l:sub(o+1)if#(d..c)>o then n[1]=t(c..m,o,true)break end\
d,n[1],l=d..c,m,m else l=l:sub(1,#l-(#l-o))end end if#(d..l)<=o then d=d..l\
table.remove(n,1)else break end end table.insert(s,d)end return\
table.concat(s,i and\"\"or\"\\n\")end local function\
f(w,y)e(1,w,\"string\")e(2,y,\"number\")local p={}for v=1,#w,y do\
p[#p+1]=w:sub(v,v+y-1)end return p end local function\
b(g,k)e(1,g,\"string\")e(2,k,\"number\")local q=g:sub(1,k)if#q<k then\
q=q..(\" \"):rep(k-#q)end return q end local function j(x)e(1,x,\"table\")return\
table.concat(x,\"\\n\")end\
return{wrap=t,cut_parts=f,ensure_size=b,newline=j}",
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
  [ "objects/scrollbox/graphic" ] = "return\
function()end\
",
  [ "animations/ease_in_out_elastic" ] = "return function(e,t)local a=(2*math.pi)/4.5 return t==0 and 0 or(t==1 and 1\
or(t<0.5 and-(2^(20*t-10)*math.sin((20*t-11.125)*a))/2\
or(2^(-20*t+10)*math.sin((20*t-11.125)*a))/2+1))end",
  [ "objects/inputbox/logic" ] = "local e=require(\"util\")local function t(a)return\
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
U=D.canvas.term_object if L.name==\"mouse_click\"or L.name==\"monitor_touch\"then\
if\
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
D.insert=not D.insert elseif L.key==keys.down then if D.autoc.sorted then if\
D.autoc.selected+1<=#D.autoc.sorted then D.autoc.selected=D.autoc.selected+1\
end end elseif L.key==keys.up then if D.autoc.sorted then if D.autoc.selected>1\
then D.autoc.selected=D.autoc.selected-1 end end elseif L.key==keys.enter and\
D.selected then local\
K={}D.input:gsub(\"%S+\",function(Q)table.insert(K,Q)end)D.on_enter(D,L,K)end end\
if L.name==\"paste\"then D.autoc.selected=1 D.input=C..L.text..M\
D.cursor_pos=D.cursor_pos+#L.text D.on_change_input(D,L,D.input)end\
end",
  [ "animations/ease_out_back" ] = "return function(e,t)local a=1.70158;local o=a+1 return 1+o*(t-1)^3+a*(t-1)^2\
end\
",
  [ "animations/ease_in_out_expo" ] = "return function(e,t)return t==0 and 0 or(t==1 and 1 or(t<0.5 and 2^(20*t-10)/2\
or(2-2^(-20*t+10))/2))end\
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
  [ "objects/inputbox/object" ] = "local e=require(\"util\")return function(t,a)if type(a.visible)~=\"boolean\"then\
a.visible=true end if type(a.reactive)~=\"boolean\"then a.reactive=true end if\
not a.autoc then a.autoc={}end if type(a.autoc.put_space)~=\"boolean\"then\
a.autoc.put_space=true end if type(a.blocking)~=\"boolean\"then a.blocking=true\
end if type(a.always_update)~=\"boolean\"then a.always_update=false end local\
o={name=a.name or\
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
t.term_object.getTextColor(),current=\"\",selected=1,put_space=a.autoc.put_space},blocking=a.blocking,always_update=a.always_update}o.cursor_x=o.positioning.x\
return o\
end",
  [ "animations/ease_out_cubic" ] = "return function(e,t)return 1-(1-t)^3\
end\
",
  [ "animations/ease_in_out_quad" ] = "return function(e,t)return t<0.5 and 2*t^2 or 1-(-2*t+2)^2/2\
end\
",
  [ "core/algo" ] = "local e=require(\"util\")_ENV=_ENV.ORIGINAL local function t(a,o,i,n,s)local\
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
  [ "objects/circle/graphic" ] = "local e=require(\"core.algo\")local t=require(\"graphic_handle\").code local\
a=require(\"util\")return function(o)local i=o.canvas.term_object local n={}local\
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
  [ "animations/ease_out_elastic" ] = "return function(e,t)local a=(2*math.pi)/3;return t==0 and 0 or(t==1 and 1\
or(2^(-10*t)*math.sin((t*10-0.75)*a)+1))end\
",
  [ "animations/ease_in_out_quart" ] = "return function(e,t)return t<0.5 and 8*t^4 or 1-(-2*t+2)^4/2\
end\
",
  [ "animations/ease_in" ] = "return function(e,t)return t*t*t\
end\
",
  [ "core/blbfor" ] = "_ENV=_ENV.ORIGINAL local e=require(\"cc.expect\").expect local t=0x0A local\
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
  [ "objects/circle/logic" ] = "return\
function()end\
",
  [ "animations/ease_out_expo" ] = "return function(e,t)return t==1 and 1 or\
1-2^(-10*t)end\
",
  [ "animations/ease_in_out_quint" ] = "return function(e,t)return t<0.5 and 16*t^5 or 1-(-2*t+2)^5/2\
end\
",
  [ "objects/switch/logic" ] = "local e=require(\"util\")return function(t,a)if\
e.is_within_field(a.x,a.y,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)then\
t.value=not t.value t.on_change_state(t,a)end\
end",
  [ "objects/circle/object" ] = "local e=require(\"util\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(a.symbols)~=\"table\"then o.symbols={}end if type(o.filled)~=\"boolean\"then\
o.filled=true end if type(o.blocking)~=\"boolean\"then o.blocking=false end if\
type(o.always_update)~=\"boolean\"then o.always_update=true end local\
i={name=o.name or e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,radius=o.radius\
or 3},symbol=o.symbol or\" \",bg=o.background_color or\
colors.white,fg=o.text_color or\
colors.black,visible=o.visible,filled=o.filled,order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,blocking=o.blocking,always_update=o.always_update}return\
i\
end",
  [ "animations/ease_in_back" ] = "return function(e,t)local a=1.70158;local o=a+1 return o*t^3-a*t^2\
end\
",
  [ "animations/ease_in_out_sine" ] = "return function(e,t)return-(math.cos(math.pi*t)-1)/2\
end\
",
  [ "core/gui_object" ] = "local e=require(\"object_loader\")local t=require(\"graphic_handle\")local\
a=require(\"core.update\")local o=require(\"util\")_ENV=_ENV.ORIGINAL local\
function i(n,s,h,r,d)local l={}local u=\"term_object\"local c=s local function\
m(f)r,d=0,0 pcall(function()local function w(y)local\
p,v=y.getPosition()r=r+(p-1)d=d+(v-1)local\
b,g=debug.getupvalue(y.reposition,5)if g.reposition and g~=term.current()then\
c=g w(g)elseif g~=nil then c=g end end w(n)end)if f then f.event_offset_x=r\
f.event_offset_y=d end end if not r or not d then m()end\
pcall(function()u=peripheral.getType(c)end)for k,q in pairs(e.types)do\
l[q]={}end local j,x=n.getSize()local\
z={term_object=n,term=n,gui=l,update=a,visible=true,id=o.uuid4(),task_schedule={},update_delay=0.05,held_keys={},log=h,task_routine={},paused_task_routine={},w=j,h=x,width=j,height=x,event_listeners={},paused_listeners={},background=n.getBackgroundColor(),cls=false,key={},texture_cache={},debug=false,event_offset_x=r,event_offset_y=d,dynamic_positions={},paused_dynamic_positions={}}z.inherit=function(E,T)z.api=E.api\
z.preset=E.preset z.async=E.async z.schedule=E.schedule\
z.add_listener=E.add_listener z.debug=E.debug z.parent=T end z.elements=z.gui\
z.calibrate=function()m(z)end z.getSize=function()return z.w,z.h end local\
A={[\"center\"]=true,[\"top_left\"]=true,[\"top_right\"]=true,[\"bottom_left\"]=true,[\"bottom_right\"]=true}z.create_position=function(O,I,j,x,N,S,H,R,D)local\
L=o.uuid4()O,I=tostring(O),tostring(I)j,x=tostring(j),tostring(x)S=S or 0 H=H\
or 0 R=R or 0 D=D or 0 N=A[N]and N or\"center\"local U,C=O:gsub(\"%%\",\"\")local\
M,F=I:gsub(\"%%\",\"\")local W,Y=j:gsub(\"%%\",\"\")local P,V=x:gsub(\"%%\",\"\")local\
B={}local function G()local K=tonumber(U)local Q=tonumber(M)local\
J=tonumber(W)local X=tonumber(P)h(z.h)if C>0 then K=z.w*(K/100)end if F>0 then\
Q=z.h*(Q/100)end if Y>0 then J=z.w*(J/100)end if V>0 then X=z.h*(X/100)end if\
N==\"center\"then if C>0 then K=K-J/2+1 end if F>0 then Q=Q-X/2+1 end elseif\
N==\"top_right\"then if C>0 then K=K-J+1 end elseif N==\"bottom_left\"then if F>0\
then Q=Q-X+1 end elseif N==\"bottom_right\"then if C>0 then K=K-J+1 end if F>0\
then Q=Q-X+1 end end B.x=math.floor(K+0.5)+S B.y=math.floor(Q+0.5)+H\
B.width=J+R B.height=X+D end G()if z.debug then\
h(\"Made new dynamic position \"..L)end z.dynamic_positions[L]=G return B end\
z.position=z.create_position z.relative_to=function(Z,et,tt,j,x,at,ot)local\
it=o.uuid4()j,x=tostring(j),tostring(x)et=et or 0 tt=tt or 0 at=A[at]and at\
or\"centered\"ot=A[ot]and ot or\"centered\"local nt,st=j:gsub(\"%%\",\"\")local\
ht,rt=x:gsub(\"%%\",\"\")local dt={}local function lt()local ut=Z.positioning.x or\
1 local ct=Z.positioning.y or 1 local mt=Z.positioning.width or 1 local\
ft=Z.positioning.height or 1 local wt=tonumber(nt)local yt=tonumber(ht)if not\
next(dt)then dt={width=wt,height=yt}end if st>0 then wt=z.w*(wt/100)end if rt>0\
then yt=z.h*(yt/100)end if at==\"centered\"then ut=ut+(mt/2)+0.5 ct=ct+(ft/2)+0.5\
elseif at==\"top_right\"then ut=ut+mt ct=ct+1 elseif at==\"bottom_left\"then\
ut=ut+1 ct=ct+ft elseif at==\"bottom_right\"then ut=ut+mt ct=ct+ft elseif\
at==\"top_left\"then ut=ut+1 ct=ct+1 end if ot==\"centered\"then ut=ut-dt.width/2\
ct=ct-dt.height/2 elseif ot==\"top_right\"then ut=ut-dt.width+0.5 ct=ct-0.5\
elseif ot==\"bottom_left\"then ut=ut-0.5 ct=ct-dt.height+0.5 elseif\
ot==\"bottom_right\"then ut=ut-dt.width+0.5 ct=ct-dt.height+0.5 elseif\
ot==\"top_left\"then ut=ut-0.5 ct=ct-0.5 end dt.x=math.floor(ut-0.5)+et\
dt.y=math.floor(ct-0.5)+tt dt.width=wt dt.height=yt end lt()if z.debug then\
h(\"Made new relative position \"..it)end z.dynamic_positions[it]=lt return dt\
end h(\"set up updater\",h.update)local function\
pt(vt,bt,gt,kt,qt,jt,xt,zt,Et,Tt,At)return\
a(z,vt,bt,gt,kt,qt,jt,xt,zt,Et,Tt,At)end local Ot local It=false\
z.schedule=function(Nt,St,Ht,Rt)local Dt=o.uuid4()if Rt or z.debug then\
h(\"created new thread: \"..tostring(Dt),h.info)end local Lt={}local\
Ut={c=coroutine.create(function()local Ct,Mt=pcall(function()if St then\
o.precise_sleep(St)end Nt(z,z.term_object)end)if not Ct then if Ht==true then\
Ot=Mt end Lt.err=Mt if Rt or z.debug then\
h(\"error in thread: \"..tostring(Dt)..\"\\n\"..tostring(Mt),h.error)h:dump()end end\
end),dbug=Rt}z.task_routine[Dt]=Ut local function Ft(...)local\
Wt=z.task_routine[Dt]or z.paused_task_routine[Dt]if Wt then local\
Yt,Ot=coroutine.resume(Wt.c,...)if not Yt then Lt.err=Ot if Rt or z.debug then\
h(\"task \"..tostring(Dt)..\" error: \"..tostring(Ot),h.error)h:dump()end end\
return true,Yt,Ot else if Rt or z.debug then\
h(\"task \"..tostring(Dt)..\" not found\",h.error)h:dump()end return false end end\
return setmetatable(Ut,{__index={kill=function()z.task_routine[Dt]=nil\
z.paused_task_routine[Dt]=nil if Rt or z.debug then\
h(\"killed task: \"..tostring(Dt),h.info)h:dump()end return true\
end,alive=function()local Pt=z.task_routine[Dt]or z.paused_task_routine[Dt]if\
not Pt then return false end return\
coroutine.status(Pt.c)~=\"dead\"end,step=Ft,update=Ft,pause=function()local\
Vt=z.task_routine[Dt]or z.paused_task_routine[Dt]if Vt then\
z.paused_task_routine[Dt]=Vt z.task_routine[Dt]=nil if Rt or z.debug then\
h(\"paused task: \"..tostring(Dt),h.info)h:dump()end return true else if Rt or\
z.debug then h(\"task \"..tostring(Dt)..\" not found\",h.error)h:dump()end return\
false end end,resume=function()local Bt=z.paused_task_routine[Dt]or\
z.task_routine[Dt]if Bt then z.task_routine[Dt]=Bt\
z.paused_task_routine[Dt]=nil if Rt or z.debug then\
h(\"resumed task: \"..tostring(Dt),h.info)h:dump()end return true else if Rt or\
z.debug then h(\"task \"..tostring(Dt)..\" not found\",h.error)h:dump()end return\
false end end,get_error=function()return Lt.err\
end,set_running=function(Gt,Rt)local Kt=z.task_routine[Dt]or\
z.paused_task_routine[Dt]local It=z.task_routine[Dt]~=nil if Kt then if It and\
Gt then return true end if not It and not Gt then return true end if It and not\
Gt then z.paused_task_routine[Dt]=Kt z.task_routine[Dt]=nil if Rt or z.debug\
then h(\"paused task: \"..tostring(Dt),h.info)h:dump()end return true end if not\
It and Gt then z.task_routine[Dt]=Kt z.paused_task_routine[Dt]=nil if Rt or\
z.debug then h(\"resumed task: \"..tostring(Dt),h.info)h:dump()end return true\
end end end},__tostring=function()return\"GuiH.SCHEDULED_THREAD.\"..Dt end})end\
z.async=z.schedule z.add_listener=function(Qt,Jt,Xt,Zt)if not\
_G.type(Jt)==\"function\"then return end if not(_G.type(Qt)==\"table\"or\
_G.type(Qt)==\"string\")then Qt={}end local ea=Xt or o.uuid4()local\
ta={filter=Qt,code=Jt}z.event_listeners[ea]=ta if Zt or z.debug then\
h(\"created event listener: \"..ea,h.success)h:dump()end return\
setmetatable(ta,{__index={kill=function()z.event_listeners[ea]=nil\
z.paused_listeners[ea]=nil if Zt or z.debug then\
h(\"killed event listener: \"..ea,h.success)h:dump()end\
end,pause=function()z.paused_listeners[ea]=ta z.event_listeners[ea]=nil if Zt\
or z.debug then h(\"paused event listener: \"..ea,h.success)h:dump()end\
end,resume=function()local ta=z.paused_listeners[ea]or z.event_listeners[ea]if\
ta then z.event_listeners[ea]=ta z.paused_listeners[ea]=nil if Zt or z.debug\
then h(\"resumed event listener: \"..ea,h.success)h:dump()end elseif Zt or\
z.debug then h(\"event listener not found: \"..ea,h.error)h:dump()end\
end},__tostring=function()return\"GuiH.EVENT_LISTENER.\"..ea end})end\
z.cause_exeption=function(aa)Ot=tostring(aa)end z.stop=function()It=false end\
z.kill=z.stop z.error=z.cause_exeption z.clear=function(oa)if oa or z.debug\
then h(\"clearing the gui..\",h.update)end local ia={}for na,sa in\
pairs(e.types)do ia[sa]={}end z.gui=ia z.elements=ia local\
ha=e.main(z,ia,h)z.create=ha z.new=ha end z.isHeld=function(...)local\
ra={...}local da,la=true,true for ua,ca in pairs(ra)do local\
ma=z.held_keys[ca]or{}if ma[1]then da=da and true la=la and ma[2]else return\
false,false,z.held_keys end end return da,la,z.held_keys end\
z.key.held=z.isHeld\
z.execute=setmetatable({},{__call=function(fa,wa,ya,pa,va)if It then\
h(\"Coulnt execute. Gui is already running\",h.error)h:dump()return false end\
Ot=nil It=true h(\"\")h(\"loading execute..\",h.update)local ba=z.term_object local\
ga local ka=ba.getBackgroundColor()local qa=coroutine.create(function()local\
ja,xa=pcall(function()ba.setVisible(true)pt(0)ba.redraw()while true do\
ba.setBackgroundColor(z.background or ka)ba.clear();(pa or\
function()end)(ba)local ga=a(z,nil,true,false,nil);(ya or\
function()end)(ba,ga);(va or function()end)(ba)end end)if not ja then Ot=xa\
h:dump()end end)h(\"created graphic routine 1\",h.update)local za=wa or\
function()end local function Ea()local Ta,Aa=pcall(za,ba)if not Ta then Ot=Aa\
h:dump()end end h(\"created custom updater\",h.update)local\
Oa=coroutine.create(function()while true do\
ba.setVisible(false)ba.setBackgroundColor(z.background or\
ka)ba.clear();z.update(0,true,nil,{type=\"mouse_click\",x=-math.huge,y=-math.huge,button=-math.huge});(va\
or\
function()end)(ba)ba.setVisible(true)ba.setVisible(false)sleep(math.max(z.update_delay,0.05))end\
end)h(\"created event listener handle\",h.update)local\
Ia=coroutine.create(function()local Na,Sa=pcall(function()while true do local\
Ha=table.pack(os.pullEventRaw())for Ra,Da in pairs(z.event_listeners)do local\
La=Da.filter if _G.type(La)==\"string\"then La={[Da.filter]=true}end if\
La[Ha[1]]or La==Ha[1]or(not next(La))then\
Da.code(table.unpack(Ha,_G.type(Da.filter)~=\"table\"and 2 or 1,Ha.n))end end end\
end)if not Na then Ot=Sa h:dump()end\
end)h(\"created graphic routine 2\",h.update)local\
Ua=coroutine.create(function()while true do for Ca,Ma in\
pairs(z.dynamic_positions)do Ma()end sleep(math.max(z.update_delay,0.05))end\
end)h(\"Created position updater\",h.update)local\
Fa=coroutine.create(function()while true do local Wa,Ya,Pa=os.pullEvent()if\
Wa==\"key\"then z.held_keys[Ya]={true,Pa}end if Wa==\"key_up\"then\
z.held_keys[Ya]=nil end end end)h(\"created key handler\")local\
Va=coroutine.create(Ea)coroutine.resume(Va)coroutine.resume(qa,\"mouse_click\",math.huge,-math.huge,-math.huge)coroutine.resume(qa,\"mouse_click\",math.huge,-math.huge,-math.huge)coroutine.resume(qa,\"mouse_click\",math.huge,-math.huge,-math.huge)coroutine.resume(Oa)coroutine.resume(Ua)h(\"\")h(\"Started execution..\",h.success)h(\"\")h:dump()while((coroutine.status(Va)~=\"dead\"or\
not(_G.type(wa)==\"function\"))and coroutine.status(qa)~=\"dead\"and Ot==nil)and It\
do local ga=table.pack(os.pullEventRaw())if o.events_with_cords[ga[1]]then\
ga[3]=ga[3]-(z.event_offset_x)ga[4]=ga[4]-(z.event_offset_y)end if\
ga[1]==\"terminate\"then Ot=\"Terminated\"break end if ga[1]~=\"guih_data_event\"then\
coroutine.resume(Ia,table.unpack(ga,1,ga.n))end\
coroutine.resume(Va,table.unpack(ga,1,ga.n))if ga[1]==\"key\"or\
ga[1]==\"key_up\"then coroutine.resume(Fa,table.unpack(ga,1,ga.n))end for Ba,Ga\
in pairs(z.task_routine)do if coroutine.status(Ga.c)~=\"dead\"then if\
Ga.filter==ga[1]or Ga.filter==nil then local\
Ka,Qa=coroutine.resume(Ga.c,table.unpack(ga,1,ga.n))if Ka then Ga.filter=Qa end\
end else z.task_routine[Ba]=nil z.task_schedule[Ba]=nil if Ga.dbug then\
h(\"Finished sheduled task: \"..tostring(Ba),h.success)end end end\
coroutine.resume(Ua,table.unpack(ga,1,ga.n))coroutine.resume(qa,table.unpack(ga,1,ga.n))coroutine.resume(Oa,table.unpack(ga,1,ga.n))local\
j,x=s.getSize()if j~=z.w or x~=z.h then if(ga[1]==\"monitor_resize\"and\
z.monitor==ga[2])or z.monitor==\"term_object\"then\
z.term_object.reposition(1,1,j,x)z.w,z.h=j,x z.width,z.height=j,x\
coroutine.resume(qa,\"mouse_click\",math.huge,-math.huge,-math.huge)end end end\
if Ot then z.last_err=Ot end ba.setVisible(true)if Ot then\
h(\"a Fatal error occured: \"..Ot..\" \"..debug.traceback(),h.fatal)else\
h(\"finished execution\",h.success)end h:dump()Ot=nil return z.last_err,true\
end,__tostring=function()return\"GuiH.main_gui_executor\"end})z.run=z.execute if\
u==\"monitor\"then\
h(\"Display object: monitor\",h.info)z.monitor=peripheral.getName(c)else\
h(\"Display object: term\",h.info)z.monitor=\"term_object\"end\
z.load_texture=function(Ja)h(\"Loading nimg texture.. \",h.update)local\
Xa=t.load_texture(Ja)return Xa end z.load_ppm_texture=function(Za,eo)local\
to,ao,oo=pcall(t.load_ppm_texture,z.term_object,Za,eo,h)if to then return ao,oo\
else h(\"Failed to load texture: \"..ao,h.error)end end\
z.load_cimg_texture=function(io)h(\"Loading cimg texture.. \",h.update)local\
no=t.load_cimg_texture(io)return no end\
z.load_blbfor_texture=function(so)h(\"Loading blbfor texture.. \",h.update)local\
ho,ro=t.load_blbfor_texture(so)return ho,ro end\
z.load_limg_texture=function(lo,uo,co)h(\"Loading limg texture.. \",h.update)local\
mo,fo=t.load_limg_texture(lo,uo,co)return mo,fo end\
z.load_limg_animation=function(wo,yo)h(\"Loading limg animation.. \",h.update)local\
po=t.load_limg_animation(wo,yo)return po end\
z.load_blbfor_animation=function(vo)h(\"Loading blbfor animation.. \",h.update)local\
bo=t.load_blbfor_animation(vo)return bo end\
z.set_event_offset=function(go,ko)z.event_offset_x,z.event_offset_y=go or\
z.event_offset_x,ko or z.event_offset_y end\
h(\"\")h(\"Starting creator..\",h.info)local qo=e.main(z,z.gui,h)z.create=qo\
z.new=qo h(\"\")z.update=pt\
h(\"loading text object...\",h.update)h(\"\")z.get_blit=function(jo,xo,zo)local Eo\
pcall(function()Eo={z.term_object.getLine(jo)}end)if not Eo then return false\
end return Eo[1]:sub(xo,zo),Eo[2]:sub(xo,zo),Eo[3]:sub(xo,zo)end\
z.text=function(To)To=To or{}if _G.type(To.centered)~=\"boolean\"then\
To.centered=false end local\
Ao=(_G.type(To.text)==\"string\")and(\"0\"):rep(#To.text)or(\"0\"):rep(13)local\
Oo=(_G.type(To.text)==\"string\")and(\"f\"):rep(#To.text)or(\"f\"):rep(13)if\
_G.type(To.blit)~=\"table\"then To.blit={Ao,Oo}end To.blit[1]=(To.blit[1]or\
Ao):lower()To.blit[2]=(To.blit[2]or\
Oo):lower()h(\"created new text object\",h.info)return setmetatable({text=To.text\
or\"<TEXT OBJECT>\",centered=To.centered,x=To.x or 1,y=To.y or\
1,offset_x=To.offset_x or 0,offset_y=To.offset_y or 0,blit=To.blit\
or{Ao,Oo},transparent=To.transparent,bg=To.bg,fg=To.fg,width=To.width,height=To.height},{__call=function(Io,No,So,Ho,j,x)So,Ho=So\
or Io.x,Ho or Io.y if Io.width then j=Io.width end if Io.height then\
x=Io.height end local Ro=No or z.term_object local Do if\
_G.type(So)==\"number\"and _G.type(Ho)==\"number\"then Do=1 end if\
_G.type(So)~=\"number\"then So=1 end if _G.type(Ho)~=\"number\"then Ho=1 end local\
Lo,Uo=So,Ho local Co={}for Mo in Io.text:gmatch(\"[^\\n]+\")do\
table.insert(Co,Mo)end if Io.centered then Uo=Uo-#Co/2 else Uo=Uo-1 end for\
Fo=1,#Co do local Wo=Co[Fo]Uo=Uo+1 if Io.centered then local Yo=(x or\
z.h)/2-0.5 local Po=math.ceil(((j or\
z.w)/2)-(#Wo/2)-0.5)Ro.setCursorPos(Po+Io.offset_x+Lo,Yo+Io.offset_y+Uo)So,Ho=Po+Io.offset_x+Lo,Yo+Io.offset_y+Uo\
else Ro.setCursorPos((Do or Io.x)+Io.offset_x+Lo-1,(Do or\
Io.y)+Io.offset_y+Uo-1)So,Ho=(Do or Io.x)+Io.offset_x+Lo-1,(Do or\
Io.y)+Io.offset_y+Uo-1 end if Io.transparent==true then local Vo=-1 if So<1\
then Vo=math.abs(math.min(So+1,3)-2)Ro.setCursorPos(1,Ho)So=1\
Wo=Wo:sub(Vo+1)end local Ao,Oo=table.unpack(Io.blit)if Io.bg then\
Oo=t.code.to_blit[Io.bg]:rep(#Wo)end if Io.fg then\
Ao=t.code.to_blit[Io.fg]:rep(#Wo)end local Bo\
pcall(function()_,_,Bo=Ro.getLine(math.floor(Ho))end)if not Bo then return end\
local Go=Bo:sub(So,math.min(So+#Wo-1,z.w))local Ko=#Wo-#Go-1 if#Ao~=#Wo then\
Ao=(\"0\"):rep(#Wo)end\
pcall(Ro.blit,Wo,Ao:sub(math.min(So,1)),Go..Oo:sub(#Oo-Ko,#Oo))else local\
Ao,Oo=table.unpack(Io.blit)if Io.bg then Oo=t.code.to_blit[Io.bg]:rep(#Wo)end\
if Io.fg then Ao=t.code.to_blit[Io.fg]:rep(#Wo)end if#Ao~=#Wo then\
Ao=(\"0\"):rep(#Wo)end if#Oo~=#Wo then Oo=(\"f\"):rep(#Wo)end\
pcall(Ro.blit,Wo,Ao,Oo)end end\
end,__tostring=function()return\"GuiH.primitive.text\"end})end return z end\
return\
i",
  [ "objects/switch/object" ] = "local e=require(\"util\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end if\
type(a.blocking)~=\"boolean\"then a.blocking=true end if\
type(a.always_update)~=\"boolean\"then a.always_update=false end local\
o={name=a.name or e.uuid4(),positioning={x=a.x or 1,y=a.y or 1,width=a.width or\
0,height=a.height or 0},on_change_state=a.on_change_state or\
function()end,background_color=a.background_color or\
t.term_object.getBackgroundColor(),background_color_on=a.background_color_on or\
t.term_object.getBackgroundColor(),text_color=a.text_color or\
t.term_object.getTextColor(),text_color_on=a.text_color_on or\
t.term_object.getTextColor(),symbol=a.symbol\
or\" \",texture=a.tex,texture_on=a.tex_on,text=a.text,text_on=a.text_on,visible=a.visible,reactive=a.reactive,react_to_events={mouse_click=true,monitor_touch=true},btn=a.btn,order=a.order\
or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,tags={},value=(a.value~=nil)and\
a.value or false,blocking=a.blocking,always_update=a.always_update}return o\
end",
  [ "objects/progressbar/object" ] = "local e=require(\"util\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(o.drag_texture)~=\"boolean\"then o.drag_texture=false end if\
type(o.blocking)~=\"boolean\"then o.blocking=false end if\
type(o.always_update)~=\"boolean\"then o.always_update=false end local\
i={name=o.name or e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or\
0,height=o.height or 0},visible=o.visible,fg=o.fg or colors.white,bg=o.bg or\
colors.black,texture=o.tex,value=o.value or 0,direction=t[o.direction]and\
o.direction or\"left-right\",order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,drag_texture=o.drag_texture,tex_offset_x=o.tex_offset_x\
or 0,tex_offset_y=o.tex_offset_y or\
0,blocking=o.blocking,always_update=o.always_update}return i\
end",
  [ "animations/ease_in_cubic" ] = "return function(e,t)return t^3\
end\
",
  [ "animations/ease_in_quad" ] = "return function(e,t)return t^2\
end\
",
  [ "core/logger" ] = "_ENV=_ENV.ORIGINAL local\
e={{colors.red},{colors.yellow},{colors.white,colors.red},{colors.white,colors.lime},{colors.white,colors.lime},{colors.white},{colors.green},{colors.gray},}local\
t={error=1,warn=2,fatal=3,success=4,message=6,update=7,info=8}local a=15 local\
o={}for i,n in pairs(t)do o[n]=i end function t:dump()end local function\
s(h,r,d)local l,u=math.huge,math.huge local r=tostring(r)d=d or\"info\"if\
h.lastLog==r..d then h.nstr=h.nstr+1 else h.nstr=1 end h.lastLog=r..d local\
c=tostring(table.getn(h.history))..\": [\"..(os.date(\"%T\",os.epoch\"local\"/1000)..(\".%03d\"):format(os.epoch\"local\"%1000)):gsub(\"%.\",\" \")..\"] \"local\
m,f=table.unpack(e[d]or{})local w=\"[\"..(o[d]or\"info\")..\"]\"local\
y=c..w..(\" \"):rep(a-#w-#tostring(#h.history)-1)..\"\\127\"..r local\
p=y..(\" \"):rep(math.max(100-(#y),3))table.insert(h.history,{str=p,type=d})end\
local function v(b,g,k,q)g=g or\"-\"local\
j=setmetatable({lastLog=\"\",nstr=1,maxln=1,history={},title=b,tsym=(#g<4)and g\
or\"-\",auto_dump=k},{__index=t,__call=s})j.lastLog=nil return j end\
return{create_log=v}",
  util = "_ENV=_ENV.ORIGINAL local function e(t,a,o,i,n,s)return t>=o and t<o+n and a>=i\
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
return(it-ht)/(it-tt)*rt+(ht-tt)/(it-tt)*rt end local function\
dt(lt,ut,ct)return(1-ct)*lt+ct*ut end local function mt(ft)local\
wt=createSelfIndexArray()for yt,pt in pairs(ft)do if type(pt)==\"table\"then for\
vt,bt in pairs(pt)do wt[vt][yt]=bt end end end return wt end local\
gt=function(kt)local qt=0 for jt,xt in pairs(kt)do qt=qt+1 end return qt,#kt\
end local zt=function(Et,Tt)local At=true local Ot=gt(Et)local It=gt(Tt)for\
Nt,St in pairs(Et)do if St~=Tt[Nt]then At=false end end if At and Ot==It then\
return true end end local function Ht(Rt)local Ht={}for Dt,Lt in pairs(Rt)do\
table.insert(Ht,Dt)end return Ht end local function Ut(Ct,Mt)local Ft=0 local\
Ht=Ht(Ct)table.sort(Ht,function(Wt,Yt)if Mt then return Yt<Wt else return Wt<Yt\
end end)return function()Ft=Ft+1 if Ct[Ht[Ft]]then return Ht[Ft],Ct[Ht[Ft]]else\
return end end end local function Pt()local Vt=math.random local\
Bt='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'return\
string.gsub(Bt,'[xy]',function(Gt)return string.format('%x',Gt=='x'and\
Vt(0,0xf)or Vt(8,0xb))end)end local function Kt(Qt)local\
Jt=os.epoch(\"utc\")+Qt*1000 while os.epoch(\"utc\")<Jt do\
os.queueEvent(\"waiting\")os.pullEvent(\"waiting\")end end local function\
Xt(Zt)local ea={}Zt:gsub(\".\",function(ta)table.insert(ea,ta)end)return ea end\
local function aa(oa)local ia={}for na=1,oa do ia[na]={\"\",\"\",\"\"}end return ia\
end local\
sa={monitor_touch=true,mouse_click=true,mouse_drag=true,mouse_scroll=true,mouse_up=true}return{is_within_field=e,tables={createNDarray=y,get_true_table_len=gt,compare_table=zt,switchXYArray=mt,create2Darray=q,create3Darray=T,iterate_order=Ut,merge=S},math={interpolateY=C,interpolateZ=G,interpolate_on_line=Z,lerp=dt},HSVToRGB=h,uuid4=Pt,precise_sleep=Kt,piece_string=Xt,create_blit_array=aa,events_with_cords=sa}",
  [ "presets/tex/checker" ] = "local e=require(\"util\")local t=require(\"graphic_handle\")return\
function(...)local a=e.tables.createNDarray(2,{offset={5,13,11,4}})local\
o={...}local i=1 for n,s in pairs(o)do local h={}for r=1,table.getn(o)do local\
d=((r+i)-2)%table.getn(o)+1 h[r]=o[d]end for n,s in pairs(h)do\
a[n+4][i+8]={s=\" \",t=\"f\",b=t.code.to_blit[s]}end i=i+1 end return\
t.load_texture(a)end",
  [ "objects/ellipse/graphic" ] = "local e=require(\"core.algo\")local t=require(\"graphic_handle\").code local\
a=require(\"util\")return function(o)local i=o.canvas.term_object local n={}local\
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
  [ "animations/ease_out_quint" ] = "return function(e,t)return 1-(1-t)^5\
end\
",
  [ "animations/ease_in_quart" ] = "return function(e,t)return t^4\
end\
",
  [ "core/luappm" ] = "_ENV=_ENV.ORIGINAL local function e(t,a,o)local i={}for n=a,o do\
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
  [ "objects/text/graphic" ] = "return function(e)if e.text then e:update(e.text)e.text()end\
end\
",
  [ "presets/rect/window" ] = "return\
function(e,t)return{top_left={sym=\" \",bg=e,fg=t},top_right={sym=\" \",bg=e,fg=t},bottom_left={sym=\" \",bg=t,fg=e},bottom_right={sym=\" \",bg=t,fg=e},side_left={sym=\" \",bg=t,fg=e},side_right={sym=\" \",bg=t,fg=e},side_top={sym=\" \",bg=e,fg=t},side_bottom={sym=\" \",bg=t,fg=e},inside={sym=\" \",bg=t,fg=e},}end\
",
  [ "presets/rect/framed_window" ] = "return\
function(e,t)return{top_left={sym=\" \",bg=e,fg=t},top_right={sym=\" \",bg=e,fg=t},bottom_left={sym=\"\\138\",bg=e,fg=t},bottom_right={sym=\"\\133\",bg=e,fg=t},side_left={sym=\"\\149\",bg=t,fg=e},side_right={sym=\"\\149\",bg=e,fg=t},side_top={sym=\" \",bg=e,fg=t},side_bottom={sym=\"\\143\",bg=e,fg=t},inside={sym=\" \",bg=t,fg=e}}end\
",
  [ "presets/rect/frame_thick" ] = "return\
function(e,t)return{top_left={sym=\" \",bg=e,fg=t},top_right={sym=\" \",bg=e,fg=t},bottom_left={sym=\" \",bg=e,fg=t},bottom_right={sym=\" \",bg=e,fg=t},side_left={sym=\" \",bg=e,fg=t},side_right={sym=\" \",bg=e,fg=t},side_top={sym=\" \",bg=e,fg=t},side_bottom={sym=\" \",bg=e,fg=t},inside={sym=\" \",bg=t,fg=t},}end\
",
  [ "objects/ellipse/logic" ] = "return\
function()end\
",
  [ "animations/ease_in_quint" ] = "return function(e,t)return t^5\
end\
",
  [ "core/object-base" ] = "local e=require(\"util\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end local o={name=a.name or\
e.uuid4(),visible=a.visible,reactive=a.reactive,react_to_events={},btn={},order=a.order\
or 1,logic_order=a.logic_order,graphic_order=a.graphic_order,}return o\
end",
  [ "objects/text/logic" ] = "return\
function()end\
",
  [ "presets/rect/frame" ] = "return\
function(e,t)return{top_left={sym=\"\\151\",bg=t,fg=e},top_right={sym=\"\\148\",bg=e,fg=t},bottom_left={sym=\"\\138\",bg=e,fg=t},bottom_right={sym=\"\\133\",bg=e,fg=t},side_left={sym=\"\\149\",bg=t,fg=e},side_right={sym=\"\\149\",bg=e,fg=t},side_top={sym=\"\\131\",bg=t,fg=e},side_bottom={sym=\"\\143\",bg=e,fg=t},inside={sym=\" \",bg=t,fg=e}}end\
",
  [ "presets/rect/border" ] = "return\
function(e,t)return{top_left={sym=\"\\159\",fg=t,bg=e},top_right={sym=\"\\144\",fg=e,bg=t},bottom_left={sym=\"\\130\",fg=e,bg=t},bottom_right={sym=\"\\129\",fg=e,bg=t},side_left={sym=\"\\149\",fg=t,bg=e},side_right={sym=\"\\149\",fg=e,bg=t},side_top={sym=\"\\143\",fg=t,bg=e},side_bottom={sym=\"\\131\",fg=e,bg=t},inside={sym=\" \",bg=t,fg=e},}end\
",
  [ "objects/ellipse/object" ] = "local e=require(\"util\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(a.symbols)~=\"table\"then o.symbols={}end if type(o.filled)~=\"boolean\"then\
o.filled=true end if type(o.blocking)~=\"boolean\"then o.blocking=false end if\
type(o.always_update)~=\"boolean\"then o.always_update=true end local\
i={name=o.name or e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or\
1,height=o.height or 1},symbol=o.symbol or\" \",bg=o.background_color or\
colors.white,fg=o.text_color or\
colors.black,visible=o.visible,filled=o.filled,order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,blocking=o.blocking,always_update=o.always_update}return\
i\
end",
  [ "animations/linear" ] = "return function(e,t)return t\
end\
",
  [ "animations/ease_in_sine" ] = "return function(e,t)return\
1-math.cos((t*math.pi)/2)end\
",
  [ "animations/flip" ] = "return function(e,t)return 1-t\
end\
",
  [ "animations/ease_out_sine" ] = "return function(e,t)return\
math.sin((t*math.pi)/2)end\
",
  [ "objects/text/object" ] = "local e=require(\"util\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end if\
type(a.blocking)~=\"boolean\"then a.blocking=false end if\
type(a.always_update)~=\"boolean\"then a.always_update=false end local\
o={name=a.name or e.uuid4(),visible=a.visible,text=a.text or\
t.text{text=\"none\",x=1,y=1,bg=colors.red,fg=colors.white},order=a.order or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,update=a.update or\
function()end,blocking=a.blocking,always_update=a.always_update}return o\
end",
  init = "local e=require\"main\"return\
setmetatable(e,{__tostring=function()return\"GuiH.API\"end})\
",
  [ "objects/rectangle/object" ] = "local e=require(\"util\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(o.symbols)~=\"table\"then o.symbols={}end if type(o.blocking)~=\"boolean\"then\
o.blocking=true end if type(o.always_update)~=\"boolean\"then\
o.always_update=false end local i={name=o.name or e.uuid4(),positioning={x=o.x\
or 1,y=o.y or 1,width=o.width or 0,height=o.height or\
0},visible=o.visible,color=o.color or\
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
or colors.white,fg=colors.black}},order=o.order or 1,logic_order=o.logic_order\
or-1,graphic_order=o.graphic_order,blocking=o.blocking,always_update=o.always_update}return\
i\
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
  [ "animations/ease_out" ] = "return function(e,t)return\
1-((1-t)^3)end\
",
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
  [ "objects/scrollbox/object" ] = "local e=require(\"util\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end if\
type(a.blocking)~=\"boolean\"then a.blocking=false end if\
type(a.always_update)~=\"boolean\"then a.always_update=true end local\
o={name=a.name or e.uuid4(),positioning={x=a.x or 1,y=a.y or 1,width=a.width or\
1,height=a.height or\
1},visible=a.visible,reactive=a.reactive,react_to_events={[\"mouse_scroll\"]=true},order=a.order\
or 1,logic_order=a.logic_order,graphic_order=a.graphic_order,value=a.value or\
1,limit_min=a.limit_min or-math.huge,limit_max=a.limit_max or\
math.huge,on_change_value=a.on_change_value or function()end,on_up=a.on_up or\
function()end,on_down=a.on_down or\
function()end,blocking=a.blocking,always_update=a.always_update}return o\
end",
  [ "objects/scrollbox/logic" ] = "local e=require(\"util\")return function(t,a)if\
e.is_within_field(a.x,a.y,t.positioning.x,t.positioning.y,t.positioning.width,t.positioning.height)then\
if a.direction==-1 then t.value=t.value+1 if t.value>t.limit_max then\
t.value=t.limit_max end t.on_change_value(t)t.on_up(t)elseif a.direction==1\
then t.value=t.value-1 if t.value<t.limit_min then t.value=t.limit_min end\
t.on_change_value(t)t.on_down(t)end end\
end",
  [ "objects/script/object" ] = "local e=require(\"util\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end if\
type(a.blocking)~=\"boolean\"then a.blocking=false end if\
type(a.always_update)~=\"boolean\"then a.always_update=true end local\
o={name=a.name or e.uuid4(),visible=a.visible,reactive=a.reactive,code=a.code\
or function()return false end,graphic=a.graphic or function()return false\
end,order=a.order or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,react_to_events={mouse_click=true,mouse_drag=true,monitor_touch=true,mouse_scroll=true,mouse_up=true,key=true,key_up=true,char=true,paste=true},blocking=a.blocking,always_update=a.always_update}return\
o\
end",
  [ "objects/rectangle/logic" ] = "return\
function()end\
",
  [ "objects/frame/graphic" ] = "return function(e)local t=e.last_known_position local a=e.positioning if\
t.x~=a.x or t.y~=a.y or t.width~=a.width or t.height~=a.height then\
e.child.w,e.child.width=a.width,a.width\
e.child.h,e.child.height=a.height,a.height\
e.window.reposition(a.x,a.y,a.width,a.height)e.last_known_position={x=a.x,y=a.y,width=a.width,height=a.height}end\
e.on_graphic(e)end",
  [ "objects/rectangle/graphic" ] = "local e=require(\"graphic_handle\").code return function(t)local\
a=t.canvas.term_object local o,i=t.positioning.x,t.positioning.y local\
n,s=t.positioning.width,t.positioning.height\
a.setCursorPos(o,i)a.blit(t.symbols.top_left.sym..t.symbols.side_top.sym:rep(n-2)..t.symbols.top_right.sym,e.to_blit[t.symbols.top_left.fg]..e.to_blit[t.symbols.side_top.fg]:rep(n-2)..e.to_blit[t.symbols.top_right.fg],e.to_blit[t.symbols.top_left.bg]..e.to_blit[t.symbols.side_top.bg]:rep(n-2)..e.to_blit[t.symbols.top_right.bg])for\
h=1,s-2 do\
a.setCursorPos(o,i+h)a.blit(t.symbols.side_left.sym..t.symbols.inside.sym:rep(n-2)..t.symbols.side_right.sym,e.to_blit[t.symbols.side_left.fg]..e.to_blit[t.symbols.inside.fg]:rep(n-2)..e.to_blit[t.symbols.side_right.fg],e.to_blit[t.symbols.side_left.bg]..e.to_blit[t.symbols.inside.bg]:rep(n-2)..e.to_blit[t.symbols.side_right.bg])end\
a.setCursorPos(o,i+s-1)a.blit(t.symbols.bottom_left.sym..t.symbols.side_bottom.sym:rep(n-2)..t.symbols.bottom_right.sym,e.to_blit[t.symbols.bottom_left.fg]..e.to_blit[t.symbols.side_bottom.fg]:rep(n-2)..e.to_blit[t.symbols.bottom_right.fg],e.to_blit[t.symbols.bottom_left.bg]..e.to_blit[t.symbols.side_bottom.bg]:rep(n-2)..e.to_blit[t.symbols.bottom_right.bg])end",
  [ "objects/progressbar/logic" ] = "return\
function(e)end\
",
  [ "objects/triangle/graphic" ] = "local e=require(\"core.algo\")local t=require(\"graphic_handle\").code return\
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
  [ "apis/fuzzy_find" ] = "local e=require(\"cc.pretty\")local function t(a,o)local\
i=100/math.max(#a,#o)local n=string.len(a)local s=string.len(o)local h={}for\
r=0,n do h[r]={}h[r][0]=r end for d=0,s do h[0][d]=d end for l=1,n do for u=1,s\
do local c=0 if string.sub(a,l,l)~=string.sub(o,u,u)then c=1 end\
h[l][u]=math.min(h[l-1][u]+1,h[l][u-1]+1,h[l-1][u-1]+c)end end return\
100-h[n][s]*i end local function m(f,w)local y,p={},{}for v,b in pairs(f)do\
table.insert(y,{t(v,w),v,b})end table.sort(y,function(g,k)return\
g[1]>k[1]end)for q,j in ipairs(y)do p[q]={match=j[1],str=j[2],data=j[3]}end\
return p end\
return{fuzzy_match=t,sort_strings=m,}",
  [ "animations/ease_out_quad" ] = "return function(e,t)return\
1-(1-t)*(1-t)end\
",
  [ "animations/ease_in_elastic" ] = "return function(e,t)local a=(2*math.pi)/3;return t==0 and 0 or(t==1 and 1\
or(-2^(10*t-10)*math.sin((t*10-10.75)*a)))end\
",
  [ "objects/frame/logic" ] = "local e=require(\"util\")return function(t,a)t.on_any(t,a)local\
o,i=t.window.getPosition()local n=t.dragger.x+o local s=t.dragger.y+i if\
a.name==\"mouse_click\"or a.name==\"monitor_touch\"then if\
e.is_within_field(a.x,a.y,n-1,s-1,t.dragger.width,t.dragger.height)then\
t.dragged=true t.last_click=a t.on_select(t,a)end elseif a.name==\"mouse_up\"then\
t.dragged=false t.on_select(t,a)elseif a.name==\"mouse_drag\"and t.dragged and\
t.dragable then local h,r=t.window.getPosition()local\
d,l=a.x-t.last_click.x,a.y-t.last_click.y t.last_click=a local u,c=h+d,r+l if\
not t.on_move(t,{x=u,y=c})then t.window.reposition(u,c)end local\
m,f=t.window.getPosition()local\
w,y=t.window.getSize()t.last_known_position={x=m,y=f,width=w,height=y}t.positioning={x=m,y=f,width=w,height=y}end\
end",
  installer = "local\
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
  [ "animations/ease_out_quart" ] = "return function(e,t)return 1-(1-t)^4\
end\
",
  [ "objects/triangle/logic" ] = "return\
function()end\
",
  graphic_handle = "local e=require\"core.luappm\"local t=require\"core.blbfor\".open local\
a=require\"util\"_ENV=_ENV.ORIGINAL local o=require\"cc.expect\"local\
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
Sa[La][Ua]=ga(Sa[La][Ua]or{},Ca,Ma,Da)os.queueEvent(\"waiting\")os.pullEvent(\"waiting\")end\
end\
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
local function ho(ro,lo,uo,co,mo,fo,wo,yo,po,vo,bo,go)local\
ko,qo,jo={},{},{}po,vo=po or 0,vo or 0 local xo=false if type(bo)==\"table\"and\
bo[lo.id]then local zo=bo[lo.id].args xo=zo.x==uo and zo.y==co and zo.width==mo\
and zo.height==fo and zo.bg==wo and zo.tg==yo and zo.offsetx==po and\
zo.offsety==vo end if type(bo)==\"table\"and bo[lo.id]and xo then\
ko=bo[lo.id].bg_layers qo=bo[lo.id].fg_layers jo=bo[lo.id].text_layers else for\
Eo=1,fo do for To=1,mo do local Ao=Qa(To+po,Eo+vo,lo)if Ao and next(Ao)then\
ko[Eo]=(ko[Eo]or\"\")..n[Ao.background_color]qo[Eo]=(qo[Eo]or\"\")..n[Ao.text_color]jo[Eo]=(jo[Eo]or\"\")..Ao.symbol:match(\".$\")else\
ko[Eo]=(ko[Eo]or\"\")..n[wo]qo[Eo]=(qo[Eo]or\"\")..n[yo]jo[Eo]=(jo[Eo]or\"\")..\" \"end\
end end if type(bo)==\"table\"then\
bo[lo.id]={bg_layers=ko,fg_layers=qo,text_layers=jo,args={term=ro,x=uo,y=co,width=mo,height=fo,bg=wo,tg=yo,offsetx=po,offsety=vo}}end\
end if not go then for Oo,Io in pairs(ko)do\
ro.setCursorPos(uo,co+Oo-1)ro.blit(jo[Oo],qo[Oo],ko[Oo])end end end local\
function\
No(So,Ho,Ro,Do,Lo,Uo,Co,Mo,Fo,Wo,Yo)ho(So,Ho,Ro,Do,Lo,Uo,Co,Mo,Fo,Wo,Yo)end\
local function\
Po(Vo,Bo,Go,Ko,Qo,Jo,Xo,Zo,ei,ti,ai)ho(Vo,Bo,Go,Ko,Qo,Jo,Xo,Zo,ei,ti,ai,true)end\
return{load_nimg_texture=M,load_ppm_texture=za,load_cimg_texture=Q,load_blbfor_texture=Wt,load_blbfor_animation=nt,load_limg_texture=Lt,load_limg_animation=pt,code={get_pixel=Qa,draw_box_tex=No,cache_image=Po,to_blit=n,to_color=s,build_drawing_char=aa},load_texture=M}",
  [ "objects/button/object" ] = "local e=require(\"util\")return function(t,a)a=a or{}if\
type(a.visible)~=\"boolean\"then a.visible=true end if\
type(a.reactive)~=\"boolean\"then a.reactive=true end if\
type(a.blocking)~=\"boolean\"then a.blocking=true end if\
type(a.always_update)~=\"boolean\"then a.always_update=false end local\
o={name=a.name or e.uuid4(),positioning={x=a.x or 1,y=a.y or 1,width=a.width or\
0,height=a.height or 0},on_click=a.on_click or\
function()end,background_color=a.background_color or\
t.term_object.getBackgroundColor(),text_color=a.text_color or\
t.term_object.getTextColor(),symbol=a.symbol\
or\" \",texture=a.tex,text=a.text,visible=a.visible,reactive=a.reactive,react_to_events={mouse_click=true,monitor_touch=true,},order=a.order\
or\
1,logic_order=a.logic_order,graphic_order=a.graphic_order,tags={},btn=a.btn,value=(a.value~=nil)and\
a.value or true,blocking=a.blocking,always_update=a.always_update}return o\
end",
  main = "local e=require(\"core.logger\")local t=e.create_log()local\
a={algo=require(\"core.algo\"),luappm=require(\"core.luappm\"),blbfor=require(\"core.blbfor\"),graphic=require(\"graphic_handle\").code,general=require(\"util\")}local\
o={}t(\"loading apis..\",t.update)for i,n in pairs(fs.list(\"apis\"))do local\
s=n:match(\"[^.]+\")if not fs.isDir(\"apis/\"..n)then\
a[s]=require(\"apis.\"..s)t(\"loaded api: \"..s)end end\
t(\"\")t(\"loading presets..\",t.update)for h,r in pairs(fs.list(\"presets\"))do for\
d,l in pairs(fs.list(\"presets/\"..r))do if not o[r]then o[r]={}end local\
u=l:match(\"[^.]+\")o[r][u]=require(\"presets.\"..r..\".\"..u)t(\"loaded preset: \"..r..\" > \"..u)end\
end t(\"\")t(\"finished loading\",t.success)t(\"\")t:dump()local function\
c(m,f,w)local y=require(\"core.gui_object\")local\
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
  [ "objects/frame/object" ] = "local e=require(\"util\")local t=require(\"core.gui_object\")return\
function(a,o)o=o or{}if type(o.clear)~=\"boolean\"then o.clear=true end if\
type(o.draggable)~=\"boolean\"then o.draggable=true end if\
type(o.visible)~=\"boolean\"then o.visible=true end if\
type(o.reactive)~=\"boolean\"then o.reactive=true end if\
type(o.blocking)~=\"boolean\"then o.blocking=true end if\
type(o.always_update)~=\"boolean\"then o.always_update=false end local\
i={name=o.name or e.uuid4(),positioning={x=o.x or 1,y=o.y or 1,width=o.width or\
0,height=o.height or\
0},visible=o.visible,reactive=o.reactive,react_to_events={mouse_drag=true,mouse_click=true,mouse_up=true},dragged=false,dragger=o.dragger,last_click={x=1,y=1},last_known_position={x=o.x\
or 1,y=o.y or 1,width=o.width or 0,height=o.height or 0},order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,btn=o.btn,dragable=o.draggable,on_move=o.on_move\
or function()end,on_select=o.on_select or function()end,on_any=o.on_any or\
function()end,on_graphic=o.on_graphic or\
function()end,on_deselect=o.on_deselect or\
function()end,blocking=o.blocking,always_update=o.always_update}local\
n=window.create(a.term_object,i.positioning.x,i.positioning.y,i.positioning.width,i.positioning.height)if\
not i.dragger then i.dragger={x=1,y=1,width=i.positioning.width,height=1}end\
i.child=t(n,a.term_object,a.log)i.window=n i.child.inherit(a,i)return i\
end",
  [ "core/update" ] = "local e=require(\"util\")_ENV=_ENV.ORIGINAL local\
t={[\"mouse_click\"]=true,[\"mouse_drag\"]=true,[\"monitor_touch\"]=true,[\"mouse_scroll\"]=true,[\"mouse_up\"]=true,[\"key\"]=true,[\"key_up\"]=true,[\"char\"]=true,[\"guih_data_event\"]=true,[\"paste\"]=true}local\
a={[\"key\"]=true,[\"key_up\"]=true,[\"char\"]=true,[\"paste\"]=true}local\
o={[1]=true,[2]=true}local\
i={[\"mouse_click\"]=true,[\"mouse_drag\"]=true,[\"mouse_up\"]=true,[\"mouse_scroll\"]=true}return\
function(n,s,h,r,d,l,u,c,m,f,w,y)if h==nil then h=true end local p=\"none\"local\
v=d local b=d local g=n.gui local k,q,j,x local z,E={},{}local T=true if((s or\
math.huge)>0)and not l then if not b or not r then while not t[p]do\
p,k,q,j,x=os.pullEvent()end if p==\"monitor_touch\"then\
v={name=p,monitor=k,x=q,y=j}end if p==\"mouse_click\"or p==\"mouse_up\"then\
v={name=p,button=k,x=q,y=j}end if p==\"mouse_drag\"then\
v={name=p,button=k,x=q,y=j}end if p==\"mouse_scroll\"then\
v={name=p,direction=k,x=q,y=j}end if p==\"key\"then\
v={name=p,key=k,held=q,x=math.huge,y=math.huge}end if p==\"key_up\"then\
v={name=p,key=k,x=math.huge,y=math.huge}end if p==\"paste\"then\
v={name=p,text=k,x=math.huge,y=math.huge}end if p==\"char\"then\
v={name=p,character=k,x=math.huge,y=math.huge}end if p==\"guih_data_event\"then\
v=k end if not v.monitor then v.monitor=\"term_object\"end if not(q~=n.id and\
p~=\"guih_data_event\")then T=false end end local A={}local O={}local I=c or\
e.tables.createNDarray(1)if T and((v.monitor==n.monitor)or a[v.name])and not u\
then for N,S in pairs(g)do for H,R in pairs(S)do if R.react_to_events[v.name]or\
not next(R.react_to_events)then if not A[R.logic_order or R.order]then\
A[R.logic_order or R.order]={}end table.insert(A[R.logic_order or\
R.order],function()if e.events_with_cords[v.name]and R.blocking then local\
D=R.positioning if D and D.x and D.y then local L=D.width or 1 local U=D.height\
or 1 local C=e.is_within_field(v.x,v.y,D.x,D.y,L,U)if C then if I[v.x][v.y]and\
not R.always_update then return end if _G.type(R.on_focus)==\"function\"and\
v.name~=\"mouse_drag\"then setfenv(R.on_focus,_ENV)(R)end for M=1,L*U do\
I[(M-1)%L+D.x][math.ceil(M/L)+D.y-1]=true end end end end if R.reactive then\
table.insert(w or O,function()if a[v.name]then if R.logic then\
setfenv(R.logic,_ENV)(R,v,n)end else if((R.btn or o)[v.button])or\
v.monitor==n.monitor then if R.logic then setfenv(R.logic,_ENV)(R,v,n)end end\
end end)end end)end end end end for F,W in e.tables.iterate_order(A,true)do for\
Y,P in pairs(W)do P()end end if not w then for V=#O,1,-1 do O[V]()end end end\
local B,G=n.term_object.getCursorPos()if h and n.visible then for K,Q in\
pairs(g)do for J,X in pairs(Q)do if not E[X.graphic_order or X.order]then\
E[X.graphic_order or X.order]={}end table.insert(E[X.graphic_order or\
X.order],function()if not(X.gui or X.child)then if X.visible and X.graphic then\
setfenv(X.graphic,_ENV)(X,n)end else if X.visible and X.graphic then\
setfenv(X.graphic,_ENV)(X,n);(X.gui or X.child).term_object.redraw()end end\
end)end end end for Z,et in e.tables.iterate_order(E,y)do for tt,at in\
pairs(et)do if y then table.insert(y,at)else at()end end end local ot={}for\
it,nt in pairs(g)do for st,ht in pairs(nt)do if not ot[ht.graphic_order or\
ht.order]then ot[ht.graphic_order or ht.order]={}end\
table.insert(ot[ht.graphic_order or ht.order],function()if ht.gui or ht.child\
then table.insert(z,ht)end end)end end for rt,dt in\
e.tables.iterate_order(ot,true)do for lt,ut in pairs(dt)do ut()end end if not T\
then return v,table.pack(p,k,q,j,x)end local ct=e.tables.createNDarray(1)local\
mt,ft={},{}local wt={}for yt,pt in ipairs(z)do local\
vt,bt=pt.window.getPosition()local gt,kt=pt.window.getSize()local b=b or d or v\
if b then local\
qt={x=(b.x-vt)+1,y=(b.y-bt)+1,name=b.name,monitor=b.monitor,button=b.button,direction=b.direction,held=b.held,key=b.key,character=b.character,text=b.text}if(pt.gui\
or pt.child)and(pt.gui or pt.child).cls then(pt.gui or\
pt.child).term_object.setBackgroundColor((pt.gui or\
pt.child).background);(pt.gui or pt.child).term_object.clear();end if\
e.is_within_field(b.x,b.y,vt,bt,vt+gt,bt+kt)then(pt.child or\
pt.gui).update(math.huge,pt.visible,true,qt,not pt.reactive,not pt.visible,ct,m\
or b.x,f or b.y,mt,ft)else qt.x=-math.huge qt.y=-math.huge;(pt.child or\
pt.gui).update(math.huge,pt.visible,true,qt,not pt.reactive,not pt.visible,ct,m\
or b.x,f or b.y,mt,mt)end if(pt.gui or pt.child)and(pt.gui or pt.child).cls\
then(pt.gui or pt.child).term_object.redraw()end end end for jt=#mt,1,-1 do\
mt[jt]()end for xt,zt in ipairs(ft)do zt()end return\
v,table.pack(p,k,q,j,x)end",
  [ "objects/triangle/object" ] = "local e=require(\"util\")local\
t={[\"left-right\"]=true,[\"right-left\"]=true,[\"top-down\"]=true,[\"down-top\"]=true,}return\
function(a,o)o=o or{}if type(o.visible)~=\"boolean\"then o.visible=true end if\
type(a.symbols)~=\"table\"then o.symbols={}end if type(o.filled)~=\"boolean\"then\
o.filled=true end if type(o.p1)~=\"table\"then o.p1={}end if\
type(o.p2)~=\"table\"then o.p2={}end if type(o.p3)~=\"table\"then o.p3={}end if\
type(o.blocking)~=\"boolean\"then o.blocking=false end if\
type(o.always_update)~=\"boolean\"then o.always_update=false end local\
i={name=o.name or e.uuid4(),positioning={p1={x=o.p1[1]or 1,y=o.p1[2]or\
1},p2={x=o.p2[1]or 1,y=o.p2[2]or 1},p3={x=o.p3[1]or 1,y=o.p3[2]or\
1}},symbol=o.symbol or\" \",bg=o.background_color or colors.white,fg=o.text_color\
or colors.black,visible=o.visible,filled=o.filled,order=o.order or\
1,logic_order=o.logic_order,graphic_order=o.graphic_order,blocking=o.blocking,always_update=o.always_update}return\
i\
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
