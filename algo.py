import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict, Set
from matplotlib.patches import RegularPolygon
from collections import defaultdict

Point = Tuple[int, int]
Cell = List[Point]

def is_adjacent(cell1: Cell, cell2: Cell) -> bool:
    """
    判断两个单元格是否相邻
    """
    for p1 in cell1:
        for p2 in cell2:
            if abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]) == 1:
                return True
    return False

def get_column_cells(env_slice: np.ndarray, col: int) -> List[Cell]:
    """
    从环境切片中提取单元格
    """
    cells = []
    cell = []
    rows = len(env_slice)
    
    for row in range(rows):
        if env_slice[row] == 0:  # 障碍物
            if cell:  # 如果当前单元格非空
                cells.append(cell)
                cell = []
        else:  # 自由空间
            cell.append((row, col))
    
    if cell:  # 处理最后一个单元格
        cells.append(cell)
    
    return cells

def get_prev_column_cells(cell_grid: np.ndarray, col: int) -> Dict[int, List[Point]]:
    """
    获取前一列的所有单元格信息
    """
    if col == 0:
        return {}
    
    rows = cell_grid.shape[0]
    prev_cells = defaultdict(list)
    
    for row in range(rows):
        cell_id = cell_grid[row, col - 1]
        if cell_id != 0:  # 不是障碍物
            prev_cells[cell_id].append((row, col - 1))
    
    return dict(prev_cells)

def find_matching_prev_cell(current_cell: Cell, prev_cells: Dict[int, List[Point]]) -> int:
    """
    为当前单元格找到匹配的前一列单元格ID
    """
    for cell_id, prev_cell in prev_cells.items():
        if is_cells_connected(current_cell, prev_cell):
            return cell_id
    return -1  # 没有找到匹配的单元格

def is_cells_connected(cell1: Cell, cell2: Cell) -> bool:
    """
    检查两个单元格是否连通（相邻）
    """
    for p1 in cell1:
        for p2 in cell2:
            # 检查是否水平相邻（同一行，相邻列）
            if p1[0] == p2[0] and abs(p1[1] - p2[1]) == 1:
                return True
    return False

def bcd_fixed(env: np.ndarray) -> np.ndarray:
    """
    修复后的 Boustrophedon Cellular Decomposition
    """
    rows, cols = env.shape
    cell_grid = np.zeros_like(env, dtype=int)
    cell_id = 1
    
    for col in range(cols):
        # 获取当前列的环境切片
        env_slice = env[:, col]
        
        # 提取当前列的所有单元格
        current_cells = get_column_cells(env_slice, col)
        
        if col == 0:
            # 第一列：为所有单元格分配新ID
            for cell in current_cells:
                for row, c in cell:
                    cell_grid[row, c] = cell_id
                cell_id += 1
        else:
            # 后续列：检查与前一列的连通性
            prev_cells = get_prev_column_cells(cell_grid, col)
            used_prev_ids = set()
            
            for cell in current_cells:
                # 尝试找到匹配的前一列单元格
                matching_id = find_matching_prev_cell(cell, prev_cells)
                
                if matching_id != -1 and matching_id not in used_prev_ids:
                    # 找到匹配且未使用的前一列单元格，重用其ID
                    for row, c in cell:
                        cell_grid[row, c] = matching_id
                    used_prev_ids.add(matching_id)
                else:
                    # 没有找到匹配或已被使用，分配新ID
                    for row, c in cell:
                        cell_grid[row, c] = cell_id
                    cell_id += 1
    
    return cell_grid

def merge_cells_bcd_improved(cell_grid: np.ndarray, size_threshold: int = 10) -> np.ndarray:
    """
    改进的单元格合并算法
    :param cell_grid: 单元格网格
    :param size_threshold: 最小单元格大小阈值
    :return: 合并后的单元格网格
    """
    rows, cols = cell_grid.shape
    merged_grid = np.copy(cell_grid)
    
    # 统计每个单元格的大小
    cell_sizes = defaultdict(int)
    for row in range(rows):
        for col in range(cols):
            if cell_grid[row, col] != 0:
                cell_sizes[cell_grid[row, col]] += 1
    
    # 找到需要合并的小单元格
    small_cells = {cell_id for cell_id, size in cell_sizes.items() if size < size_threshold}
    
    # 为每个小单元格找到最佳合并目标
    for small_cell_id in small_cells:
        # 找到所有相邻的较大单元格
        adjacent_cells = set()
        small_cell_positions = []
        
        # 收集小单元格的所有位置
        for row in range(rows):
            for col in range(cols):
                if cell_grid[row, col] == small_cell_id:
                    small_cell_positions.append((row, col))
        
        # 找到相邻的单元格
        for row, col in small_cell_positions:
            for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                nr, nc = row + dr, col + dc
                if 0 <= nr < rows and 0 <= nc < cols:
                    neighbor_id = cell_grid[nr, nc]
                    if neighbor_id != 0 and neighbor_id != small_cell_id and neighbor_id not in small_cells:
                        adjacent_cells.add(neighbor_id)
        
        # 选择最大的相邻单元格进行合并
        if adjacent_cells:
            target_cell_id = max(adjacent_cells, key=lambda x: cell_sizes[x])
            
            # 执行合并
            for row, col in small_cell_positions:
                merged_grid[row, col] = target_cell_id
    
    return merged_grid

def analyze_decomposition(cell_grid: np.ndarray) -> Dict:
    """
    分析分解结果
    """
    cell_count = len(np.unique(cell_grid)) - 1  # 减去障碍物(0)
    cell_sizes = defaultdict(int)
    
    rows, cols = cell_grid.shape
    for row in range(rows):
        for col in range(cols):
            if cell_grid[row, col] != 0:
                cell_sizes[cell_grid[row, col]] += 1
    
    total_free_space = sum(cell_sizes.values())
    avg_cell_size = total_free_space / cell_count if cell_count > 0 else 0
    
    return {
        'total_cells': cell_count,
        'total_free_space': total_free_space,
        'average_cell_size': avg_cell_size,
        'min_cell_size': min(cell_sizes.values()) if cell_sizes else 0,
        'max_cell_size': max(cell_sizes.values()) if cell_sizes else 0,
        'cell_sizes': dict(cell_sizes)
    }

def generate_environment(shape=(600, 1200), n_stars=15, n_triangles=15, max_size=50):
    """
    随机生成一个环境
    """
    env = np.ones(shape, dtype=np.uint8)
    
    # 创建matplotlib图形
    fig, ax = plt.subplots(figsize=(12, 6))
    ax.set_xlim(0, shape[1])
    ax.set_ylim(0, shape[0])
    
    # 随机生成五角星
    for _ in range(n_stars):
        x, y = np.random.randint(0, shape[1]), np.random.randint(0, shape[0])
        size = np.random.randint(10, max_size)
        star = RegularPolygon((x, y), 5, radius=size, 
                            orientation=np.random.uniform(0, 2*np.pi), 
                            facecolor='black')
        ax.add_patch(star)
    
    # 随机生成三角形
    for _ in range(n_triangles):
        x, y = np.random.randint(0, shape[1]), np.random.randint(0, shape[0])
        size = np.random.randint(10, max_size)
        triangle = RegularPolygon((x, y), 3, radius=size, 
                                orientation=np.random.uniform(0, 2*np.pi), 
                                facecolor='black')
        ax.add_patch(triangle)
    
    ax.set_aspect('equal')
    ax.axis('off')
    plt.tight_layout()
    
    # 渲染到numpy数组
    fig.canvas.draw()
    buf = np.frombuffer(fig.canvas.tostring_rgb(), dtype=np.uint8)
    buf = buf.reshape(fig.canvas.get_width_height()[::-1] + (3,))
    
    # 转换为二值图像
    env = 1 - (buf[:, :, 0] < 128).astype(np.uint8)
    
    plt.close(fig)
    return env

def display_grid_improved(env: np.ndarray, cell_grid: np.ndarray, analysis: Dict = None):
    """
    改进的显示函数，包含分析信息
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # 原始环境
    axes[0].imshow(env, cmap='binary')
    axes[0].set_title('Original Environment')
    axes[0].axis('off')
    
    # BCD分解结果
    max_cell_id = np.max(cell_grid)
    if max_cell_id > 0:
        # 为每个单元格生成随机颜色
        cell_colors = np.random.rand(max_cell_id + 1, 3)
        cell_colors[0] = [0, 0, 0]  # 障碍物为黑色
        colored_grid = cell_colors[cell_grid]
    else:
        colored_grid = np.zeros_like(cell_grid)
    
    axes[1].imshow(colored_grid)
    axes[1].set_title('BCD Decomposition')
    axes[1].axis('off')
    
    # 分析信息
    if analysis:
        axes[2].axis('off')
        info_text = f"""Decomposition Analysis:
        
Total Cells: {analysis['total_cells']}
Total Free Space: {analysis['total_free_space']} pixels
Average Cell Size: {analysis['average_cell_size']:.1f} pixels
Min Cell Size: {analysis['min_cell_size']} pixels
Max Cell Size: {analysis['max_cell_size']} pixels

Top 5 Largest Cells:"""
        
        # 添加最大的5个单元格信息
        sorted_cells = sorted(analysis['cell_sizes'].items(), 
                            key=lambda x: x[1], reverse=True)[:5]
        for i, (cell_id, size) in enumerate(sorted_cells):
            info_text += f"\nCell {cell_id}: {size} pixels"
        
        axes[2].text(0.1, 0.9, info_text, transform=axes[2].transAxes, 
                    fontsize=10, verticalalignment='top', fontfamily='monospace')
    else:
        axes[2].remove()
    
    plt.tight_layout()
    plt.show()

def main():
    """
    主测试函数
    """
    print("🚀 Testing Fixed BCD Algorithm...")
    
    # 生成测试环境
    print("📦 Generating test environment...")
    env = generate_environment(shape=(100, 100), n_stars=2, n_triangles=3, max_size=20)
    
    # 运行修复后的BCD算法
    print("🔧 Running fixed BCD algorithm...")
    cell_grid = bcd_fixed(env)
    
    # 分析结果
    print("📊 Analyzing decomposition...")
    analysis = analyze_decomposition(cell_grid)
    
    # 应用单元格合并
    print("🔗 Applying cell merging...")
    merged_grid = merge_cells_bcd_improved(cell_grid, size_threshold=15)
    merged_analysis = analyze_decomposition(merged_grid)
    
    # 显示结果
    print("🎨 Displaying results...")
    print(f"Original: {analysis['total_cells']} cells")
    print(f"After merging: {merged_analysis['total_cells']} cells")
    
    display_grid_improved(env, cell_grid, analysis)
    display_grid_improved(env, merged_grid, merged_analysis)
    
    return env, cell_grid, merged_grid

# 运行测试
if __name__ == "__main__":
    env, original_grid, merged_grid = main()
