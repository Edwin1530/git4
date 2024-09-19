from fastapi.testclient import TestClient
from .main import app  # Importez l'application à partir de app.main

client = TestClient(app)

def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "OK"}
