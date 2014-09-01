function time = expTimeString(duration)

time = '';

if duration > 1440
    nbDays = floor(duration/1440);
    if nbDays == 1
        time = [time num2str(nbDays) ' day '];
    else
        time = [time num2str(nbDays) ' days '];
    end
    duration = rem(duration, 1440);
end

if duration > 60
    nbHours = floor(duration/60);
    if nbHours == 1
        time = [time num2str(nbHours) ' hour '];
    else
        time = [time num2str(nbHours) ' hours '];
    end
    duration = rem(duration, 60);
end

if duration >= 1
    nbMinutes = floor(duration);
    if nbMinutes == 1
        time = [time num2str(nbMinutes) ' minute '];
    else
        time = [time num2str(nbMinutes) ' minutes '];
    end
    duration = rem(duration, 1);
end

if duration > 0
    nbSeconds = floor(duration*60);
    if nbSeconds == 1
        time = [time num2str(nbSeconds) ' second'];
    else
        time = [time num2str(nbSeconds) ' seconds'];
    end
end