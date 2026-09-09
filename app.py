#!/usr/bin/env python3
"""Zabtrain — тренажёр триггерных выражений Zabbix (Flask Web Edition)."""

import json
import os
import random
import re

from flask import Flask, jsonify, render_template, request, session

# ---------------------------------------------------------------------------
# App setup
# ---------------------------------------------------------------------------

app = Flask(__name__)
app.secret_key = os.urandom(24)

# ---------------------------------------------------------------------------
# Load tasks
# ---------------------------------------------------------------------------

_tasks_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tasks.json")
with open(_tasks_path, encoding="utf-8") as f:
    TASKS: list[dict] = json.load(f)

TOTAL = len(TASKS)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def normalize(text: str) -> str:
    """Remove all whitespace for comparison."""
    return re.sub(r"\s+", "", text)


def start_session() -> None:
    """Initialise training state in the session."""
    session["mode"] = "none"          # none | random | ordered | single
    session["indices"] = list(range(TOTAL))
    if session["mode"] == "random":
        random.shuffle(session["indices"])
    session["current_idx"] = 0
    session["correct"] = 0
    session["skipped"] = 0
    session["task_num"] = 0          # for single-task mode


# ---------------------------------------------------------------------------
# Routes — page
# ---------------------------------------------------------------------------


@app.route("/")
def index():
    return render_template("index.html", total=TOTAL)


# ---------------------------------------------------------------------------
# Routes — API
# ---------------------------------------------------------------------------


@app.route("/api/start", methods=["POST"])
def api_start():
    body = request.get_json(force=True)
    mode = body.get("mode", "random")

    session["mode"] = mode
    session["indices"] = list(range(TOTAL))
    session["correct"] = 0
    session["skipped"] = 0

    if mode == "random":
        random.shuffle(session["indices"])
    elif mode == "single":
        session["task_num"] = int(body.get("task_num", 0))
        session["current_idx"] = session["task_num"]
        session["indices"] = [session["task_num"]]

    session["current_idx"] = 0
    return jsonify({"ok": True})


@app.route("/api/task")
def api_task():
    idx = session.get("current_idx", 0)
    mode = session.get("mode", "none")

    if mode == "none" or mode == "single":
        order = session.get("indices", [])
        if not order:
            return jsonify({"error": "Тренировка не начата"}), 400
        real_idx = order[idx] if idx < len(order) else order[0]
    else:
        order = session.get("indices", [])
        real_idx = order[idx] if idx < len(order) else 0

    task = TASKS[real_idx]
    task_num = idx + 1
    total = len(session.get("indices", []))

    return jsonify(
        {
            "num": task_num,
            "total": total,
            "desc": task["desc"],
            "hint": task["hint"],
            "example": task["example"],
            "correct": session.get("correct", 0),
            "skipped": session.get("skipped", 0),
        }
    )


@app.route("/api/check", methods=["POST"])
def api_check():
    body = request.get_json(force=True)
    answer = body.get("answer", "").strip()
    idx = session.get("current_idx", 0)

    order = session.get("indices", [])
    if not order:
        return jsonify({"error": "Тренировка не начата"}), 400

    real_idx = order[idx] if idx < len(order) else 0
    pattern = TASKS[real_idx]["regex"]

    norm = normalize(answer)
    if re.search(pattern, norm):
        session["correct"] = session.get("correct", 0) + 1
        return jsonify({"ok": True, "correct": True})
    return jsonify({"ok": True, "correct": False})


@app.route("/api/hint")
def api_hint():
    idx = session.get("current_idx", 0)
    order = session.get("indices", [])
    if not order:
        return jsonify({"error": "Тренировка не начата"}), 400

    real_idx = order[idx] if idx < len(order) else 0
    return jsonify({"hint": TASKS[real_idx]["hint"]})


@app.route("/api/skip")
def api_skip():
    idx = session.get("current_idx", 0)
    order = session.get("indices", [])
    if not order:
        return jsonify({"error": "Тренировка не начата"}), 400

    real_idx = order[idx] if idx < len(order) else 0
    session["skipped"] = session.get("skipped", 0) + 1

    return jsonify(
        {
            "example": TASKS[real_idx]["example"],
            "hint": TASKS[real_idx]["hint"],
        }
    )


@app.route("/api/next")
def api_next():
    idx = session.get("current_idx", 0)
    order = session.get("indices", [])
    total = len(order)

    if idx + 1 >= total:
        # Training complete
        return jsonify(
            {
                "done": True,
                "correct": session.get("correct", 0),
                "skipped": session.get("skipped", 0),
                "total": total,
            }
        )

    session["current_idx"] = idx + 1
    return jsonify({"done": False})


@app.route("/api/tasks-list")
def api_tasks_list():
    """Return all task descriptions for the 'show all' view."""
    result = []
    for i, t in enumerate(TASKS):
        result.append({"num": i + 1, "desc": t["desc"]})
    return jsonify({"tasks": result})


@app.route("/api/quit")
def api_quit():
    session.clear()
    return jsonify({"ok": True})


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
