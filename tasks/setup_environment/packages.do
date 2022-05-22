clear
// ssc install labutil
// ssc install coefplot
 // ssc install scheme-burd
// net install gr0002_3, from(http://www.stata-journal.com/software/sj4-3)
//warning: gtools must be compiled manually for M1 Macs

// install from ssc
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
// local PACKAGES distinct gtools reghdfe ftools ppmlhdfe parmest estout binscatter geodist listtex egenmore matchit freqindex
foreach package in `PACKAGES' {
	capture which `package'
	if _rc==111 ssc install `package'
}

file open myfile using "../output/stata_packages.txt", write replace
file write myfile "Installed: `PACKAGES'"
file close myfile

set scheme cleanplots, perm
