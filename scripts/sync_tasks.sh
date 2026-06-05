#!/bin/bash
# sync_tasks.sh — синхронизация трекера задач с GitHub Pages
# Запуск: bash /root/task-tracker/scripts/sync_tasks.sh
set -e

TRACKER_DIR="/root/task-tracker"
TIMESTAMP=$(date +%Y%m%d_%H%M)
echo "=== SYNC TASKS $TIMESTAMP ==="

# 1. Собрать задачи из источников (дополнительно)
# Пока используем tasks.json как основной источник
cd "$TRACKER_DIR"

# 2. Обновить timestamp в tasks.json
python3 -c "
import json, datetime
with open('data/tasks.json', 'r') as f:
    data = json.load(f)
data['meta']['updated'] = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S+03:00')
with open('data/tasks.json', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
print('Updated: ' + data['meta']['updated'])
"

# 3. Сохранить историческую копию (по годам)
YEAR=$(date +%Y)
mkdir -p "history/$YEAR"
cp "data/tasks.json" "history/$YEAR/tasks_$TIMESTAMP.json"
echo "Backup: history/$YEAR/tasks_$TIMESTAMP.json"

# 4. Git push в kanban-board (GitHub Pages)
cd "$TRACKER_DIR"
git init 2>/dev/null || true
git remote add origin https://github.com/ssv86on-png/kanban-board.git 2>/dev/null || true
git fetch origin 2>/dev/null || true
git checkout main 2>/dev/null || git checkout -b main
git add -A
git commit -m "sync: $TIMESTAMP" 2>/dev/null || echo "nothing to commit"
git push -f origin main 2>&1
echo "=== SYNC COMPLETE $TIMESTAMP ==="
