../output ../temp ../input slurmlogs:
	mkdir $@

run.sbatch: ../../setup_environment/code/run.sbatch | slurmlogs
	ln -s $< $@

../../%: #Generic recipe to produce outputs from upstream tasks
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)
