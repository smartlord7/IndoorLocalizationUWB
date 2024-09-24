% Function to generate a random path
    function path = generateRandomPath(steps, mx)
        path = cumsum(randn(steps, 3), 1) + [mx(1), mx(2), mx(3)];
    end