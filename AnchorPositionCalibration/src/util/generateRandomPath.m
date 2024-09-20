% Function to generate a random path
    function path = generateRandomPath(steps, mx)
        path = cumsum(randn(steps, 3), 1) + [mx, mx, mx];
    end