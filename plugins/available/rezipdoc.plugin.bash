cite about-plugin
about-plugin 'Load ReZipDoc - a git tool to diff docx files'

# Use the install location of ReZipDoc
# otherwise default to ~/.ReZipDoc

export RE_ZIP_DOC_DIR=${RE_ZIP_DOC_DIR:-$HOME/.ReZipDoc}

# arbitrary choice
if [[ -s "${RE_ZIP_DOC_DIR}/script/rezipdoc-repo-tool.sh" ]]; then
	pathmunge "${RE_ZIP_DOC_DIR}/script"
else
	_log_error "please install ReZipDoc"
fi
