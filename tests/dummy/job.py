import sys

if sys.argv[1:] != ["single"]:
    raise SystemExit("unexpected arguments")
print("dummy job ran")
