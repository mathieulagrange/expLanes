function userId=getUserName()

if isunix
userId = getenv('USER');
if isempty(userId), userId = getenv('USERNAME'); end
else
    userId = getenv('UserName');
end


