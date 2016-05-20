local print = print

dicks        = dicks or {}
local dicks = dicks
dicks.Canvas = dicks.Canvas or nil
dicks.Labels = dicks.Labels or {}

if dicks.Canvas then
	if dicks.Canvas:IsValid () then
		dicks.Canvas:_Remove ()
	end
	dicks.Canvas = nil
end

local friendName = LocalPlayer ():Nick ()
for _, v in ipairs (player.GetAll ()) do
	if LocalPlayer ():IsFriend (v) then
		friendName = v:Nick ()
		break
	end
end

function dicks.AddLabel (text)
	dicks.CreateCanvas ()
	
	text = text:gsub (":you:", LocalPlayer ():Nick ())
	text = text:gsub (":YOU:", LocalPlayer ():Nick ():upper ())
	text = text:gsub (":friend:", friendName)
	text = text:gsub (":FRIEND:", friendName:upper ())
	
	local label = vgui.Create ("GLabelX", dicks.Canvas)
	label:SetText (text)
	label:SetTextColor (GLib.Colors.White)
	label:SizeToContents ()
	label._Remove = label._Remove or label.Remove
	
	label.Remove = function (self)
		chat.AddText ("nope.mkv")
	end
	
	local x = 0
	local y = (dicks.Canvas:GetTall () - label:GetTall ()) * 0.5
	local previous = dicks.Labels [#dicks.Labels]
	if previous then
		label.Previous = previous
		previous.Next  = label
		x = previous:GetPos () + previous:GetWide () + dicks.GetPadding ()
	end
	label.XPos = x
	label:SetPos (x, y)
	dicks.Labels [#dicks.Labels + 1] = label
	
	label.Next                 = dicks.Labels [1]
	dicks.Labels [1].Previous = label
	
	-- Fixup labels
	local visited = {}
	local fixupDivider = label.XPos
	
	visited [label] = true
	label = label.Next
	while label.XPos >= fixupDivider and not visited [label] do
		local _, y = label:GetPos ()
		label.XPos = label.Previous.XPos + label.Previous:GetWide () + dicks.GetPadding ()
		label:SetPos (label.XPos, y)
		
		visited [label] = true
		label = label.Next
	end
end

function dicks.Clear ()
	for _, label in pairs (dicks.Labels) do
		if label:IsValid () then
			label:_Remove ()
		end
	end
	dicks.Labels = {}
end

function dicks.CreateCanvas ()
	if dicks.Canvas then return end
	
	dicks.Canvas = vgui.Create ("GPanel")
	dicks.Canvas:SetSize (ScrW (), 20)
	dicks.Canvas:SetPos (0, ScrH () - dicks.Canvas:GetTall ())
	dicks.Canvas._Remove = dicks.Canvas._Remove or dicks.Canvas.Remove
	
	dicks.Canvas.Remove = function (self)
		chat.AddText ("nope.mkv")
	end
	
	dicks.Canvas.Paint = function (self, w, h)
		surface.SetDrawColor (GLib.Colors.CornflowerBlue)
		surface.DrawRect (0, 0, w, h)
	end
end

function dicks.GetPadding ()
	return 32
end

local lastThinkTime  = SysTime ()
local lastThinkFrame = CurTime ()
local function Think ()
	if CurTime () == lastThinkFrame then return end
	lastThinkFrame = CurTime ()
	
	local dt = SysTime () - lastThinkTime
	lastThinkTime = SysTime ()
	local speed = 100
	local dx = -speed * dt
	
	for k, label in pairs (dicks.Labels) do
		local _, y = label:GetPos ()
		label.XPos = label.XPos + dx
		label:SetPos (label.XPos, y)
		
		if label:GetPos () + label:GetWide () < 0 then
			local x = 0
			for _, otherLabel in pairs (dicks.Labels) do
				x = math.max (x, otherLabel.XPos + otherLabel:GetWide ())
			end
			label.XPos = x + dicks.GetPadding ()
			label:SetPos (label.XPos, y)
		end
	end
end

hook.Add ("CreateMove",                     "dicks", Think)
hook.Add ("HUDPaint",                       "dicks", Think)
hook.Add ("Move",                           "dicks", Think)
hook.Add ("PreDrawOpaqueRenderables",       "dicks", Think)
hook.Add ("PreDrawTranslucentRenderables",  "dicks", Think)
hook.Add ("PostDrawOpaqueRenderables",      "dicks", Think)
hook.Add ("PostDrawTranslucentRenderables", "dicks", Think)
hook.Add ("PostDrawVGUI",                   "dicks", Think)
hook.Add ("PostRenderScene",                "dicks", Think)
hook.Add ("RenderScene",                    "dicks", Think)
hook.Add ("Think",                          "dicks", Think)
hook.Add ("Tick",                           "dicks", Think)

dicks.Clear ()

local headlines =
{
	"=star= Python1320 has been elected President of the United States.",
	"=world= Metastruct solves global warming. \"It was easy\", said CapsAdmin.",
	"=server= Metastruct acquires Google in surprise takeover bid.",
	"=world= Metastruct launches manned mission to Mars.",
	"=rainbow= Python1320 bans Mitt Romney.",
	"=lightbulb= CapsAdmin patents revolutionary new ban system, codenamed \"Bubble\".",
	"=money= Metastruct solves the US fiscal problem. \"This isn't how\", said Python.",
	"=rainbow= CERN scientists still baffled over how to donlode wier mode.",
	"=rainbow= EXCLUSIVE: :YOU: CAUGHT FAPPING TO MOUNTAIN GOAT PORN.",
	"=wrench= Shell32 script interpreter 4.0 released: New features include anonymous delegates and dependant types.",
	"=box= A recent study done by the University of Metastruct has determined that PAC is \"laggy as fuck\".",
	"=server= Apple's share price drops to zero this morning after Metastruct's Google acquisition.",
	"=star= Firefox and Internet Explorer hit by lawsuit for being \"worse than Chrome\".",
	"=new= Metastruct releases new line of CPUs, supporting clock speeds of up to 29.3 GHz.",
	"=server= Intel founder reportedly \"jelly\" over Metastruct's newly released CPU line.",
	"=gun= Kerahk lands 12 consecutive headshots on noobs whilst blindfolded. Metastruct donates shat bricks to build new orphanage.",
	"=rainbow= Hundreds attend :you: and :friend:'s wedding reception.",
	"=rainbow= :you: wins dick sucking contest, smashes world record for dicks sucked in an hour.",
	"=exclamation= Biologists baffled by intelligent life found in Garry's Mod. All attempts to communicate have been met by crowbars."
}

for _, headline in RandomPairs (headlines) do
	dicks.AddLabel (headline)
end