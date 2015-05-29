function doit=inputQuestion(q)

if nargin<1, q=''; end

if isempty(strfind(q, '?'))
    q = [q ' do you want to continue ?'];
end

reply = input([q ' Y/N [Y]: '], 's');

if isempty(reply) || lower(reply(1))=='y', doit=1; else doit=0; end
end