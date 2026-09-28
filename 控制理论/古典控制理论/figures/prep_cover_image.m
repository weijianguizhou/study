function prep_cover_image
%PREP_COVER_IMAGE 封面手绘图的预处理
%   输入：子昕手绘.png（原始照片）
%   处理：裁去四周空白与右缘杂边，并把发灰的背景拉伸为白色
%   输出：子昕手绘_封面.png（供 cover_李思风.tex 作封面插图使用）
close all;

A = imread('子昕手绘.png');
G = im2double(im2gray(A));

% 墨迹范围（排除右缘的杂边）
m = G < 150/255;
m(:, 330:end) = false;
[r, c] = find(m);
mg = 12;                                       % 四周留白（像素）
r1 = max(1, min(r)-mg);  r2 = min(size(G,1), max(r)+mg);
c1 = max(1, min(c)-mg);  c2 = min(size(G,2), max(c)+mg);
B  = G(r1:r2, c1:c2);

% 提白：把背景灰度（0.74~0.83）映射为纯白，墨迹保持深色
B = min(1, max(0, (B - 0.03)/(0.76 - 0.03)));

imwrite(B, '子昕手绘_封面.png');
fprintf('输出 子昕手绘_封面.png：%d x %d 像素\n', size(B,2), size(B,1));
end
