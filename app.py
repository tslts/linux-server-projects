from flask import Flask, request, redirect, url_for, render_template
from database import get_db_connection

app = Flask(__name__)


@app.route("/viikko2", methods=["GET", "POST"])
def viikko2():
    connection = get_db_connection()

    try:
        with connection.cursor() as cursor:
            if request.method == "POST":
                name = request.form.get("name", "").strip()
                message = request.form.get("message", "").strip()

                if (
                    name
                    and message
                    and len(name) <= 100
                    and len(message) <= 5000
                ):
                    cursor.execute(
                        "INSERT INTO messages (name, message) "
                        "VALUES (%s, %s)",
                        (name, message)
                    )

                return redirect(url_for("viikko2"))

            cursor.execute(
                "UPDATE visits SET total = total + 1 WHERE id = 1"
            )

            cursor.execute(
                "SELECT total FROM visits WHERE id = 1"
            )
            visits = cursor.fetchone()[0]

            cursor.execute(
                "SELECT name, message, created_at "
                "FROM messages ORDER BY id DESC"
            )
            messages = cursor.fetchall()

    finally:
        connection.close()

    return render_template(
        "viikko2.html",
        visits=visits,
        messages=messages
    )

