function [bounds] = buildBounds(mx, numAnchors)
    lb = repmat([0 0 0], numAnchors, 1); % Lower bounds
    ub = repmat([mx(1) mx(2) mx(3)], numAnchors, 1);  % Upper bounds
    sz = size(lb);
    bounds = zeros(2, sz(1), sz(2));
    bounds(1, :, :) = lb;
    bounds(2, :, :) = ub;
end

