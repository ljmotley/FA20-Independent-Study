local version = "`1'"

foreach outcome in specific1 generic engagement badges {
  do prep `outcome'
  local spec "i.weekofyear i.state i.schoolyear [pw=pop], vce(cluster state)"
  drop if mi(lntele)
  if "`version'" == "wks" reg `outcome' i.postcovid  `spec'
  if "`version'" == "tele" reg `outcome' i.postcovid##c.lntele `spec'
  if "`version'" == "inc" reg `outcome' i.postcovid##c.lninc `spec'
  if "`version'" == "inctele" reg `outcome' i.postcovid##c.lninc i.postcovid##c.lntele `spec'
  if "`version'" == "N" reg `outcome' i.postcovid##c.lninc i.postcovid##c.lntele `spec'
  if "`version'" == "mtitles" reg `outcome' i.postcovid##c.lninc i.postcovid##c.lntele `spec'

  est sto r`outcome'
}

label var postcovid "Post Covid"
label var lntele "Log Teleworkability"
label var lninc "Log Income"

local opts "keep(*1.post*) noobs nomtitles"
if "`version'" == "N" local opts "drop(*) nomtitles"
if "`version'" == "mtitles" local opts "drop(*) noobs"

esttab r* using "../output/`version'.tex", replace label frag nolines nonumbers `opts'
