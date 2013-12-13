function expRandomSeed(config)

% TODO make the reset

% defaultStream = RandStream.getGlobalStream;
defaultStream = RandStream.getDefaultStream;
defaultStream.State = config.randState;
