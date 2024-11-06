function residuals = calcWeightedResiduals(anchors, distances_noisy, tagPos, numAnchors, numSamples)
    % Reshape the flat vector of anchors back into matrix form
    anchors = reshape(anchors, [numAnchors, 3]);
    
    % Define weights for each sample (linear decay from 1 to 0.1)
    weights = linspace(1, 0.1, numSamples)';
    
    % Expand tag positions and anchors for vectorized distance computation
    % tagPos_exp: numSamples x 1 x 3, anchors_exp: 1 x numAnchors x 3
    tagPos_exp = reshape(tagPos, [numSamples, 1, 3]);
    anchors_exp = reshape(anchors, [1, numAnchors, 3]);
    
    % Calculate predicted distances for each tag position and anchor
    predictedDistances = sqrt(sum((anchors_exp - tagPos_exp).^2, 3)); % numSamples x numAnchors
    
    % Calculate residuals matrix with weights applied
    residualsMatrix = (predictedDistances - distances_noisy) .* weights; % element-wise weighting

    % Convert residuals matrix to a column vector
    residuals = residualsMatrix(:);
end
