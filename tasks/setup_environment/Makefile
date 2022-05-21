SHELL=bash
include ../../shell_functions.make

all: $(foreach lang,stata R python,../output/$(lang)_packages.txt) #python

../output/stata_packages.txt: packages.do | ../output run.sbatch
	$(STATA) $<
../output/R_packages.txt: packages.R | ../output run.sbatch
	$(R) $<
../output/python_packages.txt: requirements.txt | ../output run.sbatch
	pip3 install -r $<
	echo "python packages installed" > $@

include ../generic.make
