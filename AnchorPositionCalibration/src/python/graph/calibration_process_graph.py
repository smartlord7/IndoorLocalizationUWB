import matplotlib.pyplot as plt
import networkx as nx
import matplotlib

matplotlib.use('TkAgg')
# Create a directed graph
G = nx.DiGraph()

# Define nodes with colors and layers (for left-to-right orientation)
nodes = {
    'A': ('Review\nDocumentation', 'lightyellow'),
    'B': ('Get True\nAnchor Positions', 'lightblue'),
    'C': ('Get Inter-Anchor\nDistances', 'lightblue'),
    'D': ("Get Manufacturer's\nAnchor Estimates", 'lightblue'),
    'E': ('Define a Calibration\nTrajectory', 'lightgreen'),
    'F': ('Execute the\nCalibration Trajectory', 'lightcoral'),
    'G': ('Calibrate along\nthe Trajectory', 'lightblue'),
    'I': ('Compare\nCalibration Results', 'lightgrey'),
    'J': ('Define a Location\nTrajectory', 'lightgreen'),
    'K': ('Execute the\nLocation Trajectory', 'lightcoral'),
    'L': ('Locate tag along\nthe Trajectory', 'lightblue'),
    'M': ('Compare\nLocation Results', 'lightgrey'),
}

# Add nodes to the graph
for node, (label, color) in nodes.items():
    G.add_node(node, label=label, color=color)

# Define edges (normal flow)
edges = [
    ('A', 'B'), ('B', 'C'), ('C', 'D'), ('D', 'E'),
    ('E', 'F'), ('F', 'G'), ('G', 'I'), ('I', 'J'), ('J', 'K'), ('K', 'L'), ('L', 'M')
]

# Add edges to the graph
G.add_edges_from(edges)

# Define loop edges for repetitions
loop_edges = [
    ('B', 'B', 'Repeat M times'),
    ('C', 'C', 'Repeat M times'),
    ('D', 'D', 'Repeat N times'),
]

# Adjust layout for better spacing
pos = nx.shell_layout(G)  # Adjust 'k' for better spacing

# Draw nodes with larger sizes
node_colors = [nodes[n][1] for n in G.nodes]
nx.draw(G, pos, with_labels=True, labels={n: nodes[n][0] for n in G.nodes},
        node_color=node_colors, node_size=6000, font_size=7, edge_color='black')

# Draw normal edges
nx.draw_networkx_edges(G, pos, edgelist=edges, edge_color='black')

# Draw loop edges manually with labels
for u, v, label in loop_edges:
    pos_offset = (pos[u][0], pos[u][1] + 0.2)  # Move label above the arrow
    G.add_edge(u, v, label=label)
    nx.draw_networkx_edges(G, pos, edgelist=[(u, v)], style='dashed', edge_color='red', connectionstyle="arc3,rad=0.2")
    plt.text(pos_offset[0], pos_offset[1], label, fontsize=9, color='red', fontweight='bold', ha='center')

# Adjust third loop as a curved arc from 'G' to 'F'
arc_pos = ((pos['G'][0] + pos['F'][0]) / 2 + 0.135, (pos['G'][1] + pos['F'][1]) / 3 - 0.15)  # Curve adjustment
nx.draw_networkx_edges(G, pos, edgelist=[('G', 'F')], style='dashed', edge_color='blue', connectionstyle="arc3,rad=-0.3")
plt.text(arc_pos[0], arc_pos[1], 'Repeat N times', fontsize=9, color='blue', fontweight='bold', ha='center')

# Adjust third loop as a curved arc from 'G' to 'F'
arc_pos = ((pos['L'][0] + pos['K'][0]) / 2, (pos['L'][1] + pos['K'][1]) / 3 + 0.5)  # Curve adjustment
nx.draw_networkx_edges(G, pos, edgelist=[('L', 'K')], style='dashed', edge_color='blue', connectionstyle="arc3,rad=-0.3")
plt.text(arc_pos[0], arc_pos[1], 'Repeat K times', fontsize=9, color='blue', fontweight='bold', ha='center')


# Save and show the flowchart
plt.savefig("UWB_Calibration_Flowchart_NX_Improved.png", dpi=300, bbox_inches='tight')
plt.show()
