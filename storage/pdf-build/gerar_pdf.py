from pathlib import Path
import sys,re,html
BASE=Path(__file__).resolve().parent
sys.path.insert(0,str(BASE/'deps'))
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,Table,TableStyle,PageBreak,Flowable
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
FONT=Path('C:/Windows/Fonts')
for name,file in [('Body','segoeui.ttf'),('BodyBold','segoeuib.ttf'),('Mono','consola.ttf')]:
    pdfmetrics.registerFont(TTFont(name,str(FONT/file)))
pdfmetrics.registerFontFamily('Body',normal='Body',bold='BodyBold',italic='Body',boldItalic='BodyBold')
purple=colors.HexColor('#6D28D9'); ink=colors.HexColor('#172033'); muted=colors.HexColor('#536178')
W=A4[0]-84
styles={
'p':ParagraphStyle('body',fontName='Body',fontSize=10,leading=14.5,textColor=ink,spaceAfter=9),
'h1':ParagraphStyle('title',fontName='BodyBold',fontSize=24,leading=29,textColor=ink,spaceAfter=17),
'h2':ParagraphStyle('section',fontName='BodyBold',fontSize=17,leading=22,textColor=purple,spaceBefore=8,spaceAfter=13,keepWithNext=True),
'h3':ParagraphStyle('tabletitle',fontName='BodyBold',fontSize=12,leading=17,textColor=ink,spaceBefore=13,spaceAfter=8,keepWithNext=True),
'cell':ParagraphStyle('cell',fontName='Body',fontSize=9,leading=12,textColor=ink,splitLongWords=True),
'head':ParagraphStyle('head',fontName='BodyBold',fontSize=9,leading=12,textColor=colors.white),
'legend':ParagraphStyle('legend',fontName='Body',fontSize=8,leading=11,textColor=muted,spaceAfter=10),
}
def fmt(s):
    s=html.escape(s)
    s=re.sub(r'`([^`]+)`',r'<font name="Mono">\1</font>',s)
    s=re.sub(r'\*\*([^*]+)\*\*',r'<b>\1</b>',s)
    return s
class Relations(Flowable):
    def __init__(self,edges):
        Flowable.__init__(self); self.edges=edges; self.width=W; self.height=len(edges)*35+20
    def draw(self):
        c=self.canv; bw=180; right=W-bw
        for n,(a,b,rel,card) in enumerate(self.edges):
            y=self.height-28-n*35
            c.setFillColor(colors.HexColor('#F3F0FF')); c.setStrokeColor(colors.HexColor('#D7CCF4'))
            c.roundRect(0,y,bw,24,4,fill=1,stroke=1); c.roundRect(right,y,bw,24,4,fill=1,stroke=1)
            c.setFillColor(ink); c.setFont('Mono',8)
            c.drawCentredString(bw/2,y+9,a.lower()); c.drawCentredString(right+bw/2,y+9,b.lower())
            c.setStrokeColor(purple); c.line(bw,y+9,right,y+9)
            c.line(right-5,y+12,right,y+9); c.line(right-5,y+6,right,y+9)
            c.setFillColor(muted); c.setFont('Body',7.5)
            c.drawCentredString(W/2,y+15,rel)
            c.drawCentredString(W/2,y-1,card)
        c.setFillColor(muted); c.setFont('Body',7.5)
        c.drawString(0,1,'1 : 0..N = um para zero ou muitos; 1 : 0..1 = um para zero ou um.')

def footer(c,doc):
    c.saveState(); c.setStrokeColor(colors.HexColor('#DDD6EE')); c.line(42,38,A4[0]-42,38)
    c.setFillColor(muted); c.setFont('Body',8)
    c.drawString(42,25,'Portal do Bairro | Modelo proposto do banco de dados')
    c.drawRightString(A4[0]-42,25,str(doc.page)); c.restoreState()

lines=(BASE/'esquema.md').read_text(encoding='utf-8-sig').splitlines(); story=[]; i=0; diagrams=0
while i<len(lines):
    s=lines[i].strip()
    if not s: i+=1; continue
    if s.startswith('```mermaid'):
        edges=[]; i+=1
        while i<len(lines) and not lines[i].startswith('```'):
            m=re.match(r'(\w+)\s+\|\|--(o\{|o\|)\s+(\w+)\s*:\s*(.+)',lines[i].strip())
            if m: a,card,b,rel=m.groups(); edges.append((a,b,rel,'1 : 0..N' if card=='o{' else '1 : 0..1'))
            i+=1
        diagrams+=1
        if diagrams==2: story.append(PageBreak())
        story.append(Paragraph(['Organizações e acessos','Publicações e financeiro','Avaliações e auditoria'][diagrams-1],styles['h3']))
        story.append(Relations(edges)); story.append(Spacer(1,8)); i+=1; continue
    if s.startswith('|'):
        rows=[]
        while i<len(lines) and lines[i].strip().startswith('|'):
            cells=[c.strip() for c in lines[i].strip().strip('|').split('|')]
            if not all(re.fullmatch(r'[:\- ]+',c) for c in cells):rows.append(cells)
            i+=1
        n=len(rows[0]); widths={2:[126,W-126],3:[177,111,W-288],4:[146,105,138,W-389],5:[125,68,106,109,W-408]}[n]
        data=[[Paragraph(fmt(x),styles['head' if ri==0 else 'cell']) for x in row] for ri,row in enumerate(rows)]
        t=Table(data,colWidths=widths,repeatRows=1,hAlign='LEFT')
        t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),purple),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.HexColor('#F4F6FA'),colors.white]),('VALIGN',(0,0),(-1,-1),'TOP'),('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7),('LINEBELOW',(0,0),(-1,0),.5,purple),('LINEBELOW',(0,1),(-1,-1),.3,colors.HexColor('#DFE4EB'))]))
        story.extend([t,Spacer(1,11)]); continue
    if s.startswith('### '):story.append(Paragraph(fmt(s[4:]),styles['h3']))
    elif s.startswith('## '):
        if not s.startswith('## 1.'):story.append(PageBreak())
        story.append(Paragraph(fmt(s[3:]),styles['h2']))
    elif s.startswith('# '):story.append(Paragraph(fmt(s[2:]),styles['h1']))
    elif s.startswith('- '):story.append(Paragraph('• '+fmt(s[2:]),styles['p']))
    else:story.append(Paragraph(fmt(s),styles['p']))
    i+=1
out=BASE/'Portal-do-Bairro-Esquema-do-Banco.pdf'
doc=SimpleDocTemplate(str(out),pagesize=A4,rightMargin=42,leftMargin=42,topMargin=42,bottomMargin=53,title='Portal do Bairro — Esquema do banco de dados',author='Portal do Bairro',pageCompression=1)
doc.build(story,onFirstPage=footer,onLaterPages=footer)
import pymupdf
pdf=pymupdf.open(out)
text='\n'.join(p.get_text() for p in pdf)
normalize=lambda s:re.sub(r'[^a-z0-9À-ÿ]','',s.lower())
whole=normalize(text); missing=[]
for ln in lines:
    ln=ln.strip()
    if not ln or ln.startswith('```') or ln=='erDiagram' or '||--' in ln:continue
    if ln.startswith('|'):
        cells=[c.strip() for c in ln.strip('|').split('|')]
        if all(re.fullmatch(r'[:\- ]+',c) for c in cells):continue
    else:cells=[re.sub(r'^#{1,3} |^- ','',ln)]
    for cell in cells:
        val=normalize(cell)
        if val and val not in whole: missing.append(cell)
assert not missing,missing
for num in [0,1,4,len(pdf)-1]:pdf[num].get_pixmap(matrix=pymupdf.Matrix(1.2,1.2)).save(str(BASE/f'pagina-{num+1}.png'))
(BASE/'validacao.txt').write_text(f'Paginas: {len(pdf)}\nConteudo textual completo: OK\nDiagramas: {diagrams}\nBytes: {out.stat().st_size}',encoding='utf-8')
print((BASE/'validacao.txt').read_text(encoding='utf-8')); print(out)

