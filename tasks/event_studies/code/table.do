local version = "`1'"


foreach outcome in specific1 generic engagement badges {
  do prep `outcome' drop_holidays
  summarize
  drop if inrange(wkssnccovid, 15, .)
  drop if inrange(wkssnccovid, 0, 3)
  local spec "i.weekofyear i.state i.schoolyear [pw=pop], vce(cluster state)"
  if "`version'" == "wks" reg `outcome' i.postcovid  `spec'
  if "`version'" == "tele" reg `outcome' i.postcovid##c.lntele `spec'
  if "`version'" == "comp" reg `outcome' i.postcovid##c.lncomp `spec'
  if "`version'" == "broad" reg `outcome' i.postcovid##c.lnbroad `spec'
  if "`version'" == "inc" reg `outcome' i.postcovid##c.lninc `spec'
  if "`version'" == "inctele" reg `outcome' i.postcovid##c.lninc i.postcovid##c.lntele `spec'
  if "`version'" == "comptele" reg `outcome' i.postcovid##c.lninc i.postcovid##c.lncomp `spec'
  if "`version'" == "broadtele" reg `outcome' i.postcovid##c.lninc i.postcovid##c.lnbroad `spec'
  if "`version'" == "beta" {
      reg `outcome' i.postcovid##c.lninc `spec'
      matrix b = e(b)
      local betainc = b[1,5]
      reg `outcome' i.postcovid##c.lninc i.postcovid##c.lntele `spec'
      matrix b = e(b)
      local betatele = b[1,5]

  }
    if "`version'" == "betacomp" {
      reg `outcome' i.postcovid##c.lninc `spec'
      matrix b = e(b)
      local betainc = b[1,5]
      reg `outcome' i.postcovid##c.lninc i.postcovid##c.lncomp `spec'
      matrix b = e(b)
      local betacomp = b[1,5]
  }

    if "`version'" == "betabroad" {
      reg `outcome' i.postcovid##c.lninc `spec'
      matrix b = e(b)
      local betainc = b[1,5]
      reg `outcome' i.postcovid##c.lninc i.postcovid##c.lnbroad `spec'
      matrix b = e(b)
      local betabroad = b[1,5]
  }
  if "`version'" == "N" reg `outcome' i.postcovid##c.lninc i.postcovid##c.lntele `spec'
  if "`version'" == "mtitles" reg `outcome' i.postcovid##c.lninc i.postcovid##c.lntele `spec'

  est sto r`outcome'

  if "`version'" == "beta" {
    local dbeta = 100*(`betainc'-`betatele')/`betainc'
    local dbeta : display %4.1f `dbeta'
    estadd local beta `dbeta', replace: r`outcome'
    }

  if "`version'" == "betacomp" {
    local dbeta = 100*(`betainc'-`betacomp')/`betainc'
    local dbeta : display %4.1f `dbeta'
    estadd local beta `dbeta', replace: r`outcome'
    }

  if "`version'" == "betabroad" {
    local dbeta = 100*(`betainc'-`betabroad')/`betainc'
    local dbeta : display %4.1f `dbeta'
    estadd local beta `dbeta', replace: r`outcome'
    }
}

label var postcovid "Post Covid"
label var lntele "Log Teleworkability"
label var lninc "Log Income"
label var lncomp "Log Computer"
label var lnbroad "Log Internet"

local opts "keep(*1.post*) b(a3) nostar noobs nomtitles"
if "`version'" == "N" local opts "drop(*) nomtitles"
if "`version'" == "mtitles" local opts "drop(*) noobs"
if "`version'"=="beta"|"`version'"=="betacomp"|"`version'"=="betabroad" local opts `" nomtitles drop(*) noobs scalar("beta $ 100 \times \frac{\gamma_B-\gamma_D}{\gamma_B} $") "'

esttab r* using "../output/temp1.tex", replace label frag se nolines nonumbers `opts'

cap erase "../output/eventstudytable_`version'.tex"
filefilter "../output/temp1.tex" "../output/temp2.tex", from("[1em]") to("") replace
filefilter "../output/temp2.tex" "../output/temp1.tex", from("specific1") to("School-centered") replace
filefilter "../output/temp1.tex" "../output/temp2.tex", from("generic") to("Parent-centered") replace
filefilter "../output/temp2.tex" "../output/temp1.tex", from("engagement") to("Engagement") replace
filefilter "../output/temp1.tex" "../output/temp2.tex", from("badges") to("Badges") replace
filefilter "../output/temp2.tex" "../output/temp1.tex", from("\BS_") to("_") replace
filefilter "../output/temp1.tex" "../output/temp2.tex", from("Post Covid=1") to("Post Covid") replace

shell sed '$ s/.$//' ../output/temp2.tex > ../output/temp1.tex
shell sed '$ s/.$//' ../output/temp1.tex > ../output/eventstudytable_`version'.tex

erase "../output/temp1.tex"
erase "../output/temp2.tex"

