function doit=inputQuestion(q)

if nargin<1, q=''; end

if ~strfind(q, '?')
    q = [q '\n Do you want to continue ?'];
end

reply = input([q ' Y/N [Y]: '], 's');

if isempty(reply) || lower(reply)=='y', doit=1; else doit=0; end
end