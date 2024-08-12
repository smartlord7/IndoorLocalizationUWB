function anchors = calculateAnchors(W1, b1, W2, b2, tagPos, numAnchors)
    hiddenLayer = relu(W1 * tagPos' + b1); % ReLU activation
    anchors = W2 * hiddenLayer + b2; % Output layer computation
    anchors = reshape(anchors, numAnchors, 3); % Reshape into 2D array of anchor coordinates
end