function extract_anchors(log_file, output_csv)
    % Open and read the log file
    file_data = readlines(log_file);
    
    % Define a map to store unique anchors and their positions
    anchors = containers.Map();
    
    % Parse the log file to extract anchors
    for line = file_data'
        tokens = regexp(line, '([A-F0-9]+)\[([-0-9\.]+),([-0-9\.]+),([-0-9\.]+)\]', 'tokens');
        for i = 1:length(tokens)
            anchor_id = tokens{i}{1};
            x = str2double(tokens{i}{2});
            y = str2double(tokens{i}{3});
            z = str2double(tokens{i}{4});
            
            % Store anchor if not already present
            if ~isKey(anchors, anchor_id)
                anchors(anchor_id) = [x, y, z];
            end
        end
    end
    
    % Open the CSV file for writing
    fid = fopen(output_csv, 'w');
    fprintf(fid, 'AnchorID,X,Y,Z\n');
    
    % Write anchor data to CSV
    keys = anchors.keys;
    for i = 1:length(keys)
        pos = anchors(keys{i});
        fprintf(fid, '%s,%.6f,%.6f,%.6f\n', keys{i}, pos(1), pos(2), pos(3));
    end
    
    fclose(fid);
    disp(['Anchors saved to ', output_csv]);
end