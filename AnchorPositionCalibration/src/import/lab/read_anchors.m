function anchors = read_anchors(file_path)
    % Reads anchor positions from a file and returns a map with anchor IDs as keys.
    file_data = readlines(file_path);
    anchors = containers.Map();
    
    for line = file_data'
        tokens = regexp(line, '([A-F0-9]+)\[([-0-9\.]+),([-0-9\.]+),([-0-9\.]+)\]', 'tokens');
        if ~isempty(tokens)
            hex_code = tokens{1}{1};
            position = [str2double(tokens{1}{2}), str2double(tokens{1}{3}), str2double(tokens{1}{4})];
            anchors(hex_code) = position;
        end
    end
end