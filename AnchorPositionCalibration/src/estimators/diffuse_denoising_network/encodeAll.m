% Helper function for encoding through all layers
function encodedData = encodeAll(autoencoders, data)
    for i = 1:length(autoencoders)
        data = predict(autoencoders{i}, data')';
    end
    encodedData = data;
end