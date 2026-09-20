import pytest

from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as test_client:
        yield test_client


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_config_lifecycle(client):
    created = client.post("/config", json={"name": "database_url", "value": "postgres://example"})
    assert created.status_code == 201
    assert client.get("/config/database_url").get_json()["value"] == "postgres://example"
    assert client.delete("/config/database_url").get_json() == {"deleted": True}
    assert client.get("/config/database_url").status_code == 404
