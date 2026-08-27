#!/bin/bash
set -u

json_escape() {
  python -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '""'
}

num_or_zero() {
  awk 'NR==1 {printf "%s", $1}' 2>/dev/null || printf '0'
}

cpu=$(LC_ALL=C awk '/^cpu / {u=$2+$4; t=$2+$4+$5+$6+$7+$8+$9+$10; if (t>0) printf "%.0f", (u/t)*100}' /proc/stat)
mem_total=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
mem_avail=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
mem_used=$((mem_total-mem_avail))
mem_pct=0
if [ "$mem_total" -gt 0 ]; then mem_pct=$((mem_used*100/mem_total)); fi

uptime_sec=$(awk '{printf "%d", $1}' /proc/uptime)
load=$(awk '{printf "%.2f", $1}' /proc/loadavg)
host=$(cat /etc/hostname 2>/dev/null || printf 'Linux')
kernel=$(uname -r 2>/dev/null || printf '?')

# GPU summary: prefer nvidia-smi when available, otherwise expose renderer vendor/device from lspci.
gpu="Unknown"
if command -v nvidia-smi >/dev/null 2>&1; then
  gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1)
elif command -v lspci >/dev/null 2>&1; then
  gpu=$(lspci 2>/dev/null | grep -Ei 'vga compatible controller|3d controller|display controller' | head -n1 | sed 's/^[^:]*: //')
fi

# Hyprland windows/workspaces. The output is intentionally compact JSON so QML has little work to do.
hypr_json='{"workspaces":[],"windows":[]}'
if command -v hyprctl >/dev/null 2>&1; then
  hypr_json=$(hyprctl -j clients 2>/dev/null || printf '{"workspaces":[],"windows":[]}')
fi

python - "$cpu" "$mem_pct" "$mem_used" "$mem_total" "$uptime_sec" "$load" "$host" "$kernel" "$gpu" <<'PY'
import json, os, subprocess, sys, time

cpu=int(sys.argv[1] or 0)
mem_pct=int(sys.argv[2] or 0)
mem_used=int(sys.argv[3] or 0)
mem_total=int(sys.argv[4] or 0)
uptime=int(sys.argv[5] or 0)
load=float(sys.argv[6] or 0)
host=sys.argv[7]
kernel=sys.argv[8]
gpu=sys.argv[9]

def cmd(*args):
    try:
        return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ''

clients=[]
raw=cmd('hyprctl','-j','clients')
if raw:
    try:
        clients=json.loads(raw)
    except Exception:
        clients=[]

# Workspace inventory from Hyprland.
workspaces=[]
raw_ws=cmd('hyprctl','-j','workspaces')
if raw_ws:
    try:
        workspaces=json.loads(raw_ws)
    except Exception:
        workspaces=[]

# Top processes. ps is universally available on Omarchy.
procs=[]
try:
    out=subprocess.check_output(['ps','-eo','pid=,comm=,pcpu=,pmem=,etime=,user=','--sort=-pcpu'], text=True)
    for line in out.splitlines()[:16]:
        parts=line.split(None,5)
        if len(parts)>=6:
            procs.append({
                'pid':int(parts[0]), 'name':parts[1],
                'cpu':float(parts[2] or 0), 'mem':float(parts[3] or 0),
                'etime':parts[4], 'user':parts[5]
            })
except Exception:
    pass

# Network socket counts (not payloads) for an honest, privacy-preserving "activity" signal.
net_tcp=0
for f in ('/proc/net/tcp','/proc/net/tcp6'):
    try:
        with open(f) as h:
            net_tcp += max(0, sum(1 for _ in h)-1)
    except Exception:
        pass

# Normalize windows to a small payload.
windows=[]
for c in clients:
    at=c.get('at',[0,0]); size=c.get('size',[0,0])
    windows.append({
        'address':c.get('address',''),
        'class':c.get('class','') or c.get('initialClass',''),
        'title':c.get('title',''),
        'workspace':c.get('workspace',{}).get('name',str(c.get('workspace',{}).get('id','?'))),
        'workspaceId':c.get('workspace',{}).get('id',0),
        'x':at[0] if len(at)>0 else 0,
        'y':at[1] if len(at)>1 else 0,
        'w':size[0] if len(size)>0 else 0,
        'h':size[1] if len(size)>1 else 0,
        'pid':c.get('pid',0),
        'floating':bool(c.get('floating',False)),
        'fullscreen':bool(c.get('fullscreen',0)),
        'focused':bool(c.get('focusHistoryID',999999)==0 or c.get('focusHistoryID',999999)==1),
    })

# Create graph edges from workspace -> windows -> process. Avoid pretending we know process ancestry beyond /proc.
nodes=[]
edges=[]
seen_ws=set()
for i,w in enumerate(windows):
    ws=str(w['workspace'])
    if ws not in seen_ws:
        seen_ws.add(ws)
        nodes.append({'id':'ws:'+ws,'type':'workspace','label':'Workspace '+ws})
    pid=str(w['pid'])
    nodes.append({'id':'win:'+pid+':'+str(i),'type':'window','label':w['class'] or 'Window','pid':w['pid']})
    edges.append(['ws:'+ws,'win:'+pid+':'+str(i)])
    nodes.append({'id':'proc:'+pid,'type':'process','label':w['class'] or 'process','pid':w['pid']})
    edges.append(['win:'+pid+':'+str(i),'proc:'+pid])

# De-duplicate process nodes.
dedup=[]; seen=set()
for n in nodes:
    if n['id'] not in seen:
        seen.add(n['id']); dedup.append(n)

# Human-friendly memory values.
def mb(kb): return round(kb/1024,1)

data={
  'ts':int(time.time()),
  'host':host,
  'kernel':kernel,
  'gpu':gpu,
  'uptime':uptime,
  'load':load,
  'cpu':max(0,min(100,cpu)),
  'memory':{'usedMb':mb(mem_used),'totalMb':mb(mem_total),'pct':mem_pct},
  'network':{'tcpSockets':net_tcp},
  'workspaces':[{'id':w.get('id'), 'name':w.get('name',''), 'windows':w.get('windows',0)} for w in workspaces],
  'windows':windows,
  'processes':procs,
  'graph':{'nodes':dedup[:80], 'edges':edges[:100]},
}
print(json.dumps(data,separators=(',',':')))
PY
