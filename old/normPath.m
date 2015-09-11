function p = normPath(p)

p = regexprep(p, '~', getenv('HOME'));