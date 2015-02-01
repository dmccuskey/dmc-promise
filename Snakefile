# dmc-promise

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-promise"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-promise",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_states_mix.lua"
		],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library"
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-promise", module_config )

