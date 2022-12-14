SHELL=bash
include ../../shell_functions.make

all: $(foreach lang,R stata python,../output/$(lang)_packages.txt)

../output/julia_packages.txt: packages.jl ../output/Project.toml ../output/Manifest.toml | ../output run.sbatch
	$(JULIA) $<
../output/stata_packages.txt: packages.do save_data/save_data.ado | ../output run.sbatch
	$(STATA) $<
../output/R_packages.txt: packages.R | ../output run.sbatch
	$(R) $<
../output/python_packages.txt: requirements.txt | ../output run.sbatch
	$(PIP) $<
	echo "python packages installed" > $@

../input ../output slurmlogs:
	mkdir $@
run.sbatch: ../../setup_environment/code/run.sbatch | slurmlogs
	ln -sf $< $@
