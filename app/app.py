import os

from flask import Flask, jsonify, request

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "dev")


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.get("/version")
def version():
    return jsonify({"version": VERSION})


@app.get("/env")
def env():
    return jsonify({"environment": ENVIRONMENT})

configs = {}

@app.post("/config")
def create_config():
    body = request.get_json(silent=True) or {}
    name = body.get("name")
    value = body.get("value")
    if not isinstance(name, str) or not name or value is None:
        return jsonify({"error": "name and value are required"}), 400
    configs[name] = value
    return jsonify({"name": name, "value": value}), 201


@app.get("/config/<name>")
def get_config(name):
    if name not in configs:
        return jsonify({"error": "not found"}), 404
    return jsonify({"name": name, "value": configs[name]})


@app.delete("/config/<name>")
def delete_config(name):
    if name not in configs:
        return jsonify({"error": "not found"}), 404
    del configs[name]
    return jsonify({"deleted": True})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)