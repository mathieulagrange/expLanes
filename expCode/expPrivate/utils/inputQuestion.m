function quit=inputQuestion(q)

if nargin<1, q=''; end

reply = input([q '\n Do you want to continue ? Y/N [Y]: '], 's');
if isempty(reply) || lower(reply)=='y', quit=0; else quit=1; end
end