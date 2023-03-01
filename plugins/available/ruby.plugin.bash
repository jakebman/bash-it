# shellcheck shell=bash
cite about-plugin
about-plugin 'ruby and rubygems specific functions and settings'

# Make commands installed with 'gem install --user-install' available
# ~/.gem/ruby/${RUBY_VERSION}/bin/
if _command_exists ruby && _command_exists gem; then
	GEM_HOME="$(ruby -e 'print Gem.user_dir')"
	export GEM_HOME
	pathmunge "${GEM_HOME}/bin" after
fi

function remove_gem() {
	about 'removes installed gem'
	param '1: installed gem name'
	group 'ruby'

	gem list | grep "${1:?${FUNCNAME[0]}: no gem name provided}" | awk '{ print $1; }' | xargs sudo gem uninstall
}
