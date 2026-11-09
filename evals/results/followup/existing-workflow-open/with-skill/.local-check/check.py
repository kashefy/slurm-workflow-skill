import json, os, pathlib, subprocess, tempfile
base=pathlib.Path.cwd()
with tempfile.TemporaryDirectory(prefix='local-',dir=base/'.local-check') as d:
 t=pathlib.Path(d); bindir=t/'bin'; bindir.mkdir(); root=t/'run with spaces'; profile=t/'private profile.sh'; calls=t/'calls'
 stub=bindir/'sbatch'
 stub.write_text('''#!/usr/bin/env python3
import json, os, sys
p=os.environ['CALLS']
try: n=len(open(p).readlines())
except FileNotFoundError: n=0
with open(p,'a') as f: f.write(json.dumps(sys.argv[1:])+'\\n')
if n and os.environ['MODE']=='fail': sys.exit(7)
print(('bad response' if os.environ['MODE']=='bad' else '202;local') if n else '101;local')
'''); stub.chmod(0o700)
 profile.write_text('PYTHON=/unused/python\nRUN_ROOT='+repr(str(root))+'\nSBATCH_OPTIONS=("--account=test account")\n')
 env=dict(os.environ,PATH=str(bindir)+':'+os.environ['PATH'],CALLS=str(calls))
 assert subprocess.check_output(['bash','-c','command -v sbatch'],env=env,text=True).strip()==str(stub)
 for mode in ['ok','fail','bad']:
  calls.unlink(missing_ok=True)
  r=subprocess.run(['bash',str(base/'submit.sh'),str(profile)],env=dict(env,MODE=mode),capture_output=True,text=True)
  a=[json.loads(x) for x in calls.read_text().splitlines()]
  assert len(a)==2 and r.stdout=='101\n'
  assert '--dependency=afterok:101' in a[1]
  assert a[1][-2:]==[str(base),str(profile)]
  assert '--account=test account' in a[1]
  assert r.returncode==(0 if mode=='ok' else 1)
  assert ('202' if mode=='ok' else '101') in r.stderr
  if mode=='bad': assert 'bad\\ response' in r.stderr
  print(mode+': passed')
