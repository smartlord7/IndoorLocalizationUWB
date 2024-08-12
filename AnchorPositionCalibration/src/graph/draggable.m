function draggable(h)
    % Makes a plot object draggable
    for k = 1:numel(h)
        set(h(k), 'ButtonDownFcn', @dragObject);
    end
end