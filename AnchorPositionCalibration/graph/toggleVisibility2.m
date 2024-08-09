% Example function for toggling visibility
    function toggleVisibility2(src, plotHandle)
        if get(src, 'Value') == 1
            set(plotHandle, 'Visible', 'on');
        else
            set(plotHandle, 'Visible', 'off');
        end
    end