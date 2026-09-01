#!/usr/bin/env python3
import argparse,json,sys,urllib.request
from pathlib import Path
ap=argparse.ArgumentParser();ap.add_argument('--root',required=True);args=ap.parse_args()
runtime=Path(args.root)/'STATE'/'edualc'/'runtime.json'
if not runtime.exists(): print('EDUALC_LOCAL_INFERENCE_FAIL: runtime state missing',file=sys.stderr);raise SystemExit(1)
d=json.loads(runtime.read_text(encoding='utf-8-sig'));port=int(d['port'])
try:
    with urllib.request.urlopen(f'http://127.0.0.1:{port}/v1/models',timeout=5) as r: models=json.load(r)
    mids=[x.get('id') for x in models.get('data',[]) if x.get('id')]; model='captain' if 'captain' in mids else (mids[0] if mids else 'captain')
    payload={'model':model,'messages':[{'role':'user','content':'Reply with exactly EDUALC_LOCAL_INFERENCE_PASS and nothing else.'}],'temperature':0,'max_tokens':32}
    req=urllib.request.Request(f'http://127.0.0.1:{port}/v1/chat/completions',data=json.dumps(payload).encode(),headers={'Content-Type':'application/json'})
    with urllib.request.urlopen(req,timeout=180) as r: out=json.load(r)
    content=(out.get('choices') or [{}])[0].get('message',{}).get('content','').strip()
    if content!='EDUALC_LOCAL_INFERENCE_PASS': raise RuntimeError('unexpected content: '+repr(content))
    print('EDUALC_LOCAL_INFERENCE_PASS')
except Exception as e:
    print('EDUALC_LOCAL_INFERENCE_FAIL: '+str(e),file=sys.stderr);raise SystemExit(1)
