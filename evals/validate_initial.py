"""Replay local contract checks against preserved trial artifacts; no Slurm access."""
import json, os, shutil, subprocess, tempfile
from pathlib import Path
TRIALS=Path(__file__).resolve().parent/'results/initial/ml-authoring'
STUB=Path(__file__).resolve().parents[1]/'tests/stubs/sbatch'
results={}
for condition in ('baseline','with-skill'):
 with tempfile.TemporaryDirectory(prefix='ml-eval-') as td:
  root=Path(td); scripts=root/'wrapper files'; scripts.mkdir()
  for f in (TRIALS/condition).iterdir():
   if f.is_file() and f.name!='prompt.txt': shutil.copy(f,scripts/f.name)
  project=root/'ML project'; project.mkdir(); source=root/'staged data'; source.mkdir()
  private=root/'private'; private.mkdir(); output=root/'outputs'; calls=root/'calls'; calls.mkdir()
  binpath=root/'bin'; binpath.mkdir(); shutil.copy(STUB,binpath/'sbatch'); (binpath/'sbatch').chmod(0o700)
  setup=private/'environment.sh'; setup.write_text(':\n')
  config=private/'config.sh'
  # All paths are invented and quoted for shell source.
  import shlex
  q=lambda p:shlex.quote(str(p))
  if condition=='baseline':
   config.write_text(f'PROJECT_DIR={q(project)}\nSOURCE_ROOT={q(source)}\nRUN_ROOT={q(output)}\nPYTHON=(python3)\nENV_SETUP={q(setup)}\nPREP_OPTIONS=()\nTRAIN_OPTIONS=()\nEVAL_OPTIONS=()\n')
   launcher='submit.sh'
  else:
   config.write_text(f'PROJECT={q(project)}\nSOURCE_ROOT={q(source)}\nOUTPUT_ROOT={q(output)}\nRECEIPT_ROOT={q(private/"receipts")}\nENV_SETUP={q(setup)}\nPYTHON={q(shutil.which("python3"))}\nEXPORT_POLICY=ALL\nSITE_CONFIGURED=yes\nCOMMON_OPTIONS=()\nPREP_OPTIONS=()\nTRAIN_OPTIONS=()\nEVAL_OPTIONS=()\n')
   launcher='launch.sh'
  # Tiny contract stubs, used by evaluator only; no ML implementation or compute.
  body='''import sys\nfrom pathlib import Path\na=dict(x.split("=",1) for x in sys.argv[1:])\nstage=Path(sys.argv[0]).stem\nif stage=="prepare":\n for fold in ("fold-00","fold-01","fold-02"):\n  dest=Path(a["output_dir"])/fold; dest.mkdir(parents=True,exist_ok=True)\n  for name in ("train_ids.txt","validation_ids.txt"): (dest/name).write_text("1\\n")\nelif stage=="train":\n assert Path(a["train_file"]).is_file() and Path(a["validation_file"]).is_file()\n assert a["train_seed"]=="17"\n Path(a["output_dir"]).mkdir(parents=True,exist_ok=True)\n (Path(a["output_dir"])/"best.ckpt").write_text("stub")\nelif stage=="evaluate":\n assert a["checkpoint"]=="best" and (Path(a["run_dir"])/"best.ckpt").is_file()\n (Path(a["output_dir"])/"evaluated.txt").write_text("stub")\n'''
  for name in ('prepare','train','evaluate'): (project/f'{name}.py').write_text(body)
  env=os.environ.copy(); env.update(PATH=str(binpath)+os.pathsep+env['PATH'],FAKE_SBATCH_DIR=str(calls))
  run=lambda argv,extra={}:subprocess.run(argv,cwd=scripts,env={**env,**extra},capture_output=True,text=True)
  syntax={p.name:run(['bash','-n',str(p)]).returncode for p in scripts.iterdir() if p.suffix in ('.sh','.sbatch')}
  submitted=run(['bash',str(scripts/launcher),str(config)])
  argsets=[(calls/f'{i}.args').read_bytes().decode().rstrip('\0').split('\0') for i in (1,2,3)]
  stages=[]
  spool=root/'spool'; spool.mkdir()
  for args in argsets:
   idx=next(i for i,a in enumerate(args) if a.endswith('.sbatch'))
   script=Path(args[idx]); spooled=spool/script.name; shutil.copy(script,spooled)
   stages.append((spooled,args[idx+1:]))
  jobs=[]
  for i,task in ((0,None),(1,'0'),(1,'1'),(1,'2'),(2,None)):
   script,args=stages[i]
   r=run(['bash',str(script),*args],{} if task is None else {'SLURM_ARRAY_TASK_ID':task})
   jobs.append({'stage':script.name,'task':task,'exit':r.returncode,'stderr':r.stderr})
  direct_jobs=[]
  for number,task in ((0,None),(1,'0'),(1,'1'),(1,'2'),(2,None)):
   args=argsets[number]; idx=next(i for i,a in enumerate(args) if a.endswith('.sbatch'))
   r=run(['bash',*args[idx:]],{} if task is None else {'SLURM_ARRAY_TASK_ID':task})
   direct_jobs.append({'stage':Path(args[idx]).name,'task':task,'exit':r.returncode,'stderr':r.stderr})
  evaluated_count=len(list(output.rglob('evaluated.txt')))
  checkpoint=next(output.rglob('fold-01/best.ckpt')); checkpoint.unlink()
  evalargs=argsets[2]; idx=next(i for i,a in enumerate(evalargs) if a.endswith('.sbatch'))
  missing_checkpoint=run(['bash',*evalargs[idx:]])
  if condition=='baseline': manifest=output/'folds.txt'
  else: manifest=next((private/'receipts').rglob('manifest.txt'))
  manifest.chmod(0o600); manifest.write_text('changed\n')
  preargs=argsets[0]; idx=next(i for i,a in enumerate(preargs) if a.endswith('.sbatch'))
  changed_manifest=run(['bash',*preargs[idx:]])
  # Failure test: independent invocation with fresh output root and scheduler records.
  for p in calls.iterdir(): p.unlink()
  if output.exists(): shutil.rmtree(output)
  fail=run(['bash',str(scripts/launcher),str(config)],{'FAKE_FAIL_AT':'2'})
  results[condition]={'syntax_exit':max(syntax.values()),'syntax_checks':syntax,'submission_exit':submitted.returncode,'dependencies':[a for args in argsets for a in args if a.startswith(('--dependency','--array'))], 'spooled_jobs':jobs,'failure_exit':fail.returncode,'no_third_submission_after_failure':not (calls/'3.args').exists(),'failure_message':fail.stderr,'direct_jobs':direct_jobs,'direct_evaluation_files':evaluated_count,'missing_checkpoint_exit':missing_checkpoint.returncode,'changed_manifest_exit':changed_manifest.returncode}
print(json.dumps(results,indent=2))
