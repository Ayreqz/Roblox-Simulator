-- Formata números grandes: 1500 -> "1.5K", 2300000 -> "2.3M".

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

local NumberFormatter = {}

function NumberFormatter.format(value)
	value = math.floor(value)
	if math.abs(value) < 1000 then
		return tostring(value)
	end

	local index = math.min(math.floor(math.log10(math.abs(value)) / 3), #SUFFIXES - 1)
	local scaled = value / 10 ^ (index * 3)
	scaled = math.floor(scaled * 100) / 100 -- trunca (evita "1000K")

	local text = string.format("%.2f", scaled)
	text = string.gsub(text, "%.?0+$", "") -- remove zeros finais
	return text .. SUFFIXES[index + 1]
end

return NumberFormatter
