import requests, os, subprocess, time

def test_health_endpoint():
    # Spin up a local server quickly for CI test (uvicorn)
    proc = subprocess.Popen(
        ["python", "-m", "uvicorn", "app.main:app", "--port", "18000"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        time.sleep(1.5)
        resp = requests.get("http://127.0.0.1:18000/healthz", timeout=3)
        assert resp.status_code == 200
        assert resp.json().get("status") == "ok"
    finally:
        proc.terminate()
