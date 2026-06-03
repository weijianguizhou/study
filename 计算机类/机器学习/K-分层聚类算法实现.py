import numpy as np
from sklearn.cluster import KMeans
from sklearn.metrics import davies_bouldin_score

class HierarchicalKMeans:
    def __init__(self, max_layers=5, min_data_points=50):
        self.max_layers = max_layers
        self.min_data_points = min_data_points
        self.hierarchy = []

    def _sample_layer(self, data, weights):
        """
        自底向上采样 (Bottom-up)：将坐标减半，合并权重
        论文核心：P_x = (i+1)/2, P_w = sum(w)/2^D
        """
        # 将坐标离散化/整数化映射
        new_coords = np.round(data / 2).astype(int)
        
        # 使用字典进行权重合并 (针对高维稀疏性优化)
        merged = {}
        for coord, w in zip(new_coords, weights):
            t_coord = tuple(coord)
            merged[t_coord] = merged.get(t_coord, 0) + w
            
        new_data = np.array(list(merged.keys()))
        new_weights = np.array(list(merged.values()))
        return new_data, new_weights

    def build_pyramid(self, data):
        """构建金字塔结构"""
        curr_data = data.astype(float)
        curr_weights = np.ones(len(data))
        self.hierarchy = [(curr_data, curr_weights)]
        
        for _ in range(self.max_layers):
            if len(curr_data) <= self.min_data_points:
                break
            curr_data, curr_weights = self._sample_layer(curr_data, curr_weights)
            self.hierarchy.append((curr_data, curr_weights))
        
        # 逆转列表，方便自顶向下处理
        self.hierarchy.reverse()

    def fit_dhikm(self, data, k_range=(2, 10)):
        """
        DHIKM 算法：在顶层利用 DBI 确定最优 K
        """
        # 1. 构建金字塔
        self.build_pyramid(data)
        
        top_data, top_weights = self.hierarchy[0]
        best_k = k_range[0]
        min_dbi = float('inf')
        best_centers = None

        # 2. 在顶层自动寻找最优 K (论文核心步骤)
        for k in range(k_range[0], k_range[1] + 1):
            # 初始中心选择：选权重最大的 K 个点 (论文 Step 2)
            idx = np.argsort(top_weights)[-k:]
            init_centers = top_data[idx]
            
            # 执行加权 KMeans (这里简便起见使用标准 KMeans，实际应考虑权重)
            kmeans = KMeans(n_clusters=k, init=init_centers, n_init=1, max_iter=10)
            labels = kmeans.fit_predict(top_data, sample_weight=top_weights)
            
            # 计算 DBI 指标
            dbi = davies_bouldin_score(top_data, labels)
            if dbi < min_dbi:
                min_dbi = dbi
                best_k = k
                best_centers = kmeans.cluster_centers_

        # 3. 自顶向下精炼 (Refinement Phase)
        # 利用性质 2：2*X_{k+1} - X_k <= 1
        curr_centers = best_centers
        for i in range(1, len(self.hierarchy)):
            layer_data, layer_weights = self.hierarchy[i]
            # 投影：坐标翻倍
            projected_centers = curr_centers * 2
            
            # 在当前层精炼，迭代次数限制在 10 次以内
            kmeans = KMeans(n_clusters=best_k, init=projected_centers, n_init=1, max_iter=10)
            kmeans.fit(layer_data, sample_weight=layer_weights)
            curr_centers = kmeans.cluster_centers_
            
        return best_k, curr_centers

# --- 使用示例 ---
if __name__ == "__main__":
    # 生成模拟数据
    from sklearn.datasets import make_blobs
    X, _ = make_blobs(n_samples=1000, centers=3, cluster_std=0.6, random_state=42)
    # 确保坐标为正整数（符合论文预处理要求）
    X = (X - X.min()) * 10 

    model = HierarchicalKMeans(max_layers=3, min_data_points=20)
    best_k, centers = model.fit_dhikm(X, k_range=(2, 5))

    print(f"自动确定的最优聚类数 K: {best_k}")
    print(f"最终聚类中心:\n{centers}")