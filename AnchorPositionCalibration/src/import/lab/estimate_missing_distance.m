function estimated_distance = estimate_missing_distance(tag_pos, anchor_pos)
    estimated_distance = sqrt(sum((tag_pos - anchor_pos).^2));
end