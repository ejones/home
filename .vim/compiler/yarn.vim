let current_compiler = "yarn"

exec 'CompilerSet makeprg=yarn\ --silent\ test\ -u\ --changedSince\ origin/develop'
" \ --reporters=' . expand('$HOME') . '/.js/reporters/jest-simple-reporter'

CompilerSet errorformat=%-G%\\b%.%#,[%*\\d:%*\\d:%*\\d]%m,%E%*\\sat\ %f:%l:%c,%E%*\\sat\ %*\\S\ (%f:%l:%c),%C%*\\sat%.%#,%C%*\\sat%.%#,%*\\s%f:\ %m(%l:%c),%f:%l:%c:%m,%f:%l:%m
