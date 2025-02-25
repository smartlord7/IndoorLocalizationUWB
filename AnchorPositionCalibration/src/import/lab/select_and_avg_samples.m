%% Function to Select and Average Nearby Samples
function averaged_data = select_and_avg_samples(all_data, trajectory, num_samples)
    % Selects num_samples closest samples to predefined trajectory points 
    % and averages samples within a distance threshold.

    distance_threshold = 0.035;   % How far a sample can be from the trajectory point
    max_samples_per_point = 10;  % Max samples used for averaging at each trajectory point
    
    averaged_data = [];
    
    for i = 1:size(trajectory, 2)
        traj_point = trajectory(:, i)';  % Get trajectory point as row vector
        nearby_samples = [];
        
        % Find all samples within the distance threshold
        for j = 1:length(all_data)
            entry = all_data(j);
            tag_pos = entry.tag_position;
            dist = norm(tag_pos - traj_point);
            
            if dist < distance_threshold
                nearby_samples = [nearby_samples, entry]; %#ok<AGROW>
            end
        end
        
        % Limit the number of samples to the max threshold
        if length(nearby_samples) > max_samples_per_point
            nearby_samples = nearby_samples(1:max_samples_per_point);
        end
        
        % If we have multiple nearby samples, average them
        if ~isempty(nearby_samples)
            avg_entry = struct('timestamp', mean([nearby_samples.timestamp]), ...
                               'tag_position', mean(reshape([nearby_samples.tag_position], 3, []), 2)', ...
                               'sample_num', mean([nearby_samples.sample_num]));

            % Average anchor distances
            anchor_keys = keys(nearby_samples(1).anchor_distances);
            avg_distances = containers.Map(anchor_keys, num2cell(zeros(1, length(anchor_keys))));
            
            % Properly accumulate anchor distances
            for k = 1:length(anchor_keys)
                key = anchor_keys{k};
                dist_values = zeros(1, length(nearby_samples));
                
                for s = 1:length(nearby_samples)
                    dist_values(s) = nearby_samples(s).anchor_distances(key);
                end
                
                avg_distances(key) = mean(dist_values);
            end
            
            avg_entry.anchor_distances = avg_distances;
            averaged_data = [averaged_data, avg_entry]; %#ok<AGROW>
        end
        
        % Stop if we reach the required number of samples
        if length(averaged_data) >= num_samples
            break;
        end
    end
end