integrate-githooks:
	@echo " Setting core.hooksPath in local git config "
	@command git config core.hooksPath .git-hooks
