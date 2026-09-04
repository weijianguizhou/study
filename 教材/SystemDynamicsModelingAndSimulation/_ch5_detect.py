import pymupdf

doc = pymupdf.open(r'D:\studynotes\教材\SystemDynamicsModelingAndSimulation\SystemDynamicsModelingAndSimulation.pdf')
for p in [52, 55, 56, 57, 58, 60]:
    page = doc[p]
    r = page.rect
    print(f'--- page {p+1} rect={r.width:.0f}x{r.height:.0f} ---')
    drawings = page.get_drawings()
    if drawings:
        xs0 = min(d['rect'].x0 for d in drawings)
        ys0 = min(d['rect'].y0 for d in drawings)
        xs1 = max(d['rect'].x1 for d in drawings)
        ys1 = max(d['rect'].y1 for d in drawings)
        print(f'drawings bbox: ({xs0:.0f},{ys0:.0f})-({xs1:.0f},{ys1:.0f}), count={len(drawings)}')
        for d in drawings[:50]:
            q = d['rect']
            print(f'  d {q.x0:.0f},{q.y0:.0f}-{q.x1:.0f},{q.y1:.0f} type={d["type"]}')
    else:
        print('no drawings')
    imgs = page.get_images(full=True)
    print(f'images: {len(imgs)}')
