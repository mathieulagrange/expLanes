function expMemory()

if isunix
    if ismac
        [s, r] = system('vm_stat | grep inactive | awk ''{ print $3 }'' | sed ''s/\.//''');
    else
[s, r] = system('free -bo');

    end
end

% unix('vm_stat | grep free')
% 
% unix('sysctl hw.memsize | cut -d: -f2');
% 
% % get the parent process id
% [s,ppid] = unix(['ps -p $PPID -l | ' awkCol('PPID') ]); 
% % get memory used by the parent process (resident set size)
% [s,thisused] = unix(['ps -O rss -p ' strtrim(ppid) ' | awk ''NR>1 {print$2}'' ']); 
% % rss is in kB, convert to bytes 
% thisused = str2double(thisused)*1024 
% 
% function theStr = awkCol(colname)
% theStr  = ['awk ''{ if(NR==1) for(i=1;i<=NF;i++) { if($i~/' colname '/) { colnum=i;break} } else print $colnum }'' '];