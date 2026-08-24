{lib}: path: let
  lines = lib.splitString "\n" (builtins.readFile path);
  parseLine = state: line: let
    trimmed = lib.strings.trim line;
    sectionMatch = builtins.match "^[[]([^]]+)[]]$" trimmed;
    valueMatch = builtins.match "^([^=]+)=(.*)$" trimmed;
  in
    if trimmed == "" || lib.hasPrefix ";" trimmed || lib.hasPrefix "#" trimmed
    then state
    else if sectionMatch != null
    then state // {section = builtins.head sectionMatch;}
    else if valueMatch != null && state.section != null
    then
      state
      // {
        result = lib.recursiveUpdate state.result {
          ${state.section}.${lib.strings.trim (builtins.elemAt valueMatch 0)} = lib.strings.trim (builtins.elemAt valueMatch 1);
        };
      }
    else throw "Unsupported INI line in `${toString path}`: `${line}`";
in
  (builtins.foldl' parseLine {
    section = null;
    result = {};
  } lines).result
