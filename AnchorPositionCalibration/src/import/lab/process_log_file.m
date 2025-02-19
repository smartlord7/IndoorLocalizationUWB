function process_log_file(folder_path, output_file)
    % Define true anchor positions
    anchors = struct('A1', [0, 0, 0], 'A2', [2.8, 0, 0], ...
                     'A3', [2.8, 6.5, 0], 'A4', [0, 6.5, 0]);
    
    % Get list of log files in the directory
    files = dir(fullfile(folder_path, '*.log'));
    
    fid = fopen(output_file, 'w');
    fprintf(fid, 'Timestamp,AnchorID,Distance,SampleNumber,EstimatedX,EstimatedY,EstimatedZ\n');
    sample_num = 0;
    
    for file = files'
        file_path = fullfile(file.folder, file.name);
        file_data = readlines(file_path);
        
        for line = file_data'
            sample_num = sample_num + 1;
            anchor_distances = struct('A1', NaN, 'A2', NaN, 'A3', NaN, 'A4', NaN);
            tag_position = NaN(1,3);
            
            tokens = regexp(line, '([A-F0-9]+)\[([-0-9\.]+),([-0-9\.]+),([-0-9\.]+)\]=(\d+\.\d+)', 'tokens');
            est_tokens = regexp(line, 'est\[([-0-9\.]+),([-0-9\.]+),([-0-9\.]+)', 'tokens');
            
            for i = 1:length(tokens)
                hex_code = tokens{i}{1};
                distance = str2double(tokens{i}{5});
                
                switch hex_code
                    case '0323', anchor_distances.A1 = distance;
                    case '189B', anchor_distances.A2 = distance;
                    case '8A94', anchor_distances.A3 = distance;
                    case 'C32D', anchor_distances.A4 = distance;
                end
            end
            
            % Extract estimated tag position
            if ~isempty(est_tokens)
                tag_position = [str2double(est_tokens{1}{1}), ...
                                str2double(est_tokens{1}{2}), ...
                                str2double(est_tokens{1}{3})];
            end
            
            % Handle missing data via geometric consistency
            fields = fieldnames(anchor_distances);
            for i = 1:length(fields)
                if isnan(anchor_distances.(fields{i}))
                    anchor_distances.(fields{i}) = estimate_missing_distance(tag_position, anchors.(fields{i}));
                end
            end
            
            timestamp = sample_num * 0.033; % Assuming ~30Hz sampling rate
            
            % Write to file
            % Check for NaN values before writing
            if ~any(isnan(struct2array(anchor_distances))) && ~any(isnan(tag_position))
                anchor_ids = {'A1', 'A2', 'A3', 'A4'};
                for i = 1:4
                    fprintf(fid, '%.3f,%d,%.6f,%d,%.6f,%.6f,%.6f\n', ...
                            timestamp, i, anchor_distances.(anchor_ids{i}), ...
                            sample_num, tag_position(1), tag_position(2), tag_position(3));
                end
            end
        end
    end
    
    fclose(fid);
end

function estimated_distance = estimate_missing_distance(tag_pos, anchor_pos)
    estimated_distance = sqrt(sum((tag_pos - anchor_pos).^2));
end
