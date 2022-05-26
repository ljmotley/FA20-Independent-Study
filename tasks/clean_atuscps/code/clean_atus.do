cap program drop extract_data
program define extract_data
  args p
  filefilter "../input/atus`p'_2019.do" "temp_atus`p'_2019.do", f(c:\BSatus`p'_2019.dat) t(../input/atus`p'_2019.dat) replace
  clear
  do temp_atus`p'_2019
  rm temp_atus`p'_2019.do
end


extract_data cps
summarize
extract_data cps
summarize
save "../output/atuscps_2019.dta", replace
