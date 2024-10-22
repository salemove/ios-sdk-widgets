clone-snapshots:
	@echo "	⏬  Cloning snapshots..."
	@command git clone git@github.com:salemove/ios-widgets-snapshots.git SnapshotTests/__Snapshots__

source_branch := $(shell git rev-parse --abbrev-ref HEAD)
clone-snapshots-ci:
	@echo "	⏬  Cloning snapshots..."
	@command git clone $(repo_url) SnapshotTests/__Snapshots__
	@command cd SnapshotTests/__Snapshots__ && ./checkout.sh $(source_branch) $(destination_branch)

commit-snapshots:
	@echo "	💾  Committing snapshots..."
	@command cd SnapshotTests/__Snapshots__ && git add . && git commit -a -m "Update snapshots."

push-snapshots:
	@echo "	⬆️  Pushing snapshots..."
	@command cd SnapshotTests/__Snapshots__ && git push origin master --force

pull-snapshots:
	@echo "	⬇️  Pulling snapshots..."
	@command cd SnapshotTests/__Snapshots__ && git pull --rebase origin master

setup-git:
	@echo " 🏗 Setting up Git..."
	@command cd SnapshotTests/__Snapshots__ && git init
	@command cd SnapshotTests/__Snapshots__ && git remote add origin git@github.com:salemove/ios-widgets-snapshots.git

install-lfs:
	@echo " 👨‍🔧  Installing Git LFS..."
	@command cd SnapshotTests/__Snapshots__ && git lfs install
	@command cd SnapshotTests/__Snapshots__ && git lfs track "*.png"
	@command cd SnapshotTests/__Snapshots__ && git add .gitattributes && git commit -a -m "Add .gitattributes"

write-diff:
	@echo " ✍️  Writing changes (if any) to file..."
	@command cd SnapshotTests/__Snapshots__ && git diff --name-only > ./../Changes.diff

integrate-githooks:
	@echo " Setting core.hooksPath in local git config "
	@command git config core.hooksPath .git-hooks
