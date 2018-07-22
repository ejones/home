let current_compiler = "yarn"

exec 'CompilerSet makeprg=yarn\ --silent\ test\ --reporters=' . expand('$HOME') . '/.js/reporters/jest-simple-reporter'

CompilerSet errorformat&
