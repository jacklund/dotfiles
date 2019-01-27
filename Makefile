SHELL=bash
top_level_files = aliases bashrc fzf.bash fzf.zsh gitconfig gorc tmux.conf vim vimrc zshrc zshrc.d

install: install_top_level_files install_configs install_scripts

install_top_level_files: $(top_level_files)
	@for file in $(top_level_files); do \
		if [[ `readlink -f ~/.$${file}` != ${PWD}/$${file} ]]; then \
			mv ~/.$${file} ~/.$${file}.orig; \
			ln -s ${PWD}/$${file} ~/.$${file}; \
		fi; \
	done

install_configs: $(config_files)
	@for file in config/*/*; do \
		if [[ `readlink -f ~/.$${file}` != ${PWD}/$${file} ]]; then \
			mv ~/.$${file} ~/.$${file}.orig; \
			ln -s ${PWD}/$${file} ~/.$${file}; \
		fi; \
	done

install_scripts:
	@for file in bin/*; do \
		if [[ `readlink -f ~/$${file}` != ${PWD}/$${file} ]]; then \
			mv ~/$${file} ~/$${file}.orig; \
			ln -s ${PWD}/$${file} ~/$${file}; \
		fi; \
	done

