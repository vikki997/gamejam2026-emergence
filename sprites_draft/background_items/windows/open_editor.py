"""Open a pack asset in the existing Facade or Building Texturing app."""
import json,sys,os
from pathlib import Path
PACK=Path(__file__).resolve().parent
ROOT=PACK.parents[1]
mode=sys.argv[1] if len(sys.argv)>1 else 'facade'
index=int(sys.argv[2]) if len(sys.argv)>2 else 1
if not 1<=index<=100:raise SystemExit('Use an asset ID from 1 to 100')
row=json.loads((PACK/'manifest.json').read_text())[index-1]
from PySide6.QtWidgets import QApplication
app=QApplication([]);app.setStyle('Fusion')
if mode=='texturing':
    os.environ['BT_LIBRARY']=str(PACK/'assets')
    records=[]
    for path in (PACK/'assets').glob('*_wall.png'):
        records.append({'name':path.stem.removesuffix('_wall'),'pixel_art':True,'world_size_m':2,
            'channels':{'base_color':{'path':str(path),'size':[64,64]}}})
    (PACK/'assets/materials.json').write_text(json.dumps({'from':'Pixel Facades 100','materials':records}))
    sys.path.insert(0,str(ROOT.parent/'building_texturing'))
    from editor.app import MainWindow,dark_palette,APP_QSS
    app.setPalette(dark_palette());app.setStyleSheet(APP_QSS)
    window=MainWindow();assert window.open_project(str(PACK/f'texturing_projects/{row["name"]}.btex'))
else:
    sys.path.insert(0,str(ROOT))
    from app.window import MainWindow
    from app.project import load
    window=MainWindow();path=PACK/row['project'];figures,settings=load(path)
    window.project.install(figures,settings,path)
    window.canvas_controls.presentation_action.setChecked(True)
window.show();app.exec()
