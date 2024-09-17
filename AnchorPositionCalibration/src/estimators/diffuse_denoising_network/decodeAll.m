% Helper function for decoding through all layers (assuming autoencoders are symmetric)
function decodedData = decodeAll(autoencoders, data)
    for i = length(autoencoders):-1:1
        % Use predict here to decode the data
        % Note: This is a placeholder, actual decoding might require reverse operations
        data = predict(autoencoders{i}, data')';
    end
    decodedData = data;
end