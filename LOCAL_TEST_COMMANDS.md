# Quick CI/CD Test Commands

## Test Frontend Locally
```bash
cd frontend
npm install
npm test -- --coverage --watchAll=false
npm run build
npm run lint
```

## Test Backend Locally  
```bash
cd backend
python -m pytest --cov=. --cov-report=xml --cov-report=term
python -m flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics --exclude=venv,__pycache__,.git
python -m black --check --diff .
python -m bandit -r . -f json -o bandit-report.json || true
python -m safety check --json --output safety-report.json || true
```

## Test Docker Builds
```bash
# Backend
docker build -t test-backend ./backend

# Frontend  
docker build -t test-frontend ./frontend
```

## Validate Workflows
```bash
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml')); print('✅ Workflow is valid')"
```
