function process_log_data(folder_path, anchor_file, trajectory_file, num_samples, output_file)
    % Reads UWB data, anchor positions, and trajectory, aggregates data across multiple files, 
    % and averages redundant samples for better stability.
    %
    % Inputs:
    % - folder_path: Directory containing log files
    % - anchor_file: Path to the file with anchor coordinates
    % - trajectory_file: Path to the file with predefined trajectory points
    % - num_samples: Number of samples to extract based on closest trajectory points
    % - output_file: Output CSV file to store processed data
    
    % Read anchor positions
    anchors = read_anchors(anchor_file);
    
    % Read predefined trajectory points
    trajectory = read_trajectory(trajectory_file);
    
    % Get list of log files in the directory
    files = dir(fullfile(folder_path, '*.log'));

    % Initialize data storage across all files
    all_data = [];
    sample_num = 0; % Global sample counter

    % Process each file and aggregate
    for file = files'
        file_path = fullfile(file.folder, file.name);
        file_data = readlines(file_path);

        for line = file_data'
            sample_num = sample_num + 1;
            anchor_distances = containers.Map(keys(anchors), num2cell(nan(1, length(anchors))));
            tag_position = NaN(1,3);
            
            % Extract anchor distances
            tokens = regexp(line, 'AN\d,([A-F0-9]+),([-0-9\.]+),([-0-9\.]+),([-0-9\.]+),([-0-9\.]+)', 'tokens');
            pos_tokens = regexp(line, 'POS,([-0-9\.]+),([-0-9\.]+),([-0-9\.]+),(\d+)', 'tokens');
            
            for i = 1:length(tokens)
                hex_code = tokens{i}{1};  % Anchor hex ID
                distance = str2double(tokens{i}{5}); % Extract distance
                
                if isKey(anchors, hex_code)
                    anchor_distances(hex_code) = distance;
                end
            end
            
            % Extract estimated tag position
            if ~isempty(pos_tokens)
                tag_position = [str2double(pos_tokens{1}{1}), ...
                                str2double(pos_tokens{1}{2}), ...
                                str2double(pos_tokens{1}{3})];
            end
            
            % Handle missing distances using real anchor positions
            anchor_keys = keys(anchor_distances);
            for i = 1:length(anchor_keys)
                if isnan(anchor_distances(anchor_keys{i}))
                    anchor_distances(anchor_keys{i}) = estimate_missing_distance(tag_position, anchors(anchor_keys{i}));
                end
            end
            
            timestamp = sample_num; % Ensures unique timestamps across files

            % Store data for later selection
            data_entry = struct('timestamp', timestamp, 'tag_position', tag_position, ...
                                'anchor_distances', anchor_distances, 'sample_num', sample_num);
            all_data = [all_data, data_entry]; %#ok<AGROW>
        end
    end

    % Select closest samples to predefined trajectory points & apply averaging
    selected_data = select_and_avg_samples(all_data, trajectory, num_samples);
    
    % Write aggregated and averaged data to file
    fid = fopen(output_file, 'w');
    fprintf(fid, 'Timestamp,AnchorID,Distance,SampleNumber,EstimatedX,EstimatedY,EstimatedZ\n');
    
    for i = 1:length(selected_data)
        entry = selected_data(i);
        anchor_keys = keys(entry.anchor_distances);
        for j = 1:length(anchor_keys)
            fprintf(fid, '%.3f,%s,%.6f,%d,%.6f,%.6f,%.6f\n', ...
                    entry.timestamp, anchor_keys{j}, entry.anchor_distances(anchor_keys{j}), ...
                    entry.sample_num, entry.tag_position(1), entry.tag_position(2), entry.tag_position(3));
        end
    end
    
    fclose(fid);
end
