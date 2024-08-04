function dragObject(src, ~)
    % Dragging function for plot objects
    fig = ancestor(src, 'figure');
    set(fig, 'WindowButtonMotionFcn', @moveObject);
    set(fig, 'WindowButtonUpFcn', @dropObject);
    function moveObject(~, ~)
        cp = get(gca, 'CurrentPoint');
        set(src, 'XData', cp(1,1), 'YData', cp(1,2), 'ZData', cp(1,3));
    end
    function dropObject(~, ~)
        set(fig, 'WindowButtonMotionFcn', '');
        set(fig, 'WindowButtonUpFcn', '');
    end
end