clear

//warning: gtools must be compiled manually for M1 Macs

// install from ssc
local PACKAGES distinct gtools reghdfe ftools ppmlhdfe parmest estout binscatter geodist listtex egenmore matchit freqindex
foreach package in `PACKAGES' {
	capture which `package'
	if _rc==111 ssc install `package'
}

file open myfile using "../output/stata_packages.txt", write replace
file write myfile "Installed: `PACKAGES'"
file close myfile
