function H = computeJacobian(state, anchors, tagPos)
    % Compute Jacobian of the measurement function
    numAnchors = size(anchors, 1);
    H = zeros(numAnchors, length(state));

    for i = 1:numAnchors
        anchorPos = anchors(i, :)';
        distance = norm(tagPos - anchorPos);
        % Derivative of distance w.r.t. tag position
        H(i, 1:3) = (tagPos - anchorPos') / distance; % d(z_hat)/d(tagPos)
    end
end