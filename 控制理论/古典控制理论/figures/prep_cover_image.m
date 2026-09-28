function prep_cover_image
%PREP_COVER_IMAGE 封面手绘图的预处理
%   输入：子昕手绘.png（原始照片）
%   处理：裁去四周空白与右缘杂边；用分块背景估计做光照平整，消除照片
%         的渐变阴影，使纸面背景成为均匀纯白；再轻微提高墨迹对比。
%   输出：子昕手绘_封面.png（供 cover_李思风.tex 作封面插图使用）
close all;

A = imread('子昕手绘.png');
G = im2double(im2gray(A));

% ---- 墨迹范围（排除右缘的杂边）----
m = G < 150/255;
m(:, 330:end) = false;
[r, c] = find(m);
mg = 12;                                       % 四周留白（像素）
r1 = max(1, min(r)-mg);  r2 = min(size(G,1), max(r)+mg);
c1 = max(1, min(c)-mg);  c2 = min(size(G,2), max(c)+mg);
B  = G(r1:r2, c1:c2);
[nr, nc] = size(B);

% ---- 分块估计背景光照（每块取 90 分位亮度）----
gb   = 24;                                     % 分块大小（像素）
nrB  = ceil(nr/gb);  ncB = ceil(nc/gb);
bgc  = zeros(nrB, ncB);
for i = 1:nrB
    for j = 1:ncB
        blk = B((i-1)*gb+1:min(i*gb,nr), (j-1)*gb+1:min(j*gb,nc));
        s   = sort(blk(:));
        bgc(i,j) = s(max(1, round(0.9*numel(s))));
    end
end

% ---- 插值成全尺寸背景，并做光照平整（除法校正）----
[Xc, Yc] = meshgrid(((1:ncB)-0.5)*gb, ((1:nrB)-0.5)*gb);
[xi, yi] = meshgrid(1:nc, 1:nr);
xi = min(max(xi, Xc(1)), Xc(end));
yi = min(max(yi, Yc(1)), Yc(end));
BG = interp2(Xc, Yc, bgc, xi, yi, 'linear');
B  = B ./ max(BG, 0.2);

% ---- 提白与轻微对比 ----
B = min(1, max(0, (B - 0.05)/(0.88)));

imwrite(B, '子昕手绘_封面.png');
fprintf('输出 子昕手绘_封面.png：%d x %d 像素\n', size(B,2), size(B,1));
end
