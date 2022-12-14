../output ../report ../temp ../input slurmlogs:
	mkdir $@

run.sbatch: ../../setup_environment/code/run.sbatch | slurmlogs
	ln -sf $< $@

../input/Project.toml: ../../setup_environment/output/Project.toml | ../input/Manifest.toml ../input
	ln -sf $< $@
../input/Manifest.toml: ../../setup_environment/output/Manifest.toml | ../input
	ln -sf $< $@

.PRECIOUS: ../../%

../../%: #Generic recipe to produce outputs from upstream tasks
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)

../report/%.csv.log: ../output/%.csv | ../report
ifneq ($(shell command -v md5),)
	cat <(md5 $<) <(echo -n 'Lines:') <(cat $< | wc -l ) <(head -3 $<) <(echo '...') <(tail -2 $<)  > $@
else
	cat <(md5sum $<) <(echo -n 'Lines:') <(cat $< | wc -l ) <(head -3 $<) <(echo '...') <(tail -2 $<) > $@
endif
	cat $< | awk -f ../../get_averages_csv.awk >> $@
